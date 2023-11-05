library(keras)
library(tidyverse)
library(lubridate)

setwd("/Users/yash/Desktop/oil")
# Read the CSV file
df <- read_csv('merged_data.csv')
print(head(df))

# Convert 'Time' to a Date object for future plotting
df$Time <- as.Date(paste0("01-", df$Time), format = "%d-%b-%y")
print(tail(df$Time, 15))

# Select relevant columns for training, excluding any non-numeric or target columns
cols <- c(colnames(df)[2:13], colnames(df)[16:23])  # Assuming these are the correct columns
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
n_past <-12

# Prepare training data
trainX <- list()
trainY <- list()

for (i in seq(n_past, nrow(df_for_training_scaled) - n_future + 1)) {
  trainX[[length(trainX) + 1]] <- df_for_training_scaled[(i - n_past + 1):i, ]
  trainY[[length(trainY) + 1]] <- df_for_training_scaled[i + n_future - 1, "Saudi.Arabia.Exports..Thousand.Barrels.Day."]
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
  epochs = 40,
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
scaled_prediction <- (prediction * scale["Saudi.Arabia.Exports..Thousand.Barrels.Day."]) + center["Saudi.Arabia.Exports..Thousand.Barrels.Day."]
y_pred_next_month <- as.vector(scaled_prediction)

# Create the date for the next month prediction
forecast_date <- max(df$Time) %m+% months(1)

# Create forecast dataframe
df_forecast_next_month <- tibble(Date = forecast_date, `Saudi.Arabia.Exports..Thousand.Barrels.Day.` = y_pred_next_month)

# Plot actual vs predicted values on the training set
train_predictions <- model %>% predict(trainX)
scaled_train_predictions <- (train_predictions * scale["Saudi.Arabia.Exports..Thousand.Barrels.Day."]) + center["Saudi.Arabia.Exports..Thousand.Barrels.Day."]

# Assuming the length of scaled_train_predictions corresponds to the number of predictions
num_predictions <- length(scaled_train_predictions)

# Since we have one more prediction than we have space for in the df_for_training, we drop one prediction
scaled_train_predictions <- scaled_train_predictions[-1]

# Create a dataframe for plotting with correct dimensions
df_training_with_predictions <- df_for_training %>% 
  slice((n_past + 1):(n_past + num_predictions - 1)) %>% 
  mutate(Predicted = scaled_train_predictions)

# Now, add the corresponding dates from df to the df_training_with_predictions
df_training_with_predictions$Time <- df$Time[(n_past + 1):(n_past + num_predictions - 1)]

# Plotting actual vs predicted on the training data
ggplot(df_training_with_predictions, aes(x = Time)) +
  geom_line(aes(y = `Saudi.Arabia.Exports..Thousand.Barrels.Day.`), color = "blue") +
  geom_line(aes(y = Predicted), color = "red") +
  labs(title = "Actual vs Predicted Exports", x = "Date", y = "Exports (Thousand Barrels/Day)")

# Create the df_forecast_next_month DataFrame with the forecasted values
df_forecast_next_month <- data.frame(
  Time = forecast_date, 
  Predicted = y_pred_next_month
)

# Create df_forecast_for_plot with the same structure as df_training_with_predictions
df_forecast_for_plot <- df_training_with_predictions %>%
  slice(0) %>%  # Create a row with the same structure but empty
  bind_rows(df_forecast_next_month) %>%  # Add the forecasted data
  mutate(`Saudi.Arabia.Exports..Thousand.Barrels.Day.` = NA_real_)  # Set actual exports to NA

# Combine the actual and forecast data frames
df_plot <- bind_rows(
  df_training_with_predictions %>% mutate(Data_Type = "Actual"),
  df_forecast_for_plot %>% mutate(Data_Type = "Forecast")
)

# Plot actual vs forecasted exports
ggplot(df_plot, aes(x = Time)) +
  geom_line(aes(y = `Saudi.Arabia.Exports..Thousand.Barrels.Day.`, color = Data_Type), na.rm = TRUE) +
  geom_line(aes(y = Predicted, color = "red"), linetype = "dashed", na.rm = TRUE) +
  geom_point(aes(y = Predicted, color = "red"), na.rm = TRUE) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
  labs(title = "Actual vs Forecast Exports", x = "Date", y = "Exports (Thousand Barrels/Day)") +
  scale_color_manual(values = c("Actual" = "blue", "Forecast" = "red")) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Calculate the residuals/errors
residuals <- df_training_with_predictions$`Saudi.Arabia.Exports..Thousand.Barrels.Day.` - df_training_with_predictions$Predicted

# Calculate MSE
mse <- mean(residuals^2, na.rm = TRUE)  # na.rm = TRUE to handle any potential NA values

# Calculate RMSE
rmse <- sqrt(mse)

# Calculate the total sum of squares (SST)
sst <- sum((df_training_with_predictions$`Saudi.Arabia.Exports..Thousand.Barrels.Day.` - mean(df_training_with_predictions$`Saudi.Arabia.Exports..Thousand.Barrels.Day.`))^2, na.rm = TRUE)

# Calculate the residual sum of squares (SSR)
ssr <- sum(residuals^2, na.rm = TRUE)

# Calculate R-squared
r_squared <- 1 - (ssr/sst)

# Output RMSE and R-squared
list(RMSE = rmse, R_Squared = r_squared)
