library(tidyverse)
library(httr)
library(devtools)
load_all()

# 24 hour token for simulation account
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiMzNiODIyZjRiMzFhNDJjMDhkYTNlNjAwNGUzNTg0YzciLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTUzNjgzODMiLCJvYWwiOiIxRiJ9.8EYSo7H--fkGLx0SdOzAZwA0GM32ylk3nI1I0gi34G0baGUFZsUCcAxdatKCA8Yld3GwvOmTSYEGO-Lpu_7_ig"
token24 <- paste("Bearer", token24)

my_token <- authorize_live()

# Live
r <- GET("https://gateway.saxobank.com/openapi/port/v1/balances/me",
         config = my_token)

http_status(r)
content(r)$CashBalance

# Sim
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/balances/me",
         httr::add_headers(Authorization = token24))

http_status(r)
content(r)$CashBalance


# Get this to work (fail because of sim endpoint)
get_client_info(token = my_token)
get_balance(token = my_token)

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

