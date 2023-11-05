# Install Required Packages
library(httr)
library(tidyverse)

# Set your API key
my_API <- "_api_key_here_"

# Define a function to interact with ChatGPT
hey_chatGPT <- function(question, text) {
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions",
    add_headers(Authorization = paste("Bearer", my_API)),
    content_type_json(),
    encode = "json",
    body = list(
      model = "gpt-3.5-turbo-0301",
      messages = list(
        list(role = "system", content = "You are a user who is rating news."),
        list(role = "user", content = question),
        list(role = "assistant", content = text)
      )
    )
  )
  
  response_text <- content(response)$choices[[1]]$message$content
  return(response_text)
}

# Read in your dataset
data <- read.csv(file.choose())  # Update with your actual file path

# Create a "gpt" column
data$gpt <- NA

# Loop over your dataset and prompt ChatGPT
for (i in 1:nrow(data)) {
  question <- "Rate the news headline based on how good the news is for Saudi Aramco from 1 to 10:"
  text <- data$Headline[i]
  result <- hey_chatGPT(question, text)
  
  # Extract numeric values from the response using regular expressions
  numeric_values <- as.numeric(regmatches(result, regexpr("\\d+", result)))
  
  if (length(numeric_values) > 0) {
    data$gpt[i] <- max(min(numeric_values, 10), 1)  # Ensure the value is between 1 and 10
  } else {
    data$gpt[i] <- NA
  }
}

# Print the resulting dataset
print(data)

