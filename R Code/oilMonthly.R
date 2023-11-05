# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(corrplot)

setwd("/Users/yash/Desktop/oil")
# Read the CSV file
data <- read.csv("DataMonthly.csv")

# Convert the "Time" column to a date format
data$Date <- as.Date(paste0("01-", data$Time), format = "%d-%b-%y")

# Clean the "Volume" column by removing any non-numeric characters
data$Volume <- as.numeric(gsub("[^0-9.]", "", data$Volume))


# Create separate time series graphs for each variable using a loop
for (variable in setdiff(names(data), c("Date", "Time"))) {
  df <- data %>%
    select(Date, variable) %>%
    rename(Variable = variable, Value = !!variable)
  
  p <- ggplot(df, aes(x = Date, y = Value)) +
    geom_line() +
    labs(title = paste("Time Series for", variable),
         x = "Date",
         y = "Value") +
    theme_minimal()
  
  print(p)
}

# Create a correlation matrix for the numeric columns
correlation_matrix <- cor(select(data, -Time, -Date))

# Create a heatmap
ggplot(data = melt(correlation_matrix), aes(Var1, Var2, fill = value)) +
  geom_tile() +
  geom_text(aes(label = round(value, 2)), vjust = 1) +  # Add labels rounded to 2 decimal places
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0) +
  labs(title = "Correlation Heatmap",
       x = "Variables",
       y = "Variables") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
