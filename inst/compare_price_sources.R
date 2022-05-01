library(tidyverse)
library(httr)
library(quantmod)
devtools::load_all()


# 24 hour token for simulation account
# https://www.developer.saxo/openapi/token/current#/lst/1650285935777
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiMDBjNTFjODUwMDk1NDJhZmI4NjlkOGNkMjZmYjMwNTciLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTE0OTUxMjkiLCJvYWwiOiIxRiJ9.VmgbAjEyftBXRjFzB_43TtCHmsbgf3cksgSGzE9IyPp7tNAMPtWJlxTFf7qaqk1MrU8NWeiXRMUXDCal3FblYQ"
token24 <- paste("Bearer", token24)

# Basic request for balance
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/balances/me",
         add_headers(Authorization = token24))

http_status(r)

cse <- get_cse_stocks(token24)
uics <- paste(cse$Data.Identifier, collapse = ",")
prc <- get_info_prices(token = token24, uics = uics)

# Novo example
mPrice <- getSymbols("NOVO-B.CO",
                     from = Sys.Date(),
                     to = Sys.Date(),
                     auto.assign = FALSE)
