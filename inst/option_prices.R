# A go at fetching option prices -- after
# connecting dev account to live account

library(tidyverse)
devtools::load_all()
theme_set(theme_minimal())

# 24 hour token for simulation account
# https://www.developer.saxo/openapi/token/current#/lst/1650285935777
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiZWMxNGJmNTdiZjczNGJhMWIyMmY2M2ViNGI4ZDk1ODciLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTMxMzcxNDAiLCJvYWwiOiIxRiJ9.UDO2G61nrE7cQ8pn48nBhTyIxzWv3p9IuNsh0hUV51Azj2eVOt_Mg0L5bjJ06ZZtdNanlqQY2MXALlgXkcExXw"
token24 <- paste("Bearer", token24)

# EUREX: Largest European futures and options market
# OPRA: Options Price Reporting Authority for US
opt <- get_assets(token24, exchange_id = "EUREX", asset_type = "StockOption", remove_constant_cols = F)

uics <- opt$Data.Identifier %>% head(5) %>% paste0(collapse = ",")

prc <- get_info_prices(token24, uics = uics, asset_type = "StockOption")


# https://openapi.help.saxo/hc/en-us/articles/4417056831633-How-do-I-find-the-OptionRootId-for-an-option-

# Detailed information about option root:
r2 <- GET("https://gateway.saxobank.com/sim/openapi/ref/v1/instruments/contractoptionspaces/7",
         query = list(ClientKey = "mM3WZ5aMVM|2gm5fOyrLkw=="), # How to pass OptionRouteId to call? Not like this
         add_headers(Authorization = token24)
)

http_status(r2)
content(r)
response_df(r)

df <- r2 %>%
  httr::content(as = "text") %>%
  jsonlite::fromJSON(flatten = T) %>%
  as.data.frame() %>% # Breaks here, complex response at this end point
  dplyr::as_tibble() %>%
  dplyr::mutate(dplyr::across(dplyr::ends_with("LastUpdated"), lubridate::as_datetime))

df$RelatedInstruments
