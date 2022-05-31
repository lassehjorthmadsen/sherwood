# A go at fetching option prices -- after
# connecting dev account to live account

library(tidyverse)
library(httr)
devtools::load_all()

# 24 hour token for simulation account
# https://www.developer.saxo/openapi/token/current#/lst/1650285935777
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiODY2YTJkZjYyNDdjNDc5MGE4YTIzZjZkOWRhNWQ4ZGEiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTQxMTQ0MDgiLCJvYWwiOiIxRiJ9.L-PD61_5wqqi6tR1mTF0X7htFF008OPYpXsKpuTt9IMSHOGfYg5e1Zf3t1NTHe7nw69CGido52zhvNaojZIJVQ"
token24 <- paste("Bearer", token24)

# EUREX: Largest European futures and options market
# OPRA: Options Price Reporting Authority for US

# Ref:
# https://www.developer.saxo/openapi/learn/reference-data?phrase=contractoptionspaces

# 1. Get list of options via instruments end point
opt <- get_instruments(token24, exchange_id = "EUREX", asset_type = "StockOption", remove_constant_cols = F)

# 2. Identifier field will contain Option Root ID (collection of related options)
root_id <- opt %>% filter(str_detect(Data.Description, "Heidelberger Cement AG")) %>% pull(Data.Identifier)

# 3. Use root id to get option space from contractoptionspaces end point. Try option root = 572 :
# Option space can be huge, so limit using OptionSpaceSegment parameter (how does that work, exactly?)
r <- GET("https://gateway.saxobank.com/sim/openapi/ref/v1/instruments/contractoptionspaces/572",
         query = list(ClientKey = "mM3WZ5aMVM|2gm5fOyrLkw==",
                      OptionSpaceSegment = "DefaultDates",
                      UnderlyingUic = "1"
         ),
         add_headers(Authorization = token24)
)

http_status(r)

# 4. Examine response to find the option we need.
specific_options <- r %>%
  content() %>%
  pluck("OptionSpace") %>%
  map(pluck, "SpecificOptions") %>%
  bind_rows() %>%
  filter(PutCall == "Call", TradingStatus == "Tradable")

uics <- paste(specific_options$Uic, collapse = ",")

prices <- get_info_prices(token = token24, uics = uics, asset_type = "StockOption", remove_constant_cols = F)

prices %>% glimpse()
prices %>% view("prices")

sch <- get_schedule(token = token24, uic = "18094550", asset_type = "StockOption", remove_constant_cols = F)

# To do:
# Understand option space
# Understand OptionSpaceSegment parameter
# Try optionchain endpoint
