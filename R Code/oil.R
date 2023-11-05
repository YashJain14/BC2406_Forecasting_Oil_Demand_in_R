library(data.table)
library(ggplot2)
library(zoo) 
library(tidyverse)
library(reshape2)
library(readr)

#Load Data
setwd("/Users/yash/Desktop/oil")
news <- fread("news.csv")
price <- fread("oil_price_vol.csv")
SaudiProduction <- fread("SaudiArabia_OilProduction.csv")
gdp_data <- fread("gdp.csv")
gdp_mag_data <- fread("gdp_magnitude.csv")
country <- fread("country.csv")
export <- fread("saudiExport.csv")
USimports <- fread("USImports.csv")


###############################################################################
# Convert Date to Date format
price$Date <- as.Date(price$Date, format = "%d-%b-%y") 
# Create time series plot
plot(price$Date, price$Open,  
     xlab = "Date", ylab = "Price",
     type = "l", lwd = 2, col = "blue")

plot(price$Date, as.numeric(gsub(",", "", price$Volume)), 
     type = "l", 
     xlab = "Date", ylab = "Volume", 
     main = "Time vs. Volume", col ="blue", lwd = 2)

# Create a data table
price_dt <- data.table(price)

# Convert Volume to numeric and remove commas
price_dt[, Volume := as.numeric(gsub(",", "", Volume))]

# Create a month column
price_dt[, month := as.yearmon(Date)]

# Aggregate data by month with mean for Open and sum for Volume
price_agg <- price_dt[, .(Open = mean(Open), Volume = sum(Volume)), by = month]

# Create time series plot with monthly time axis for Open prices
plot(price_agg$month, price_agg$Open,  
     xlab = "Month", ylab = "Mean Price",
     type = "l", lwd = 2, col = "blue")

# Create time series plot with monthly time axis for Volume
plot(price_agg$month, price_agg$Volume, 
     type = "l", 
     xlab = "Month", ylab = "Total Volume", 
     main = "Time vs. Volume", col = "blue", lwd = 2)
###############################################################################


# Convert the "Date" column to the "yearmon" class
SaudiProduction$Date <- as.yearmon(SaudiProduction$Date, format = "%b-%y")

# Plot the data
plot(SaudiProduction$Date, SaudiProduction$Production,  
     xlab = "Date", ylab = "Production",
     type = "l", lwd = 2, col = "blue")


###############################################################################

# Convert Date to Date format
news$Date <- as.Date(news$Date, format = "%d/%m/%y")

# Create a new column for the quarter
news$Quarter <- as.yearqtr(news$Date)

# Group the data by quarter and calculate the average rating
quarterly_avg <- news %>%
  group_by(Quarter) %>%
  summarise(AvgRating = mean(Rating, na.rm = TRUE))

# Plot the quarterly average ratings
plot(quarterly_avg$Quarter, quarterly_avg$AvgRating, 
     xlab = "Quarter", ylab = "Average Rating",
     type = "l", lwd = 2, col = "blue")


###############################################################################



# Create a line plot for all countries in the same graph
ggplot(gdp_data, aes(x = TIME, y = Value, group = LOCATION, color = LOCATION)) +
  geom_line() +
  labs(
    x = "Time",
    y = "Value",
    title = "GDP Growth Rate"
  ) +
  theme_minimal()





data_long <- melt(gdp_mag_data, id.vars = c("Country", "Scale"))
# Create a line plot for multiple countries
ggplot(data_long, aes(x = variable, y = value, group = Country, color = Country)) +
  geom_line() +
  labs(
    x = "Quarter",
    y = "Value (Millions)",
    title = "GDP Growth"
  ) +
  theme_minimal() +
  theme(legend.position = "top")  # Adjust the legend position


###############################################################################

# Convert the "Time" column to a date format (MMM-YY)
country$Time <- as.Date(paste0("01-", country$Time), format = "%d-%b-%y")


ggplot(country, aes(x = Time)) +
  geom_line(aes(y = China, color = "China")) +
  geom_line(aes(y = India, color = "India")) +
  geom_line(aes(y = Japan, color = "Japan")) +
  geom_line(aes(y = Korea, color = "Korea")) +
  geom_line(aes(y = `United States of America`, color = "United States of America")) +
  labs(title = "Crude Oil Imports by Country",
       x = "Time",
       y = "Thousand Barrels per day (kb/d)") +
  scale_x_date(date_labels = "%b %Y", date_breaks = "3 months") +
  scale_color_manual(values = c("China" = "red", "India" = "blue", "Japan" = "green", "Korea" = "purple", "United States of America" = "orange")) +
  theme_minimal()


###############################################################################

# Convert the "Time" column to a date format (MMM-YY)
export$Time <- as.Date(paste0("01-", export$Time), format = "%d-%b-%y")
ggplot(export, aes(x = Time, y = `Saudi Arabia`)) +
  geom_line() +
  labs(title = "Saudi Arabia Export Over Time",
       x = "Time",
       y = "Export Value") +
  scale_x_date(date_labels = "%b-%y", date_breaks = "3 month") +
  theme_minimal()


###############################################################################

# Convert the "Time" column to a date format (MMM-YY)
USimports$Date <- as.Date(as.yearmon(USimports$Date, format = "%b-%Y"))
ggplot(USimports, aes(x = Date, y = `U.S. Net Imports from Saudi Arabia of Crude Oil (Thousand Barrels per Day)`)) +
  geom_line() +
  labs(title = "US Import from Saudi Arabia",
       x = "Time",
       y = "Import Value") +
  scale_x_date(date_labels = "%b-%y", date_breaks = "3 month") +
  theme_minimal()
