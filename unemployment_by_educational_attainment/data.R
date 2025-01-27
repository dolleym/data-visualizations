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
    "startyear": "2015",
    "endyear": "2024",
    "registration_key": "{{api_key}}"
  }', .open="{{", .close="}}"
)

response <- POST(url,
                 body = payload,
                 content_type("application/json"),
                 encode="json"
)

json <- content(response, "text") %>% 
  jsonlite::fromJSON()


assemble <- lapply(1:4, function(series){
  table <- json$Results$series$data[[series]] %>%
    as_tibble() %>% 
    mutate(
      seriesid = case_when(
        series == 1 ~ 'LNS14027659',
        series == 2 ~ 'LNS14027660',
        series == 3 ~ 'LNS14027689',
        series == 4 ~ 'LNS14027662'
      ),
      seriesname = case_when(
        series == 1 ~ 'Less than a High School Diploma',
        series == 2 ~ 'High School Graduates No College',
        series == 3 ~ 'Some College or Associate Degree ',
        series == 4 ~ "Bachelor's Degree and Higher"
      ) 
    )
}) %>% bind_rows()


readr::write_csv(assemble, "unemployment_by_educational_attainment/data.csv")

chart_dta <- readr::read_csv("unemployment_by_educational_attainment/data.csv") %>% 
  group_by(
    year, 
    seriesname
  ) %>% 
  summarise(
    annual_avg = mean(value)
  )
  


