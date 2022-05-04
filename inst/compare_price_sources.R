# As a sanity check, this compare stock prices from
# Copenhagen Stock Exchange, CSE, obtained from Saxo
# Bank with same stock prices from Yahoo Finance.

library(tidyverse)
library(httr)
library(quantmod)
devtools::load_all()

# 24 hour token for simulation account
# https://www.developer.saxo/openapi/token/current#/lst/1650285935777
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiMzg3MTY2ZTA1ZTFiNDJhYjg5MWM1MWQ5ZWRkZGU4ZWQiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTE3MzY4MDYiLCJvYWwiOiIxRiJ9.Elfir5XXdxqIa1_HoMsFcoqKji-yPrxkYGMtM_2eEIbyGOMWDAMfTCByFYo_CQWziVIlriAxrvbiIR1Iscskjg"
token24 <- paste("Bearer", token24)

cse <- get_cse_stocks(token24)
uics <- paste(cse$Data.Identifier, collapse = ",")
prc <- get_info_prices(token = token24, uics = uics)

# Yahoo Finance symbols (is there a more automatic ways to map those?)
yahoo_symbols <- cse$Data.Symbol %>%
  str_replace(":xcse", ".CO") %>%
  str_replace("a.", "-A.") %>%
  str_replace("b.", "-B.") %>%
  str_replace("SAS", "SAS-DKK") %>%
  str_replace("_", "-") %>%
  str_replace("ATLA", "ATLA-DKK")

# prices from Yahoo
yahoo_prices <- yahoo_symbols %>%
  set_names() %>%
  map(getSymbols, from = "2022-04-01", auto.assign = FALSE) %>% # For some reason you can't get just one day
  map(as.data.frame) %>%
  map(rownames_to_column, "date") %>%
  map(as_tibble) %>%
  map_dfr(pivot_longer, -date)

yahoo_prices_latest <- yahoo_prices %>%
  separate(name, into = c("company", "metric"), sep = "\\.CO\\.") %>%
  mutate(company = paste0(company, ".CO")) %>%
  mutate(date = as.Date(date)) %>%
  group_by(company) %>%
  slice_max(order_by = date, n = 1) %>%
  ungroup() %>%
  filter(metric == "Open")

# Join data from Saxo Bank with Yahoo data
prc <- prc %>%
  mutate(yahoo_symbol = yahoo_symbols) %>%
  left_join(yahoo_prices_latest, by = c("yahoo_symbol" = "company"))

# Plot
prc %>%
  select(company = Data.DisplayAndFormat.Description,
         saxo_ask = Data.Quote.Ask,
         saxo_bid = Data.Quote.Bid,
         saxo_mid = Data.Quote.Mid,
         yahoo_open = value) %>%
  mutate(company = fct_reorder(company, saxo_mid)) %>%
  pivot_longer(-company, names_to = "price_source") %>%
  ggplot(aes(y = company, x = value, color = price_source, group = price_source)) +
  geom_point() +
  geom_line() +
  scale_x_log10()

# View values
prc %>%
  select(company = Data.DisplayAndFormat.Description, contains("Quote"), yahoo_open = value) %>%
  view()
