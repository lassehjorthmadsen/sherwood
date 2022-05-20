library(tidyverse)
library(httr)

# 24 hour token for simulation account
# https://www.developer.saxo/openapi/token/current#/lst/1650285935777
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiNTY2Zjk3NzUxNGExNGIwNjhlMTc5M2ZlOTU3MGVhZTQiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTE2NjMwMzUiLCJvYWwiOiIxRiJ9.FCuqIdSKC2f24tGluWr_GywcSmVf9SrkO8Le5HEuIz1HXjxcwKo2HhKZKuWrI2TeXgMErKYDyr-Czg4aGSVeNQ"
token24 <- paste("Bearer", token24)

# Basic request for balance
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/balances/me",
         add_headers(Authorization = token24))

content(r)$CashBalance

# available features
r <- GET("https://gateway.saxobank.com/sim/openapi/root/v1/features/availability",
         add_headers(Authorization = token24))
content(r)
content(r)[[1]]$Feature

# instrument prices
r <- GET("https://gateway.saxobank.com/sim/openapi/ref/V1/instruments/",
         query = list(top = "30", Keywords = "Apple", AssetTypes = "Stock"),
         add_headers(Authorization = token24))

http_status(r)
content(r)$Data %>% str()

df <- content(r)$Data %>%
  map_dfr(as_tibble) %>%
  mutate(TradableAs = map_chr(TradableAs, paste, collapse = ";"))

df

# Test POST reguest
r <- POST("https://gateway.saxobank.com/sim/openapi/root/v1/diagnostics/post")
http_status(r)

# test subscriptions
r <- POST("https://gateway.saxobank.com/sim/openapi/trade/v1/infoprices/subscriptions")
http_status(r)

# subscriptions
body <- list(Arguments =
               list("Uics" = "2047",
                 "AssetType" = "FxSpot"),
  ContextId = "explorer_1649365841278",
  ReferenceId = "C_419"
)

body <- jsonlite::toJSON(body, auto_unbox = T)

r <- POST("https://gateway.saxobank.com/sim/openapi/trade/v1/infoprices/subscriptions", body = body, encode = "raw")
http_status(r)


# Stock info prices:
r <- GET("https://gateway.saxobank.com/sim/openapi/ref/v1/instruments",
         query = list(AssetTypes = "Stock"), # Stock
         add_headers(Authorization = token24))

http_status(r)
df <- content(r)$Data %>% map_dfr(as_tibble)
df

Uics <- df %>%
  #slice_head(n = 3) %>%
  pull(Identifier) %>%
  paste(collapse = ",")

r <- GET("https://gateway.saxobank.com/sim/openapi/trade/v1/infoprices/list",
         query = list(AccountKey = "mM3WZ5aMVM|2gm5fOyrLkw==",
                      Uics = Uics,
                      AssetType = "Stock", # Stock
                      Amount = "1",
                      FieldGroups = "DisplayAndFormat",
                      Quote = TRUE),
         add_headers(Authorization = token24)
)

http_status(r)
content(r)$Data

content(r)$Data %>%
  map_dfr(~ map_dfc(.x, as_tibble)) %>%
  view("stocks")

# FX rates:
r <- GET("https://gateway.saxobank.com/sim/openapi/trade/v1/infoprices/list",
         query = list(AccountKey = "mM3WZ5aMVM|2gm5fOyrLkw==",
                      Uics = "21,42,10000",
                      AssetType = "FXSpot",
                      Amount = "100000",
                      FieldGroups = "Quote",
                      Quote = TRUE),
         add_headers(Authorization = token24)
         )

http_status(r)
content(r)$Data

prices <- content(r)$Data %>%
  map_dfr(~ map_dfc(.x, as_tibble)) %>%
  select(Uic = value...21, Symbol, Decimals, Amount, Bid, Ask, LastUpdated = value...8) %>%
  mutate(LastUpdated = lubridate::as_datetime(LastUpdated)) %>%
  arrange(Uic)

prices %>% view("FXSpot")
