# Load necessary libraries
library(tidyverse)
library(readr)
library(vars)
library(data.table)
library(tseries)
library(forecast)
library(ggplot2)

setwd("/Users/kp/R/Oil_Project")
merged_df = fread("DataMonthly.csv")

merged_df$Time <- as.Date(as.yearmon(merged_df$Time, "%y-%b"))
merged_df$Volume <- as.numeric(gsub(",", "", merged_df$Volume))
start_year <- as.numeric(format(min(merged_df$Time), "%Y"))  # start year
start_month <- as.numeric(format(min(merged_df$Time), "%m"))   # start month

colnames(merged_df)
summary(merged_df)

data_ts <- ts(subset(merged_df, select = -Time), start = c(2020, 1), frequency = 12)

ggplot(data = export_data, aes(x = time_seq)) +
  geom_line(aes(y = actual_exports), color = "black") + 
  labs(x = "Date", y = "Exports (in Thousand Barrels per Day)", title = "Time Series of Saudi Arabia's Oil Export") +
  theme_minimal()

model <- tslm(Exports ~  Volume + 
                China_Import + trend + US_Import + Japan_Import + India_Import +
                 US_Import_from_Saudi_Arabia , data=data_ts)
summary(model)
checkresiduals(model)

fitted_values = fitted(model)

merged_df$fitted_values <- fitted_values

ggplot(data = merged_df, aes(x = Time)) + 
  geom_line(aes(y = Exports, colour = "Actual"), linetype = "solid") +
  geom_line(aes(y = fitted_values, colour = "Predicted"), linetype = "dashed") +  
  labs(x = "Time", y = "Exports", title = "Actual vs. Predicted Exports") + 
  theme_minimal() + theme(legend.position = "bottom") +
  scale_colour_manual("", values = c("Actual" = "black", "Predicted" = "red")) +
  scale_linetype_manual("", values = c("Actual" = "solid", "Predicted" = "dashed"))

rmse <- sqrt(mean((merged_df$Exports - fitted_values)^2))
print(rmse)


data_ts_var = data_ts[, c("Exports", "Volume", 
                          "Japan_Import", "US_Import_from_Saudi_Arabia")]


VARselect(data_ts_var, lag.max=5,
          type="const")[["selection"]]

p = 5
var_model <- VAR(data_ts_var, p = p, type = "const")
summary(var_model)

actual_values <- window(data_ts_var, start = c(2020,p+1))
fitted_values <- fitted(var_model)
rmse <- sqrt(colMeans((actual_values - fitted_values)^2))
print(rmse)

fitted_exports = fitted_values[,"Exports"]
fitted_exports_full <- c(rep(NA, 5), fitted_exports)
actual_exports = data_ts_var[,"Exports"]

time_seq <- seq(from = as.Date("2020-01-01"), by = "month", length.out = length(actual_exports))

export_data <- data.frame(
  time_seq = time_seq,
  actual_exports = actual_exports,
  fitted_exports = fitted_exports_full
)

ggplot(data = export_data, aes(x = time_seq)) + 
  geom_line(aes(y = actual_exports, colour = "Actual"), linetype = "solid") +
  geom_line(aes(y = fitted_exports, colour = "Predicted"), linetype = "dashed") +  
  labs(x = "Time", y = "Exports", title = "Actual vs. Predicted Exports") + 
  theme_minimal() + theme(legend.position = "bottom") +
  scale_colour_manual("", values = c("Actual" = "black", "Predicted" = "red")) +
  scale_linetype_manual("", values = c("Actual" = "solid", "Predicted" = "dashed"))


forecast_results <- predict(var_model, n.ahead = 24)
par(mar = c(3, 3, 2, 2))
forecast(var_model) %>%
  autoplot() + xlab("Year")
