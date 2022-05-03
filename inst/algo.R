library(tidyverse)
library(httr)
devtools::load_all()

# 24 hour token for simulation account
# https://www.developer.saxo/openapi/token/current#/lst/1650285935777
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiNTY2Zjk3NzUxNGExNGIwNjhlMTc5M2ZlOTU3MGVhZTQiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTE2NjMwMzUiLCJvYWwiOiIxRiJ9.FCuqIdSKC2f24tGluWr_GywcSmVf9SrkO8Le5HEuIz1HXjxcwKo2HhKZKuWrI2TeXgMErKYDyr-Czg4aGSVeNQ"
token24 <- paste("Bearer", token24)

cse <- get_cse_stocks(token24)
uics <- paste(cse$Data.Identifier, collapse = ",")
prc <- get_info_prices(token = token24, uics = uics)
detail <- get_info_detail(token = token24, uics = uics)
