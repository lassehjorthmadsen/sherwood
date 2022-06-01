# Snippets to buy stocks on sim environment

library(tidyverse)
library(httr)
devtools::load_all()

# 24 hour token for simulation account
# https://www.developer.saxo/openapi/token/current#/lst/1650285935777
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiODY2YTJkZjYyNDdjNDc5MGE4YTIzZjZkOWRhNWQ4ZGEiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTQxMTQ0MDgiLCJvYWwiOiIxRiJ9.L-PD61_5wqqi6tR1mTF0X7htFF008OPYpXsKpuTt9IMSHOGfYg5e1Zf3t1NTHe7nw69CGido52zhvNaojZIJVQ"
token24 <- paste("Bearer", token24)

stc <- get_instruments(token24, exchange_id = "CSE", asset_type = "Stock")

random_stock <- stc %>% slice_sample(n = 1)
random_uic <- random_stock %>% pull(Data.Identifier)

prc <- get_info_prices(token24, uics = random_uic)

r <-
  httr::POST(
    "https://gateway.saxobank.com/sim/openapi/trade/v2/orders",
    body = list(
      "Uic" = random_uic,
      "BuySell" = "Buy",
      "AssetType" = "Stock",
      "Amount" = 1,
      "AmountType" = "Quantity",
      "OrderPrice" = 7,
      "OrderType" = "Market",
      "OrderRelation" = "StandAlone",
      "ManualOrder" = TRUE
    ),
    config = httr::add_headers(Authorization = token24),
    encode = "form"
  )

http_status(r)
get_orders(token24) %>% view()
