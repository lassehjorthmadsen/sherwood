# As a sanity check, this compare stock prices from
# Copenhagen Stock Exchange, CSE, obtained from Saxo
# Bank with same stock prices from Yahoo Finance.

library(tidyverse)
library(httr)
library(quantmod)
devtools::load_all()
theme_set(theme_minimal())

# 24 hour token for simulation account
# https://www.developer.saxo/openapi/token/current#/lst/1650285935777
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiYTRjYmRiYTZkOTI3NDIxNDliMTQ3YWI4YzlkYzNmYWIiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTIyNjQ3MDAiLCJvYWwiOiIxRiJ9.kYsKlrTJf3139L7rk0c5MGNHx9UmXfHLbsDmgNNPj31NN1b3G-3Vms6MAbG0yM7Wd4CNk_hWgRqvu-Fd-M-oWQ"
token24 <- paste("Bearer", token24)

exc <- get_exchanges(token = token24) # All Exchanges

# All stocks from all exchanges (max 1000 per exchange)
stc <- exc$Data.ExchangeId[c(165,188)] %>%
  map(get_stocks, token = token24) %>%
  compact() %>%
  bind_rows() %>%
  filter(!is.na(Data.Identifier))

# All stocks from Copenhagen Stock Exchange, CSE
 stc_cse <- get_stocks(token24, exchange_id = "CSE")
 prc_cse <- get_info_prices(token, paste(stc_cse$Data.Identifier, collapse = ","))

# uics split in smaller chunks
uic_split <- split(stc$Data.Identifier,
                   ceiling(seq_along(stc$Data.Identifier) / 100)) %>%
  map(paste, collapse = ",")

# get info prices
prc <- uic_split %>% map_dfr(get_info_prices, token = token24)

# Yahoo Finance symbols (This doesn't work in many cases. Is there a more automatic ways to map those?)
prc <- prc %>%
  separate(col = Data.DisplayAndFormat.Symbol, into = c("short_symbol", "exchange"), sep = ":", remove = F) %>%
  mutate(short_symbol = paste0(toupper(short_symbol), ".CO")) %>%
  select(Data.DisplayAndFormat.Description, Data.DisplayAndFormat.Symbol, short_symbol, exchange, Data.PriceSource)

prc_cse <- prc_cse %>%
  mutate(yahoo_symbol = Data.DisplayAndFormat.Symbol %>%
  str_replace(":xcse", ".CO") %>%
  str_replace("a.", "-A.") %>%
  str_replace("b.", "-B.") %>%
  str_replace("SAS", "SAS-DKK") %>%
  str_replace("_", "-") %>%
  str_replace("ATLA", "ATLA-DKK")
  )

# prices from Yahoo
standard_yahoo <- getQuote(prc_cse$yahoo_symbol) %>% select(-`Trade Time`)
extra_yahoo <- getQuote(prc_cse$yahoo_symbol,
                        what = yahooQF(
                          c(
                            "Name",
                            "Quote Soucee Name",
                            "Exchange",
                            "P/E Ratio",
                            "High",
                            "Bid",
                            "Ask"
                          )
                        ))

quotes_yahoo <- bind_cols(standard_yahoo, extra_yahoo) %>%
  rownames_to_column(var = "yahoo_symbol") %>%
  as_tibble()


# Join data from Saxo Bank with Yahoo data
prc_cse <- prc_cse %>%
  left_join(quotes_yahoo, by = "yahoo_symbol")

# Plots
prc_cse %>%
  select(company = Data.DisplayAndFormat.Description,
         saxo_ask = Data.Quote.Ask,
         saxo_bid = Data.Quote.Bid,
         saxo_mid = Data.Quote.Mid,
         yahoo_open = Open) %>%
  mutate(company = fct_reorder(company, saxo_mid)) %>%
  pivot_longer(-company, names_to = "price_source") %>%
  ggplot(aes(y = company, x = value, color = price_source, group = price_source)) +
  geom_point() +
  geom_line() +
  scale_x_log10()

prc_cse %>%
  ggplot(aes(x = Volume, y = `P/E Ratio`, label = Name)) +
  geom_point() +
  ggrepel::geom_text_repel(max.overlaps = 20, size = 3, color = gray(0.5)) +
  scale_x_log10() +
  scale_y_log10()

# View values
prc_cse %>%
  select(company = Data.DisplayAndFormat.Description, contains("Quote"), Open) %>%
  view()
