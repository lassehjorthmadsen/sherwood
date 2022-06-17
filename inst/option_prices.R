# Snippets for getting option prices

library(httr)
library(tidyverse)
library(jsonlite)
devtools::load_all()

# Token for live environment
my_token <- authorize_live()

# My info
my_info <- get_client_info(token = my_token, live = TRUE)

# My default key
account_key <- my_info$DefaultAccountKey[1]
client_key <- my_info$ClientKey[1]

# EUREX: Largest European futures and options market
# OPRA: Options Price Reporting Authority for US

# Ref:
# https://www.developer.saxo/openapi/learn/reference-data?phrase=contractoptionspaces

# 1. Get list of options via instruments end point
opt <- get_instruments(token = my_token, live = TRUE, exchange_id = "EUREX", asset_type = "StockOption")

# 2. Identifier field will contain Option Root ID (collection of related options). E.g.:
root_id <- opt %>% filter(str_detect(Data.Description, "Heidelberger Cement AG")) %>% pull(Data.Identifier)

# 3. Use root id to get option space from contractoptionspaces end point. Try option root = 572 :
# Option space can be huge, so limit using OptionSpaceSegment parameter (how does that work, exactly?)
r <- httr::GET("https://gateway.saxobank.com/openapi/ref/v1/instruments/contractoptionspaces/572",
         query = list(ClientKey = client_key,
                      OptionSpaceSegment = "DefaultDates",
                      UnderlyingUic = "1"
                      ),
         config = my_token
         )


httr::http_status(r)

# 4. Examine response to find the option we need.
specific_options <- r %>%
  content() %>%
  pluck("OptionSpace") %>%
  map(pluck, "SpecificOptions") %>%
  bind_rows() %>%
  filter(PutCall == "Call", TradingStatus == "Tradable")

# 5. Set up price subscription
context_id <- c(letters, LETTERS, 0:9, "-") %>%
  sample(size = 10, replace = TRUE) %>%
  paste(collapse = "")

reference_id <- c(letters, LETTERS, 0:9, "-") %>%
  sample(size = 10, replace = TRUE) %>%
  paste(collapse = "")

body <- list(
  "Arguments" = list("Uic" = 16829451,
                     "AssetType" = "StockOption"),
  "ContextId" = "explorer_1655456847440",
  "ReferenceId" = "K_241"
)

r <- POST("https://gateway.saxobank.com/openapi/trade/v1/prices/subscriptions",
          write_stream(function(x) {
            print(length(x))
            length(x)
          }),
          body = body,
          config = my_token,
          encode = "json"
)

http_status(r)

content(r)
response_df(r)





# 6. Use optionschain endpoint


body <- list(
  "Arguments" = list("AssetType" = "StockOption",
                     "Identifier" = root_id),
  "ContextId" = context_id,
  "ReferenceId" = reference_id
)


r <- POST("https://gateway.saxobank.com/openapi/trade/v1/optionschain/subscriptions",
          body = jsonlite::toJSON(body),
          config = my_token,
          encode = "form"
          )

r <- POST("https://gateway.saxobank.com/openapi/trade/v1/optionschain/subscriptions",
          body = jsonlite::toJSON(body),
          config = my_token,
          encode = "json"
)

r <- POST("https://gateway.saxobank.com/openapi/trade/v1/optionschain/subscriptions",
          body = body,
          config = my_token,
          encode = "form"
)


http_status(r)
