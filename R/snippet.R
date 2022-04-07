library(tidyverse)
library(httr)

# 24 hour token for simulation account
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiZGVkOGNhOTNjOThiNDM3ZjhhZTNmNWIyYTgxOThmZTgiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NDk0NTExOTIiLCJvYWwiOiIxRiJ9.026_QpW0A4ohNFz8LUyWvXs9XbyJE5-kmoYOEDT6R8RqoaUk3QMgZphPAIfpXtbZeDDGQl-CYsKjIItaf04gEw"
token24 <- paste("Bearer", token24)

# Basic request for balance
r <-
  GET(
    "https://gateway.saxobank.com/sim/openapi/port/v1/balances/me",
    add_headers(Authorization = token24)
    )

# Examine content
http_status(r)

headers(r)
content(r)
str(content(r))
content(r)$CashBalance

# Balance with keys
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/balances",
         query = list(AccountKey = "mM3WZ5aMVM|2gm5fOyrLkw==",
                      ClientKey = "mM3WZ5aMVM|2gm5fOyrLkw=="),
         add_headers(Authorization = token24))

http_status(r)
content(r)$CashBalance

# User details
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/users/me",
         add_headers(Authorization = token24))

http_status(r)
content(r)

r <- GET("https://gateway.saxobank.com/sim/openapi/root/v1/user",
         add_headers(Authorization = token24))

http_status(r)
content(r)


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
content(r) %>% str()
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



# Option prices

# 1) setup subscription

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

http_status(r)
content(r) %>% str()



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

# Keys
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/accounts/me",
         add_headers(Authorization = token24))

http_status(r)
content(r)$Data[[1]]$AccountKey
content(r)$Data[[1]]$ClientKey


# App object
{
  "AppName": "sherwood",
  "AppKey": "6a4e7a986bb349149689955cd9828770",
  "AuthorizationEndpoint": "https://sim.logonvalidation.net/authorize",
  "TokenEndpoint": "https://sim.logonvalidation.net/token",
  "GrantType": "Code",
  "OpenApiBaseUrl": "https://gateway.saxobank.com/sim/openapi/",
  "RedirectUrls": [
    "http://www.lassehjorthmadsen.dk/"
  ],
  "AppSecret": "85055ce86c0848ebad36a2332557f3f7"
}


# How to use parameters?
params = '{
  "response_type": "code",
  "client_id": "6a4e7a986bb349149689955cd9828770",
  "redirect_uri": "http://www.lassehjorthmadsen.dk/",
  "client_secret": "85055ce86c0848ebad36a2332557f3f7",
}'

r <- POST("https://gateway.saxobank.com/sim/openapi/port/v1/users/me",
          body = params, encode = "raw")

http_status(r)
