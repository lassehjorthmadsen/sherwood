library(tidyverse)
library(httr)
library(devtools)
load_all()

# 24 hour token for simulation account
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiMTQ5MWY0ZjZmYmE3NGRjOWFjNWI0Y2E0MWJhODMwZWIiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTUzMjM4NTciLCJvYWwiOiIxRiJ9.Z0idU4PYNQnMJf8iDLnDLZDQsgLG1An_lKsSEV_JOE0gxd8WuRnAA8YjXw5Kunib100vU32UhHSYGXqlbuzCOg"
token24 <- paste("Bearer", token24)

# Authorization flow
# https://github.com/r-lib/httr/blob/main/demo/oauth2-github.r
saxo <- oauth_endpoint(authorize = "authorize",
                       access = "token",
                       base_url = "https://live.logonvalidation.net")

# Use: file.edit("~/.Renviron")
myapp <- oauth_app(appname = "sherwood",
                   key = Sys.getenv("sherwood_key"),
                   secret = Sys.getenv("sherwood_secret"))

my_token <- oauth2.0_token(saxo, myapp, cache = FALSE)
my_token <- oauth2.0_token(saxo, myapp, cache = TRUE)

# Get this to work (now fail also because of sim endpoint)
get_client_info(token = my_token)
get_balance(token = my_token)

# Works finally for live and sim environments
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/balances/me",
         httr::add_headers(Authorization = token24))

http_status(r)
content(r)$CashBalance

r <- GET("https://gateway.saxobank.com/openapi/port/v1/balances/me",
         config = my_token)

http_status(r)
content(r)$CashBalance


# Get the details about a user, like LastLoginStatus, works on sim
r <- GET("https://gateway.saxobank.com/openapi/port/v1/users/me",
         config = my_token)

http_status(r)
content(r)
content(r)$UserKey == content(r)$ClientKey # Identical
content(r)$LastLoginStatus
content(r)$LastLoginTime %>% lubridate::as_datetime()
Sys.time() %>% lubridate::as_datetime()
content(r)$MarketDataViaOpenApiTermsAccepted # Need to fix?
content(r)$Name
content(r)$UserKey

# Get the details about logged-in user's client
r <- GET("https://gateway.saxobank.com/openapi/port/v1/clients/me",
         config = my_token)

http_status(r)
content(r)

