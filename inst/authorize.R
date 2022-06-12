library(tidyverse)
library(httr)
library(devtools)
load_all()

# 24 hour token for simulation account
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiMzIxNmRiMDdjZWE2NGJhNTgyMjU5NTFlOGYxYmE5NTYiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTQ4MDc0OTciLCJvYWwiOiIxRiJ9.UUCetlU5xi8qMCpowlqDLNJe0zf9nYcoTGm2YlUYN59cOmsHsHo2qo-mpOQECC2MWhSTyvtOfvu_EmFGm52fIg"
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

# get_client_info(token = my_token$credentials$access_token)
