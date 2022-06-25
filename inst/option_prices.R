# Snippets for getting option prices

library(httr)
library(tidyverse)
library(jsonlite)
devtools::load_all()

# Token for live environment
my_token <- authorize_live()

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

# 3. Use root id to get option space from contractoptionspaces end point. Try option root = 572 :
specific_options <-
  get_optionspace(
    token = my_token,
    live = TRUE,
    client_key = client_key,
    option_root_id = root_id
  )

# 4. Set up price subscription for example option
example_option_uic <- specific_options %>%
  filter(TradingStatus == "Tradable", PutCall == "Call") %>%
  slice_head(n = 1) %>%
  pull(Uic)

prices <-
  make_subscription(
    token = my_token,
    live = TRUE,
    uic = example_option_uic,
    asset_type = "StockOption"
  )

option <- specific_options %>%
  inner_join(prices, by = c("Uic" = "Snapshot.Uic"))

stock <- get_info_prices(token = my_token, live = TRUE, uics = option$UnderlyingUic)

option <- option %>% left_join(stock, by = c("Uic" = "Data.Uic"))

option %>% select(
  Uic,
  UnderlyingUic,
  PutCall,
  StrikePrice,
  Expiry,
  Snapshot.AssetType,
  Snapshot.Commissions.CostBuy,
  Snapshot.PriceInfoDetails.Open,
  Snapshot.PriceInfoDetails.Volume,
  Snapshot.PriceInfoDetails.Open
  ) %>%
  glimpse()


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
