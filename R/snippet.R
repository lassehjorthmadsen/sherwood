library(tidyverse)
library(httr)


eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiN2EzNjkyMjBhNGRjNDQwODkwM2ViZjI4NzcxZmY5YTUiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NDg0OTgxMDQiLCJvYWwiOiIxRiJ9.zakf7U-pb9K17LW1XERrsis4LxXkRnUqYvaWSqxe076QPjcejv2fdEOq1ktO_mO5zCckmbgx-Xrls0BLM2etvg

# copy your app configuration from https://www.developer.saxo/openapi/appmanagement
app_config <- list(
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
)

# Python snip
params = {
  "response_type": "code",
  "client_id": app_config["AppKey"],
  "state": state,
  "redirect_uri": app_config["RedirectUrls"][0],
  "client_secret": app_config["AppSecret"],
}

auth_url = requests.Request(
  "GET", url=app_config["AuthorizationEndpoint"], params=params
).prepare()

# in R?
params <- c(
  "response_type" = "code",
  "client_id" = "6a4e7a986bb349149689955cd9828770",
  # "state": state,
  "redirect_uri" = "http://www.lassehjorthmadsen.dk/",
  "client_secret"= "85055ce86c0848ebad36a2332557f3f7"
)

# The api responds
r <- POST("https://gateway.saxobank.com/sim/openapi/port/v1/users/me", params)
http_status(r)

params = '{
  "response_type": "code",
  "client_id": "6a4e7a986bb349149689955cd9828770",
  "redirect_uri": "http://www.lassehjorthmadsen.dk/",
  "client_secret": "85055ce86c0848ebad36a2332557f3f7",
}'

r <- POST("https://gateway.saxobank.com/sim/openapi/port/v1/users/me",
          body = params, encode = "raw")

http_status(r)

# Examine response
r
headers(r)
content(r)
str(content(r))
