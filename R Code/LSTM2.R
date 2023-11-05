# Load necessary libraries
library(keras)
library(tidyverse)
library(lubridate)

# Set the working directory to the location of the CSV file
setwd("/Users/yash/Desktop/oil")

# Read the CSV file
df <- read_csv('merged_data.csv')
print(head(df))

# Convert 'Time' to a Date object for future plotting
df$Time <- as.Date(paste0("01-", df$Time), format = "%d-%b-%y")
print(tail(df$Time, 15))

# Select relevant columns for training, excluding any non-numeric or target columns
cols <- c(colnames(df)[2:13], colnames(df)[16:23])
print(cols)

# Create a new dataframe with only training data
df_for_training <- df %>% select(all_of(cols))

# Normalize the dataset
scaler <- scale(df_for_training)
df_for_training_scaled <- as.data.frame(scaler)
center <- attr(scaler, "scaled:center")
scale <- attr(scaler, "scaled:scale")

# Parameters for LSTM input
n_future <- 1
n_past <- 12

# Prepare training data
trainX <- list()
trainY <- list()

for (i in seq(n_past, nrow(df_for_training_scaled) - n_future + 1)) {
  trainX[[length(trainX) + 1]] <- df_for_training_scaled[(i - n_past + 1):i, ]
  trainY[[length(trainY) + 1]] <- df_for_training_scaled[i + n_future - 1, "Saudi.Arabia.Production..Thousand.Barrels.Day."]
}

trainX <- array(unlist(trainX), dim = c(length(trainX), n_past, length(cols)))
trainY <- matrix(unlist(trainY), ncol = 1, byrow = TRUE)

# Define and compile the LSTM model
model <- keras_model_sequential() %>%
  layer_lstm(units = 64, activation = 'relu', input_shape = c(n_past, length(cols)), return_sequences = TRUE) %>%
  layer_lstm(units = 32, activation = 'relu', return_sequences = FALSE) %>%
  layer_dropout(rate = 0.2) %>%
  layer_dense(units = 1) %>%
  compile(
    optimizer = optimizer_adam(),
    loss = 'mse'
  )

# Fit the model
history <- model %>% fit(
  trainX,
  trainY,
  epochs = 25,  # Adjust the number of epochs if necessary
  batch_size = 16,
  validation_split = 0.1,
  verbose = 1
)

# Plot the training and validation loss
plot(history)

# Prepare the data for the next month prediction
last_known_data <- df_for_training_scaled[(nrow(df_for_training_scaled) - n_past + 1):nrow(df_for_training_scaled), ]

# Prepare the data for prediction
x_input <- array(as.matrix(last_known_data), dim = c(1, n_past, ncol(df_for_training_scaled)))

# Make the prediction
prediction <- model %>% predict(x_input)

# Scale back the prediction for the target variable
scaled_prediction <- (prediction * scale["Saudi.Arabia.Production..Thousand.Barrels.Day."]) + center["Saudi.Arabia.Production..Thousand.Barrels.Day."]
y_pred_next_month <- as.vector(scaled_prediction)

# Create the date for the next month prediction
forecast_date <- max(df$Time) %m+% months(1)

# Create forecast dataframe
df_forecast_next_month <- tibble(Date = forecast_date, `Saudi.Arabia.Production..Thousand.Barrels.Day.` = y_pred_next_month)

# Plot actual vs predicted values on the training set
train_predictions <- model %>% predict(trainX)
scaled_train_predictions <- (train_predictions * scale["Saudi.Arabia.Production..Thousand.Barrels.Day."]) + center["Saudi.Arabia.Production..Thousand.Barrels.Day."]

# Assuming the length of scaled_train_predictions corresponds to the number of predictions
num_predictions <- length(scaled_train_predictions)

# Since we have one more prediction than we have space for in the df_for_training, we drop one prediction
# Typically, you would drop the first prediction as it's based on the first window of training data
scaled_train_predictions <- scaled_train_predictions[-1]

# Create a dataframe for plotting with correct dimensions
df_training_with_predictions <- df_for_training %>% 
  slice((n_past + 1):(n_past + num_predictions - 1)) %>% 
  mutate(Predicted = scaled_train_predictions)

# Now, add the corresponding dates from df to the df_training_with_predictions
# We need to ensure that the dates match the predictions
df_training_with_predictions$Time <- df$Time[(n_past + 1):(n_past + num_predictions - 1)]

# Plotting actual vs predicted on the training data
ggplot(df_training_with_predictions, aes(x = Time)) +
  geom_line(aes(y = `Saudi.Arabia.Production..Thousand.Barrels.Day.`), color = "blue") +
  geom_line(aes(y = Predicted), color = "red") +
  labs(title = "Actual vs Predicted Production", x = "Date", y = "Production (Thousand Barrels/Day)")


# Assuming y_pred_next_month and forecast_date are already defined with the correct values

# Create the df_forecast_next_month DataFrame with the forecasted values
df_forecast_next_month <- data.frame(
  Time = forecast_date, 
  Predicted = y_pred_next_month
)

# Create df_forecast_for_plot with the same structure as df_training_with_predictions
# But with NA values for actual production and the predicted values for the forecasted date
# This assumes df_training_with_predictions has a column 'Saudi.Arabia.Production..Thousand.Barrels.Day.'
# which is the actual production values we want to plot.
df_forecast_for_plot <- df_training_with_predictions %>%
  slice(0) %>%  # Create a row with the same structure but empty
  bind_rows(df_forecast_next_month) %>%  # Add the forecasted data
  mutate(`Saudi.Arabia.Production..Thousand.Barrels.Day.` = NA_real_)  # Set actual production to NA

# Combine the actual and forecast data frames
df_plot <- bind_rows(
  df_training_with_predictions %>% mutate(Data_Type = "Actual"),
  df_forecast_for_plot %>% mutate(Data_Type = "Forecast")
)

ggplot(df_plot, aes(x = Time)) +
  geom_line(aes(y = `Saudi.Arabia.Production..Thousand.Barrels.Day.`, color = Data_Type), na.rm = TRUE) +
  geom_line(aes(y = Predicted, color = Data_Type), linetype = "dashed", na.rm = TRUE) +
  geom_point(aes(y = Predicted, color = Data_Type), na.rm = TRUE) + # This adds points to the predicted line
  scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") + # This will format the x-axis with month and year
  labs(title = "Actual vs Forecast Production", x = "Date", y = "Production (Thousand Barrels/Day)") +
  scale_color_manual(values = c("Actual" = "blue", "Forecast" = "red")) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))  # Rotate x-axis labels for better readability
