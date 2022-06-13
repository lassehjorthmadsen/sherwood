library(tidyverse)
library(httr)
library(devtools)
load_all()

# 24 hour token for simulation account
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiMjllYjQ1YzhiMzY4NGUxMTgyNTE0Y2U1YmVmMDJiZWQiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTUyMDM5NTMiLCJvYWwiOiIxRiJ9.m3QP3chYLl14WUeca65_fj14qdQ-1KTdTRl121r3JDGpIwMDyAbVSKVQI7NfiQlgZSfTVklaOxKh7sMHoSZocw"
token24 <- paste("Bearer", token24)

# Authorization flow
# https://github.com/r-lib/httr/blob/main/demo/oauth2-github.r
saxo <-
  oauth_endpoint(authorize = "authorize",
                 access = "token",
                 base_url = "https://live.logonvalidation.net")

myapp <- oauth_app(appname = "sherwood",
                   key = AppKey,
                   secret = AppSecret)

my_token <- oauth2.0_token(saxo, myapp, cache = TRUE)
token <- my_token$credentials$access_token

# Get this to work (now fail also because of sim endpoint)
get_client_info(token = token24)
get_client_info(token = token)

get_balance(token = token24)
get_balance(token = token)
get_instruments(token = paste("Bearer", token))


# Works, with or without headers. If given, token needn't be correct
r <- GET("https://gateway.saxobank.com/openapi/root/v1/diagnostics/get")

r <- GET("https://gateway.saxobank.com/openapi/root/v1/diagnostics/get",
         add_headers(Authorization = "token"))
http_status(r)


# Works on sim, not on live
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/balances/me",
         httr::add_headers(Authorization = token24))

r <- GET("https://gateway.saxobank.com/openapi/port/v1/balances/me",
         add_headers(Authorization = token))

r <- GET("https://gateway.saxobank.com/openapi/port/v1/balances/me",
         add_headers(Authorization = paste("Bearer", token)))

http_status(r)
content(r)$CashBalance

# Try not using /me endpoint. Works
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/balances/?ClientKey=mM3WZ5aMVM|2gm5fOyrLkw==",
         httr::add_headers(Authorization = token24))

http_status(r)
content(r)$CashBalance

# Get the details about a user, like LastLoginStatus, works on sim
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/users/mM3WZ5aMVM|2gm5fOyrLkw==",
         add_headers(Authorization = token24))

http_status(r)
content(r)
content(r)$UserKey == content(r)$ClientKey # Identical
content(r)$LastLoginStatus
content(r)$LastLoginTime %>% lubridate::as_datetime()
Sys.time() %>% lubridate::as_datetime()

# Get the details about a *client*, like LastLoginStatus, rights, works on sim
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/clients/mM3WZ5aMVM|2gm5fOyrLkw==",
         add_headers(Authorization = token24))

http_status(r)
content(r)






# Get UserKey, on live: "Client error: (401) Unauthorized"
r <- GET("https://gateway.saxobank.com/openapi/port/v1/users/me",
         add_headers(Authorization = token))

http_status(r)

content(r)$Name
content(r)$UserKey





r <- GET("https://gateway.saxobank.com/openapi/port/v1/clients/me",
         add_headers(Authorization = token))

http_status(r)
content(r)$CashBalance

https://gateway.saxobank.com/sim/openapi/port/v1/balances/?ClientKey={ClientKey}&AccountGroupKey={AccountGroupKey}&AccountKey={AccountKey}&FieldGroups={FieldGroups}
