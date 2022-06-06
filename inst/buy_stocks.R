# Demo snippets to buy stocks on sim environment

library(tidyverse)
library(httr)
devtools::load_all()

# 24 hour token for simulation account
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiM2U0Yzg1ODAwY2NkNDYyZTk5NDUwMGFiNDkyNWUwZjYiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTQ1NDgwMzQiLCJvYWwiOiIxRiJ9.Mm9UXQ61eVzT7mo6Ub-gHxefe3HNgXREk-RGYIfmAqTeuhZ8dHW5g3QYcLuI_oW8qWWXlSbKfrFPgjGu-3dcaw"
token24 <- paste("Bearer", token24)

# My default key
default_key <- get_client_info(token24) %>% slice_head(n = 1) %>% pull(DefaultAccountKey)

# All stocks from CSE, Copenhagen Stock Exchange
stocks <- get_instruments(token24, exchange_id = "CSE", asset_type = "Stock")

# Buy a random stock
random_uic <- stocks %>% slice_sample(n = 1) %>% pull(Data.Identifier)
place_order(token24, random_uic, "Buy", "Stock")

# Show orders, selected fields
get_orders(token24) %>% select(
  Data.AssetType,
  Data.BuySell,
  Data.OrderId,
  Data.OrderTime,
  Data.DisplayAndFormat.Description,
  Data.Exchange.Description
)

# Cancel latest order
ids <- get_orders(token24) %>% slice_head(n = 1) %>% pull(Data.OrderId) %>% paste(collapse = ",")
cancel_order(token = token24, account_key = default_key, order_ids = ids)
get_orders(token24, remove_constant_cols = T)

# Cancel all orders
cancel_all_orders(token = token24, account_key = default_key)
get_orders(token24, remove_constant_cols = T)
