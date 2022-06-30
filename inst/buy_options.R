# Demo snippet to buy stock options on live environment

library(httr)
library(tidyverse)
library(jsonlite)
devtools::load_all()

# Token for live environment
my_token <- authorize_live()

# 24 hour token for simulation account
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiYTA3NDY2ZmJlZTQzNDkxOGI3ZWFjOTA4NDBjMjdjNjQiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTY2NjcyMjQiLCJvYWwiOiIxRiJ9.RTjjckpHQyfHqa9Vib397VpwXCZjmm42qAXygBpdZqcBO_EOIk2KfY45_azLIbCwrzNc0swC8vhl0LoxD1OOSw"
token24 <- paste("Bearer", token24)

# My info
my_info <- get_client_info(token = my_token, live = TRUE)

# My default key
client_key <- my_info$ClientKey[1]

# EUREX: Largest European futures and options market
# OPRA: Options Price Reporting Authority for US

# Ref:
# https://www.developer.saxo/openapi/learn/reference-data?phrase=contractoptionspaces

# 1. Get list of options via instruments end point
opt <- get_instruments(token = my_token, live = TRUE, exchange_id = "EUREX", asset_type = "StockOption")

# 2. Identifier field will contain Option Root ID (collection of related options). E.g.:
root_id <- opt %>% filter(str_detect(Data.Description, "Heidelberger Cement AG")) %>% pull(Data.Identifier)
opt %>% filter(Data.Identifier == root_id) %>% glimpse()

# 3. Use root id to get option space from contractoptionspaces end point. Try option root = 572 :
specific_options <-
  get_optionspace(
    token = my_token,
    live = TRUE,
    client_key = client_key,
    option_root_id = root_id
  )

# 4. Check price for underlying instrument ("Heidelberger Cement AG")
# Sanity check: one root_id will have only one underlying instrument, right?
n_distinct(specific_options$UnderlyingUic)

underlying_uic <- specific_options$UnderlyingUic[1]

underlying_infoprice <- get_info_prices(token = my_token, live = TRUE, uics = underlying_uic)
underlying_infoprice %>% glimpse()
approx_price <- underlying_infoprice$Data.Quote.Mid %>% round()

# 5. Set up price subscription for example option
example_option_uic <- specific_options %>%
  filter(TradingStatus == "Tradable", PutCall == "Call", StrikePrice == approx_price) %>%
  slice_min(Expiry) %>%
  pull(Uic)

prices <-
  make_subscription(
    token = my_token,
    live = TRUE,
    uic = example_option_uic,
    asset_type = "StockOption"
  )

prices %>% glimpse()

option <- specific_options %>%
  inner_join(prices, by = c("Uic" = "Snapshot.Uic")) %>%
  left_join(underlying_infoprice, by = c("UnderlyingUic" = "Data.Uic"))

option %>% select(
  Uic,
  UnderlyingUic,
  Data.DisplayAndFormat.Description,
  PutCall,
  StrikePrice,
  Expiry,
  Snapshot.AssetType,
  Snapshot.Commissions.CostBuy,
  Snapshot.PriceInfoDetails.Open,
  Snapshot.PriceInfoDetails.Volume
  ) %>%
  glimpse()

# 6. Place order
place_order(
  token = token24,
  live = FALSE,
  uic = example_option_uic,
  buy_sell = "Buy",
  asset_type = "StockOption",
  order_type = "Limit",
  order_price = 2.4,
  to_open_close = "ToOpen"
)

sim_orders <- get_orders(token = token24, live = FALSE)
sim_orders %>% glimpse()

# Cancel latest order
latest_id <- sim_orders %>% slice_max(Data.OrderTime) %>% pull(Data.OrderId)
latest_AccountKey <- sim_orders %>% slice_max(Data.OrderTime) %>% pull(Data.AccountKey)

cancel_order(token = token24, live = FALSE, account_key = latest_AccountKey, order_ids = latest_id)

cancel_all_orders(token = token24, live = FALSE, account_key = account_key)




# 6. Use optionschain endpoint
body <- list(
  "Arguments" = list("AssetType" = "StockOption",
                     "Identifier" = root_id),
  "ContextId" = context_id,
  "ReferenceId" = reference_id
)


r <- POST("https://gateway.saxobank.com/openapi/trade/v1/optionschain/subscriptions",
          body = jsonlite::toJSON(body),
          config = my_token,
          encode = "form"
          )

r <- POST("https://gateway.saxobank.com/openapi/trade/v1/optionschain/subscriptions",
          body = jsonlite::toJSON(body),
          config = my_token,
          encode = "json"
)

r <- POST("https://gateway.saxobank.com/openapi/trade/v1/optionschain/subscriptions",
          body = body,
          config = my_token,
          encode = "form"
)


http_status(r)
