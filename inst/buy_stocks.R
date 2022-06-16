# Demo snippet to buy stocks on live environment

library(tidyverse)
devtools::load_all()

# Token for live environment
my_token <- authorize_live()

# My info
my_info <- get_client_info(token = my_token, live = TRUE)

# My default key
account_key <- my_info$DefaultAccountKey[1]

# All stocks from CSE, Copenhagen Stock Exchange
stocks <- get_instruments(token = my_token, live = TRUE, exchange_id = "CSE", asset_type = "Stock")

# Info prices
uics = stocks$Data.Identifier %>% paste(collapse = ",")
infop <- get_info_prices(token = my_token, live = TRUE, uics = uics)
infop_sim <- get_info_prices(token = token24, live = FALSE, uics = uics)

# Buy a cheap stock
infop_sim %>%
  arrange(Data.Quote.Mid) %>%
  select(Data.DisplayAndFormat.Description,
         Data.DisplayAndFormat.Symbol,
         Data.AssetType,
         Data.Uic,
         Data.Quote.Mid,
         Data.Quote.MarketState)

place_order(
  token = my_token,
  live = TRUE,
  uic = 2664,
  buy_sell = "Buy",
  asset_type = "Stock",
  order_type = "Limit",
  order_price = 0.4
)

# Show orders, selected fields
my_orders <- get_orders(token = my_token, live = TRUE) %>%
  select(
    AssetType = Data.AssetType,
    BuySell = Data.BuySell,
    OrderId = Data.OrderId,
    OrderTime = Data.OrderTime,
    AccountKey = Data.AccountKey,
    Description = Data.DisplayAndFormat.Description,
    Exchange = Data.Exchange.Description
  )

my_orders

# Cancel latest order
latest_id <- my_orders %>% slice_max(OrderTime) %>% pull(OrderId)
latest_AccountKey <- my_orders %>% slice_max(OrderTime) %>% pull(AccountKey)

cancel_order(token = my_token, live = TRUE, account_key = latest_AccountKey, order_ids = latest_id)

get_orders(token = my_token, live = TRUE, remove_constant_cols = F) %>% glimpse()

# Cancel all orders
cancel_all_orders(token = my_token, live = TRUE, account_key = account_key)
get_orders(token = my_token, live = TRUE)
