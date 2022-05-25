# A go at fetching option prices -- after
# connecting dev account to live account

library(tidyverse)
library(httr)
devtools::load_all()
theme_set(theme_minimal())

# 24 hour token for simulation account
# https://www.developer.saxo/openapi/token/current#/lst/1650285935777
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiZWY4MWZmNWEyMDcwNDk2YjkxZjBiZjRhNWVhZDA4MGEiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTM1NzA0NDEiLCJvYWwiOiIxRiJ9.hwllV12gTz57U4izCkOOGy75KvhoQeO8XubkGCzNdSWQ8Uc_vo6RGMKZLZOy2eoY2T7gMPDR3a92O6qRvN1j_g"
token24 <- paste("Bearer", token24)

# EUREX: Largest European futures and options market
# OPRA: Options Price Reporting Authority for US
opt <- get_assets(token24, exchange_id = "EUREX", asset_type = "StockOption", remove_constant_cols = F)

uics <- opt$Data.Identifier %>% head(5) %>% paste0(collapse = ",")

prc <- get_info_prices(token24, uics = uics, asset_type = "StockOption")


# try this
# 1. Get list of options like in opt above
# 2. Get uics from those
# 3. Get optionRootIds for those, as explained here:
# https://openapi.help.saxo/hc/en-us/articles/4417056831633-How-do-I-find-the-OptionRootId-for-an-option-
# 4. Then, get option root info including price(?) like below:

# Detailed information about option root (optionRootId = 7) :
r2 <- GET("https://gateway.saxobank.com/sim/openapi/ref/v1/instruments/contractoptionspaces/7",
         query = list(ClientKey = "mM3WZ5aMVM|2gm5fOyrLkw=="), # How to pass OptionRouteId to call? Not like this
         add_headers(Authorization = token24)
)

http_status(r2)
content(r2)
response_df(r2)

df <- r2 %>%
  httr::content(as = "text") %>%
  jsonlite::fromJSON(flatten = T) %>%
  as.data.frame() %>% # Breaks here, complex response at this end point
  dplyr::as_tibble() %>%
  dplyr::mutate(dplyr::across(dplyr::ends_with("LastUpdated"), lubridate::as_datetime))

df$RelatedInstruments

