library(tidyverse)
library(httr)

# 24 hour token for simulation account
# https://www.developer.saxo/openapi/token/current#/lst/1650285935777
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiNzkzNTM2OGEzMzc0NGYxMjllYTE4NzUxZDFhZWMyNzgiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTA4NzM1ODEiLCJvYWwiOiIxRiJ9.B1TSVo6Lq4YznklMfVZXzcClmA0mUaqDXeKjJlxUH10eQuTtM_usNdGTiO0GYewa7krLXRN0HitvA6vln-xh4A"
token24 <- paste("Bearer", token24)

cse <- get_cse_stocks(token24)
uics <- paste(cse$Identifier, collapse = ",")
prc <- get_info_prices(token = token24, uics = uics)
detail <- get_info_detail(token = token24, uics = uics)
