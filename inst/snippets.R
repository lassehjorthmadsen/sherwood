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


# Try to get stock option prices (InfoPrices, https://www.developer.saxo/openapi/learn/pricing)
# First, get all StockOption types
r <- GET("https://gateway.saxobank.com/sim/openapi/ref/v1/instruments",
         query = list(AssetTypes = "StockOption"),
         add_headers(Authorization = token24))

http_status(r)
df <- content(r)$Data %>% map_dfr(as_tibble)
df

Uics <- df %>%
  #slice_head(n = 3) %>%
  pull(Identifier) %>%
  paste(collapse = ",")

# GET THIS TO WORK
# Then, try to get a few prices for those:
r <- GET("https://gateway.saxobank.com/sim/openapi/trade/v1/infoprices/list",
         query = list(AccountKey = "mM3WZ5aMVM|2gm5fOyrLkw==",
                      Uics = Uics,
                      AssetType = "StockOption",
                      Amount = "1",
                      FieldGroups = "DisplayAndFormat",
                      Quote = TRUE,
                      PutCall = "Call"), # Required?),
         add_headers(Authorization = token24)
)

http_status(r)
content(r)$Data

# The above seems to work for stocks, like this:
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

# This works too, for FX:
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

# This also returns an empty list. All parameter example from
# https://www.developer.saxo/openapi/referencedocs/trade/v1/infoprices/getinfopricelistasync/2eaaceb6373a7eff36c5f04f345cabe0

r <-
  GET(
    "https://gateway.saxobank.com/sim/openapi/trade/v1/infoprices/list",
    query = list(
      Uics = "22,23",
      AccountKey = "mM3WZ5aMVM|2gm5fOyrLkw==",
      AssetType = "FuturesOption",
      # Amount = "45182985752.759308",
      # ForwardDate = "2021-09-17T20:42:25.610734Z",
      # ExpiryDate = "2022-08-05T14:16:28.445831Z",
      # StrikePrice = "-6.3319863291243844E+22",
      # OrderAskPrice = "-3.3795401359503469E+17",
      # OrderBidPrice = "-6.6779484960120688E+21",
      # LowerBarrier = "4.7868170226202995E+28",
      # UpperBarrier = "-5.6102223519559008E+17",
      PutCall = "Put",
      FieldGroups = "PriceInfo",
      # AmountType = "CashAmount",
      # ForwardDateNearLeg = "2021-05-28T10:49:35.815166Z",
      # ForwardDateFarLeg = "2022-01-01T12:40:08.973058Z",
      ToOpenClose = "Undefined",
      QuoteCurrency = TRUE
    ),
    add_headers(Authorization = token24)
  )

http_status(r)  # OK, but ...
content(r)$Data # ... empty

# Tesla:
r <- GET("https://gateway.saxobank.com/sim/openapi/trade/v1/infoprices",
         query = list(AccountKey = "mM3WZ5aMVM|2gm5fOyrLkw==",
                      Uic = "47556",
                      AssetType = "Stock"),
         add_headers(Authorization = token24)
)

http_status(r)
content(r) %>% map(as_tibble)
content(r)[1]


# Fx prices, from here: https://www.developer.saxo/openapi/tutorial#/7
r <- GET("https://gateway.saxobank.com/sim/openapi/trade/v1/infoprices/list",
         query = list(AccountKey = "mM3WZ5aMVM|2gm5fOyrLkw==",
                      Uics = "2047,1311,2046,17749,16",
                      AssetType = "FxSpot",
                      Amount = "100000",
                      FieldGroups = "DisplayAndFormat",
                      Quote = TRUE),
         add_headers(Authorization = token24)
         )

http_status(r)
content(r)$Data %>% str()

df <- content(r)$Data %>%
  map_dfr(~ map_dfc(.x, as_tibble)) %>%
  select(Uic = value...21, Symbol, Decimals, Amount, Bid, Ask, LastUpdated = value...8) %>%
  mutate(LastUpdated = lubridate::as_datetime(LastUpdated)) %>%
  arrange(Uic)

df


# Setup subscription -- doesn't work, only for live env?
body <- list(
  Arguments = list(
    AccountKey = "mM3WZ5aMVM|2gm5fOyrLkw==",
    AssetType = "StockIndexOption",
    Identifier = 18,
    MaxStrikesPerExpiry = 3
  ),
  ContextId = "20220331032319399",
  ReferenceId = "C0101093"
)

body <- jsonlite::toJSON(body, auto_unbox = T)

r <- POST("https://gateway.saxobank.com/sim/openapi/trade/v1/optionschain/subscriptions", body = body, encode = "raw")

content(r) %>% str()
