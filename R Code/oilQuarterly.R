# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(xts)
library(zoo)
setwd("/Users/yash/Desktop/oil")
# Read the first CSV file
data1 <- read.csv("DataMonthly.csv")

# Convert the "Time" column in data1 to a date format
data1$Date <- as.Date(paste0("01-", data1$Time), format = "%d-%b-%y")

# Convert the "Date" column in data1 to yearqtr format
data1$YearQtr <- as.yearqtr(data1$Date)

# Filter data1 to include data until March 2023
data1 <- data1 %>%
  filter(YearQtr <= as.yearqtr("2023 Q1"))


# Read the second CSV file
data2 <- read.csv("Quarter2.csv")


# Convert the "Quarter" column in data2 to a date format (if needed)
data2$Quarter <- as.yearqtr(data2$Quarter, format = "%YQ%q")

# Merge the two datasets based on the common quarterly column
merged_data <- full_join(data1, data2, by = c("YearQtr" = "Quarter"))


# Clean the "Volume" column by removing any non-numeric characters
merged_data$Volume <- as.numeric(gsub("[^0-9.]", "", merged_data$Volume))

for (variable in setdiff(names(merged_data), "Date")) {
  df <- xts(merged_data[, variable], order.by = merged_data$YearQtr)
  
  p <- ggplot(data.frame(Date = as.Date(index(df)), Value = coredata(df)), aes(x = Date, y = Value)) +
    geom_line(aes(group = 1)) +  # Treat all data as a single group
    labs(title = paste("Time Series for", variable),
         x = "Date",
         y = "Value") +
    theme_minimal()
  
  print(p)
}


# Create a correlation matrix for the numeric columns
correlation_matrix <- cor(select(merged_data, -Time, -Date, -YearQtr))

# Create a heatmap
ggplot(data = melt(correlation_matrix), aes(Var1, Var2, fill = value)) +
  geom_tile() +
  geom_text(aes(label = round(value, 2)), size=2, vjust = 1) +  # Add labels rounded to 2 decimal places
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0) +
  labs(title = "Correlation Heatmap",
       x = "Variables",
       y = "Variables") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
