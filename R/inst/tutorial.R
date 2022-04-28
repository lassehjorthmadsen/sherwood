library(tidyverse)
library(httr)

# 24 hour token for simulation account
# https://www.developer.saxo/openapi/token/current#/lst/1650285935777
token24 <- "eyJhbGciOiJFUzI1NiIsIng1dCI6IkRFNDc0QUQ1Q0NGRUFFRTlDRThCRDQ3ODlFRTZDOTEyRjVCM0UzOTQifQ.eyJvYWEiOiI3Nzc3NSIsImlzcyI6Im9hIiwiYWlkIjoiMTA5IiwidWlkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiY2lkIjoibU0zV1o1YU1WTXwyZ201Zk95ckxrdz09IiwiaXNhIjoiRmFsc2UiLCJ0aWQiOiIyMDAyIiwic2lkIjoiYjdlMWUxNzIxNDMzNGIwZDllMjI1YzA2YWQ5MjlhNWEiLCJkZ2kiOiI4NCIsImV4cCI6IjE2NTExNzY1MjAiLCJvYWwiOiIxRiJ9.tkI2zgIjmvbNQgykb81PWSqxMS6nsu_WChWInz61odpeXSvxNJC-OfFsWEesQu0kSQLPwoJFnzHI30Lv6vMQBA"
token24 <- paste("Bearer", token24)

#####################################################################
# Tutorial: https://gateway.saxobank.com/sim/openapi/port/v1/users/me
#####################################################################

# Look up information about the User
# The query below will return some basic information about the logged in user (i.e. the user id associated with the token).
# Notice the usage of the /me identifier. This is used often to identify an entity or a list of entities directly related to the logged in user.
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/users/me",
         add_headers(Authorization = token24))
content(r)$Name

# Look up information about the Client
# The query below will return some basic information about the client associated with the logged in user.
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/clients/me",
         add_headers(Authorization = token24))
content(r)$ClientId

# Look up information about the Accounts
# The client holds one or more accounts. Let go log for those. Lets also find the AccountKey associate with the clients default account (which was provided as the "DefaultAccountId" property on the client).
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/accounts/me",
         add_headers(Authorization = token24))
content(r)$Data[[1]]$AccountKey

# Establish Client and AccountKeys
# A number of API calls require you to specifiy and ClientKey or and AccountKey. We have already found the ClientKey through the request to the Users and Clients resources.
# We will use the AccountKey associated with the clients default account. This can be found by iterating the list of accounts fetched from the Accounts resource and looking for the one with AccountId = the clients DefaultAccountKey.
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/accounts/me",
         add_headers(Authorization = token24))

AccountKey <- content(r)$Data[[1]]$AccountKey
ClientKey <- content(r)$Data[[1]]$ClientKey

# Look up information about balances on your default account
# The portfolio/balances resource returns up to date information about account balances. You could issue a "/portfolio/balances/me" request to get summary information about the total balance across all your accounts.
# In this case we will use the "portfolio/balances?ClientKey={clientKey} &AccountKey={accountKey}" request to get information about the balance on your default account.
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/balances",
         query = list(AccountKey = AccountKey,
                      ClientKey = ClientKey),
         add_headers(Authorization = token24)
)

content(r)$CashBalance

# Look up information about the Instruments
# Now let's go find something to trade.
# You can fetch summary information about all instruments and option roots from the /ref/instruments endpoint. If you need more detailed information about a particular instrument or option root, you must make a secondary call to /instruments/details for instruments and /instruments/contractoptionspaces for options.
# For now we will just fetch summary information for instruments containing the key "DKK" in the symbol name or description.
# We will further constrain the list to only include instruments, which can be traded as spot currencies (assettypes=FxSpot). Notice that each instrument has an Identifier. For everything but options, this identifier will be what we use in other calls as UIC (Universal Instrument Code).
r <- GET("https://gateway.saxobank.com/sim/openapi/ref/v1/instruments?",
         query = list(Keywords = "DKK", AssetTypes = "FxSpot"),
         add_headers(Authorization = token24)
)

df <- content(r)$Data %>%
  map_dfr(as_tibble) %>%
  select(Identifier, Symbol, AssetType, Description) %>%
  arrange(Identifier) %>%
  head()

df # List of FX (foreign exchange) current prices (spot prices)

# Look up prices on Instruments
# Next, we will get some prices for instruments to trade.
# The simplest way to do this is to issue a GET request on the /trading/v1/infoprices endpoint. You can access /trading/v1/infoprices to get information for a single instrument, or /trading/v1/infoprices/list to get information for a list of instruments with the specified asset type.
# The request below will fetch prices for UICs=2047,1311,2046,17749,16, equivalent of Danish Kroner against, Swedish Krone, Swiss Franc, Norwegian Krone, US Dollar and Euro
r <- GET("https://gateway.saxobank.com/sim/openapi/trade/v1/infoprices/list",
         query = list(AccountKey = AccountKey,
                      Uics = "2047,1311,2046,17749,16",
                      AssetType = "FXSpot",
                      Amount = "100000",
                      FieldGroups = "DisplayAndFormat,Quote"),
         add_headers(Authorization = token24)
)

rates <- content(r)$Data %>%
  map_dfr(~ map_dfc(.x, as_tibble)) %>%
  select(Uic = value...21, Symbol, Decimals, Amount, Bid, Ask, LastUpdated = value...8) %>%
  mutate(LastUpdated = lubridate::as_datetime(LastUpdated)) %>%
  arrange(Uic)

rates # Exchange rates for selected currencies

# Place order on EURDKK
# It's time to start trading!
# In this step we will place an order on EURDKK, which has Uic=16. We will make it a limit order a little from the market, so we can find it.
# After this, we will query the /orders resource to verify that the order has been placed. We will then change the order to a market order. This will cause the order to be executed.
# It should disappear from the list of orders, but you should now have a new position. We will verify this by querying the /positions resource.
# Placing a new order is done by submitting a POST to the trading/orders endpoint. The amount of information required depends on the instrument and ordertype, and you should study the reference documentation carefully.
# The sample querystring and request body specifies the placement of a GTC limit order for 100.000 in the EURDKK FXSpot instrument on the specified account.
body <- '{
	"Uic": 16,
	"BuySell": "Buy",
	"AssetType": "FxSpot",
	"Amount": 100000,
	"OrderPrice": 7,
	"OrderType": "Limit",
	"OrderRelation": "StandAlone",
	"ManualOrder": true,
	"OrderDuration": {
		"DurationType": "GoodTillCancel"
	},
	"AccountKey": "mM3WZ5aMVM|2gm5fOyrLkw=="
}'

r <- POST(
  url = "https://gateway.saxobank.com/sim/openapi/trade/v2/orders",
  body = body,
  encode = "raw",
  add_headers(Authorization = token24),
  content_type_json()
)

content(r)$OrderId

# Find your Order
# You should now be able to find the order you just placed in the list of open orders. The order should be on Uic=16 and placed just a minute ago (OrderTime)".
# Note the addition of the FieldGroups=DisplayAndFormat. This requests the resource to also return informational values, which may be useful when displaying the information to the user.
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/orders/me",
         query = list(FieldGroups = "DisplayAndFormat"),
         add_headers(Authorization = token24)
)

col_names <- content(r)$Data[[1]] %>%
  flatten() %>%
  names()

orders <-
  content(r)$Data %>%
  map(compact) %>%
  map_dfr(~ map_dfc(.x, as_tibble))

names(orders) <- col_names

orders %>% # My orders, selected fields
  select("OrderId", "Uic",	"Symbol", "AssetType", "BuySell",
         "Amount", "Price", "OpenOrderType",	"DurationType")

# Change the order to a market order
# A limit order will not be executed before the limit price has been hit. We will now change the limit order to a market order. The market order will be filled immediately. It will then disappear from the orderlist and appear in the position list.
# Changing an order is done by submitting a PATCH to the trading/orders endpoint. You must specify the orderId, assetType, accountKey and the values in the request body.
# The request body below is generated automatically based your latest live order.
body <- '{
  "OrderType": "Market",
  "OrderDuration": {
    "DurationType": "DayOrder"
  },
  "AccountKey": "mM3WZ5aMVM|2gm5fOyrLkw==",
  "OrderId": "5005632977",
  "AssetType": "FxSpot"
}'

r <- PATCH(
  url = "https://gateway.saxobank.com/sim/openapi/trade/v2/orders",
  body = body,
  encode = "raw",
  add_headers(Authorization = token24),
  content_type_json()
)

content(r)$OrderId

# Find your Position
# You should now be able to find the position created as a result of your order being filled. The position should be on Uic=16.
# Note the addition of the FieldGroups=PositionStatic,PositionDynamic,DisplayAndFormat.
# This requests the resource to values which do not change (static), which change (dynamic) and some useful when displaying the information to the user (DisplayAndFormat).
r <- GET("https://gateway.saxobank.com/sim/openapi/port/v1/positions",
         query = list(ClientKey = ClientKey,
                      FieldGroups = "DisplayAndFormat,PositionBase,PositionView"),
         add_headers(Authorization = token24)
)

content(r)$Data %>% str()

col_names <- content(r)$Data[[1]] %>%
  map(compact) %>%
  flatten() %>%
  names()

positions <- content(r)$Data %>%
  map(~ map(.x, compact)) %>%
  map_dfr(~ map_dfc(.x, as_tibble))

names(positions) <- col_names

positions %>% # My positions, selected fields
  select("PositionId", "Uic",	"Symbol",	"AssetType",
         "Amount",	"OpenPrice", "ProfitLossOnTradeInBaseCurrency")

