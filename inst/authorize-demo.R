library(tidyverse)
library(httr)
library(devtools)
load_all()

# 24 hour token for simulation account
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiYzRmNTNiZDAyOGQ5NDgyMzg0OGVkNmJkZmExOWE0N2YiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTU0NjM1MDgiLCJvYWwiOiIxRiJ9.37-_MRk3jyi4gsMIIqO_OP62TjUxD_FiXqn69_XlT06hLLnjbW8kq-38D6WYVK-uQQhN3BNTvaOE0DJpSBcmfg"
token24 <- paste("Bearer", token24)

my_token <- authorize_live()

# client info
ci <- get_client_info(token = my_token, live = TRUE)
ci_sim <- get_client_info(token = token24)

# account info
ai <- get_account_info(token = my_token, live = TRUE)
ai_sim <- get_account_info(token = token24)

# exchanges
ex <- get_exchanges(token = my_token, live = TRUE)
ex_sim <- get_exchanges(token = token24)

# instruments
ins <- get_instruments(token = my_token, live = TRUE)
ins_sim <- get_instruments(token = token24)

# info prices
uics = ins$Data.Identifier %>% paste(collapse = ",")
ip <- get_info_prices(token = my_token, live = TRUE, uics = uics)
ip_sim <- get_info_prices(token = token24, live = FALSE, uics = uics)

# price details
de <- get_details(token = my_token, live = TRUE, uics = uics)
de_sim <- get_details(token = token24, live = FALSE, uics = uics)

# trade schedule
uic = ins$Data.Identifier[1]
sc <- get_schedule(token = my_token, live = TRUE, uic = uic)
sc_sim <- get_schedule(token = token24, live = FALSE, uic = uic)

# my orders
or <- get_orders(token = my_token, live = TRUE)
or_sim <- get_orders(token = token24, live = FALSE)

# balance
get_balance(token = my_token, live = TRUE)
get_balance(token = token24, live = FALSE)

# place order
# LIVE: A bit careful with real money; see buy_stock.R snippet
# SIM:
po <- place_order(
  token = token24,
  live = FALSE,
  uic = uic,
  buy_sell = "Buy",
  asset_type = "Stock",
  order_type = "Limit",
  order_price = 150
)

# cancel order
# cancel_order(token = my_token, live = TRUE)
ids <- get_orders(token = token24, live = FALSE) %>% slice_head(n = 1) %>% pull(Data.OrderId) %>% paste(collapse = ",")
cancel_order(token = token24, live = FALSE, account_key = ci_sim$DefaultAccountKey[1], order_ids = ids)

# cancel all orders
cancel_all_orders(token = token24, live = FALSE, account_key = ci_sim$DefaultAccountKey[1])
