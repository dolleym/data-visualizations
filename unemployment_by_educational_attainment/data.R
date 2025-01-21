library(httr)
library(dplyr)
library(glue)
# Link to unemployment  series codes: https://data.bls.gov/toppicks?survey=ln

# Register for a BLS API key and save as environmental variable: https://data.bls.gov/registrationEngine/
api_key <- Sys.getenv("BLS_API_KEY") 

url <- 'https://api.bls.gov/publicAPI/v1/timeseries/data/'

payload <- glue(
  '{
    "seriesid": [
      "LNS14027659", "LNS14027660", "LNS14027689", "LNS14027662"
    ],
    "startyear": "2013",
    "endyear": "2022",
    "annualaverage": true,
    "registration_key": {{"api_key"}}
  }', .open="{{", .close="}}"
)

response <- POST(url,
                 body = payload,
                 content_type("application/json"),
                 encode="json"
)

json <- content(response, "text") %>% 
  jsonlite::fromJSON()

table <- data$Results$series$data[[1]] %>%
  as_tibble()

readr::write_csv(table, "unemployment_by_educational_attainment/data.csv")
