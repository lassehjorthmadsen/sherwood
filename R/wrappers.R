#' Get client details
#'
#' @param token either a character or a token2.0 reference class (RC) object
#' as returned by `httr::oauth2.0_token()`. Sim environment uses character,
#' (a '24 hour token'); live environment a token object.
#' @param live boolean, TRUE for live environment, i.e. real money.
#' Defaults to FALSE, i.e. simulation environment.
#' @param ... parameters passed on to `response_df()`
#'
#' @details
#' See the [Open API Documentation](https://www.developer.saxo/openapi/referencedocs/port/v1/clients/getclient/1499e70934cb99a0c9e70d53f9ad8f7d)
#'
#' @return tibble
#'
#' @export
#'
get_client_info <- function(token, live = FALSE, ...) {

  if (live) {
    r <- httr::GET("https://gateway.saxobank.com/openapi/port/v1/clients/me",
             config = token)
  } else {
    r <- httr::GET("https://gateway.saxobank.com/sim/openapi/port/v1/clients/me",
                   httr::add_headers(Authorization = token)
    )
  }

  client <- response_df(r, ...)
  client
}


#' @title Get accounts for user
#' Returns all accounts under a particular client to which the logged in user belongs.
#'
#' @param token either a character or a token2.0 reference class (RC) object
#' as returned by `httr::oauth2.0_token()`. Sim environment uses character,
#' (a '24 hour token'); live environment a token object.
#' @param live boolean, TRUE for live environment, i.e. real money.
#' Defaults to FALSE, i.e. simulation environment.
#' @param ... parameters passed on to `response_df()`
#'
#' @details
#' See the [Open API Documentation](https://www.developer.saxo/openapi/referencedocs/port/v1/accounts/getaccounts/af56e3512758f8125dc6e5493d93c019)
#'
#' @return tibble
#' @export
#'
get_account_info <- function(token, live = FALSE, ...) {

  if (live) {
    r <- httr::GET("https://gateway.saxobank.com/openapi/port/v1/accounts/me",
             config = token)
  } else {
    r <- httr::GET("https://gateway.saxobank.com/sim/openapi/port/v1/accounts/me",
                   httr::add_headers(Authorization = token)
    )
  }

  account <- response_df(r, remove_constant_cols = FALSE)
  account
}


#' Get exchange names and data
#'
#' @param token either a character or a token2.0 reference class (RC) object
#' as returned by `httr::oauth2.0_token()`. Sim environment uses character,
#' (a '24 hour token'); live environment a token object.
#' @param live boolean, TRUE for live environment, i.e. real money.
#' Defaults to FALSE, i.e. simulation environment.
#'
#' @return tibble
#' @export
#'
get_exchanges <- function(token, live = FALSE) {

  if (live) {
    r <- httr::GET("https://gateway.saxobank.com/openapi/ref/v1/exchanges",
             config = token)
  } else {
    r <- httr::GET("https://gateway.saxobank.com/sim/openapi/ref/v1/exchanges",
                   httr::add_headers(Authorization = token)
    )
  }

  if (httr::http_type(r) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  exchanges <- response_df(r)
  exchanges
}


#' Get stock names and identifiers
#'
#' @param token either a character or a token2.0 reference class (RC) object
#' as returned by `httr::oauth2.0_token()`. Sim environment uses character,
#' (a '24 hour token'); live environment a token object.
#' @param live boolean, TRUE for live environment, i.e. real money.
#' Defaults to FALSE, i.e. simulation environment.
#' @param exchange_id character, the Exchange to search, e.g. "CSE" for
#' Copenhagen Stock Exchange
#' @param asset_type character, type of asset, e.g. "Stock" or "StockOption"
#' @param ... parameters passed on to `response_df()`
#'
#' @return tibble
#' @export
#'
get_instruments <- function(token, live = FALSE, exchange_id = "CSE", asset_type = "Stock", ...) {

  if (live) {
    r <- httr::GET("https://gateway.saxobank.com/openapi/ref/v1/instruments",
                   query = list(ExchangeId = exchange_id,
                                AssetTypes = asset_type,
                                `$top` = 1000),
                   config = token)
  } else {
    r <- httr::GET("https://gateway.saxobank.com/sim/openapi/ref/v1/instruments",
                   query = list(ExchangeId = exchange_id,
                                AssetTypes = asset_type,
                                `$top` = 1000),
                   httr::add_headers(Authorization = token)
    )
  }

  httr::stop_for_status(r)

  if (httr::http_type(r) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  stocks <- response_df(r, ...)
  stocks
}

#' Get info (non-tradeable) prices for list of instruments
#'
#' @param token either a character or a token2.0 reference class (RC) object
#' as returned by `httr::oauth2.0_token()`. Sim environment uses character,
#' (a '24 hour token'); live environment a token object.
#' @param live boolean, TRUE for live environment, i.e. real money.
#' Defaults to FALSE, i.e. simulation environment.
#' @param uics character, comma separated list of identifiers
#' @param asset_type character, type of asset, e.g. "Stock" or "StockOption"
#' @param amount numeric, defaults to 10000
#' @param ... parameters passed on to `response_df()`
#'
#' @return
#' tibble with instruments (e.g. stocks)
#' @export
#'
get_info_prices <- function(token, live = FALSE, uics, asset_type = "Stock", amount = 10000, ...) {

  if (live) {
    r <- httr::GET("https://gateway.saxobank.com/openapi/trade/v1/infoprices/list",
                   query = list(Uics = uics,
                                AssetType = asset_type,
                                Amount = amount,
                                FieldGroups = "DisplayAndFormat, Quote"),
                   config = token)
  } else {
    r <- httr::GET("https://gateway.saxobank.com/sim/openapi/trade/v1/infoprices/list",
                   query = list(Uics = uics,
                                AssetType = asset_type,
                                Amount = amount,
                                FieldGroups = "DisplayAndFormat, Quote"),
                   httr::add_headers(Authorization = token)
    )
  }

  prices <- response_df(r, ...)
  prices
}

#' Get detailed information for list of instruments, e.g. stocks
#'
#' @param token either a character or a token2.0 reference class (RC) object
#' as returned by `httr::oauth2.0_token()`. Sim environment uses character,
#' (a '24 hour token'); live environment a token object.
#' @param live boolean, TRUE for live environment, i.e. real money.
#' Defaults to FALSE, i.e. simulation environment.
#' @param uics character, comma separated list of identifiers
#' @param asset_type character, type of asset, e.g. "Stock" or "StockOption"
#' @param ... parameters passed on to `response_df()`
#'
#' @return
#' tibble with instruments (e.g. stocks)
#' @export
#'
get_details <- function(token, live = FALSE, uics, asset_type = "Stock", ...) {

  if (live) {
    r <- httr::GET("https://gateway.saxobank.com/openapi/ref/v1/instruments/details",
                   query = list(Uics = uics,
                                AssetType = asset_type),
                   config = token)
  } else {
    r <- httr::GET("https://gateway.saxobank.com/sim/openapi/ref/v1/instruments/details",
                   query = list(Uics = uics,
                                AssetType = asset_type),
                   httr::add_headers(Authorization = token)
    )
  }

  info <- response_df(r, ...)
  info
}


#' Get trading schedule for a given uic and asset type
#'
#' @param token either a character or a token2.0 reference class (RC) object
#' as returned by `httr::oauth2.0_token()`. Sim environment uses character,
#' (a '24 hour token'); live environment a token object.
#' @param live boolean, TRUE for live environment, i.e. real money.
#' Defaults to FALSE, i.e. simulation environment.
#' @param uic character, instrument identifier
#' @param asset_type character, type of asset, e.g. "Stock" or "StockOption"
#' @param ... parameters passed on to `response_df()`
#'
#' @return tibble with trading schedule
#' @export
#'
get_schedule <- function(token, live = FALSE, uic, asset_type = "Stock", ...) {

  if (live) {
    url <-
      paste(
        "https://gateway.saxobank.com/openapi/ref/v1/instruments/tradingschedule",
        uic,
        asset_type,
        sep = "/"
      )

    r <- httr::GET(url = url,
                   query = list(Uics = uic,
                                AssetType = asset_type),
                   config = token)
  } else {
    url <-
      paste(
        "https://gateway.saxobank.com/sim/openapi/ref/v1/instruments/tradingschedule",
        uic,
        asset_type,
        sep = "/"
      )

    r <- httr::GET(url = url,
                   query = list(Uics = uic,
                                AssetType = asset_type),
                   httr::add_headers(Authorization = token)
    )
  }

  httr::stop_for_status(r)

  schedule <- response_df(r, ...)
  schedule
}


#' Get active orders for logged-in client
#'
#' @param token either a character or a token2.0 reference class (RC) object
#' as returned by `httr::oauth2.0_token()`. Sim environment uses character,
#' (a '24 hour token'); live environment a token object.
#' @param live boolean, TRUE for live environment, i.e. real money.
#' Defaults to FALSE, i.e. simulation environment.
#' @param ... parameters passed on to `response_df()`
#'
#' @return tibble with active orders
#' @export
#'
get_orders <- function(token, live = FALSE, ...) {

  if (live) {
    r <- httr::GET("https://gateway.saxobank.com/openapi/port/v1/orders/me",
                   query = list("fieldGroups" = "DisplayAndFormat"),
                   config = token)
  } else {
    r <- httr::GET("https://gateway.saxobank.com/sim/openapi/port/v1/orders/me",
                   query = list("fieldGroups" = "DisplayAndFormat"),
                   httr::add_headers(Authorization = token)
    )
  }

  httr::stop_for_status(r)

  if (!purrr::is_empty(httr::content(r)$Data)) {
    orders <- response_df(r, ...)
  } else {
    orders <- NULL
  }

  orders
}

#' Get cash balance for logged-in client
#'
#' @param token either a character or a token2.0 reference class (RC) object
#' as returned by `httr::oauth2.0_token()`. Sim environment uses character,
#' (a '24 hour token'); live environment a token object.
#' @param live boolean, TRUE for live environment, i.e. real money.
#' Defaults to FALSE, i.e. simulation environment.
#'
#' @return numeric, cash balance
#'
get_balance <- function(token, live = FALSE) {
  if (live) {
    r <- httr::GET("https://gateway.saxobank.com/openapi/port/v1/balances/me",
             config = token)
  } else {
    r <- httr::GET("https://gateway.saxobank.com/sim/openapi/port/v1/balances/me",
                   httr::add_headers(Authorization = token)
                   )
  }

  httr::stop_for_status(r)

  balance <- httr::content(r)$CashBalance
  balance
}


#' Place a new order
#'
#' @param token either a character or a token2.0 reference class (RC) object
#' as returned by `httr::oauth2.0_token()`. Sim environment uses character,
#' (a '24 hour token'); live environment a token object.
#' @param live boolean, TRUE for live environment, i.e. real money.
#' Defaults to FALSE, i.e. simulation environment.
#' @param uic character, instrument identifier
#' @param buy_sell character, "Buy" or "Sell
#' @param asset_type character, type of asset to buy or sell, e.g. "Stock" (default)
#' @param amount numeric, amount to buy or sell, either by number of stocks
#' ("Quantity") or by value ("CashAmount") as specified by `amount_type`
#' @param amount_type character, either "CashAmount" or "Quantity" (default)
#' @param order_price numeric, the price of the order, optional for market orders, see
#' `order_type` parameter
#' @param order_type character, defaults to "Market", see link in Details for more
#' information
#' @param ... parameters passed on to `response_df()`
#'
#' @return tibble
#'
#' @details
#' See the [Open API Documentation](https://www.developer.saxo/openapi/referencedocs/trade/v2/orders/placeorder/6cd02ecfc9130d34dc5c59fb182fc5b4)
#'
#' @export
#'
place_order <- function(token,
                        live = FALSE,
                        uic,
                        buy_sell,
                        asset_type = "Stock",
                        amount = 1,
                        amount_type = "Quantity",
                        order_price = 1,
                        order_type = "Market",
                        ...) {

  body <- list(
    "Uic" = uic,
    "BuySell" = buy_sell,
    "AssetType" = asset_type,
    "Amount" = amount,
    "AmountType" = amount_type,
    "OrderPrice" = order_price,
    "OrderType" = order_type,
    "OrderRelation" = "StandAlone",
    "ManualOrder" = TRUE
  )

  if (live) {
    r <-
      httr::POST(
        "https://gateway.saxobank.com/openapi/trade/v2/orders",
        body = body,
        config = token,
        encode = "form"
      )
  } else {
    r <-
      httr::POST(
        "https://gateway.saxobank.com/sim/openapi/trade/v2/orders",
        body = body,
        config = httr::add_headers(Authorization = token),
        encode = "form"
      )
  }

  order <- response_df(r)
  order
}


#' Cancel one or more orders
#'
#' @param token either a character or a token2.0 reference class (RC) object
#' as returned by `httr::oauth2.0_token()`. Sim environment uses character,
#' (a '24 hour token'); live environment a token object.
#' @param live boolean, TRUE for live environment, i.e. real money.
#' Defaults to FALSE, i.e. simulation environment.
#' @param account_key character
#' @param order_ids character, one or more order ids
#'
#' @return tibble
#'
#' @details
#' See the [Open API Documentation](https://www.developer.saxo/openapi/referencedocs/trade/v2/orders/cancelorder/a1fd2fffa62f21901f23318f65fe8147)
#'
#' @export
#'
cancel_order <- function(token, live = FALSE, account_key, order_ids) {

  if (live) {
    url <-
      paste0(
        "https://gateway.saxobank.com/openapi/trade/v2/orders/",
        order_ids,
        "/?",
        "AccountKey=",
        account_key
      )

    r <- httr::DELETE(
      url = url,
      config = token)

  } else {
    url <-
      paste0(
        "https://gateway.saxobank.com/sim/openapi/trade/v2/orders/",
        order_ids,
        "/?",
        "AccountKey=",
        account_key
      )

    r <- httr::DELETE(
      url = url,
      config = httr::add_headers(Authorization = token)
    )
  }

  httr::stop_for_status(r)

  cancel <- response_df(r)
  cancel
}


#' Cancel all orders
#' Call `get_orders()` and `cancel_order()` to cancel *all* orders for an account
#'
#' @param token either a character or a token2.0 reference class (RC) object
#' as returned by `httr::oauth2.0_token()`. Sim environment uses character,
#' (a '24 hour token'); live environment a token object.
#' @param live boolean, TRUE for live environment, i.e. real money.
#' Defaults to FALSE, i.e. simulation environment.
#' @param account_key character
#' @param ... parameters passed on to `response_df()`
#'
#' @return tibble, containing list of cancelled order ids
#' @export
#'
cancel_all_orders <- function(token, live = FALSE, account_key, ...) {

  order_ids <- get_orders(token = token, live = live) %>%
    dplyr::select(dplyr::ends_with("OrderId")) %>%
    dplyr::pull(1) %>%
    paste(collapse = ",")

  cancel_all <- cancel_order(token = token, live = live, account_key = account_key, order_ids = order_ids, ...)
  cancel_all
}


#' Get option space for a given root id
#'
#' Returns the `$SpecificOptions` element of the `$OptionSpace`
#' element of the response object from a call to `contractoptionspaces`
#' endpoint.
#'
#' @importFrom rlang .data
#'
#' @param token either a character or a token2.0 reference class (RC) object
#' as returned by `httr::oauth2.0_token()`. Sim environment uses character,
#' (a '24 hour token'); live environment a token object.
#' @param live boolean, TRUE for live environment, i.e. real money.
#' Defaults to FALSE, i.e. simulation environment.
#' @param client_key character
#' @param option_root_id numeric, id of the required option root
#'
#' @return tibble
#'
#' @export
#'
get_optionspace <- function(token, live = FALSE, client_key, option_root_id) {
  if (live) {
    url <-
      paste0(
        "https://gateway.saxobank.com/openapi/ref/v1/instruments/contractoptionspaces/",
        option_root_id
      )

    r <- httr::GET(url = url,
                   query = list(ClientKey = client_key, OptionSpaceSegment = "DefaultDates"),
                   config = token
                   )

  } else {
    url <-
      paste0(
        "https://gateway.saxobank.com/sim/openapi/ref/v1/instruments/contractoptionspaces/",
        option_root_id
      )

    r <- httr::GET(url = url,
                   query = list(ClientKey = client_key, OptionSpaceSegment = "DefaultDates",
                                config = httr::add_headers(Authorization = token)
                                )
                   )
  }

  httr::stop_for_status(r)

  specific_options <- r %>%
    httr::content() %>%
    purrr::pluck("OptionSpace") %>%
    purrr::map(purrr::pluck, "SpecificOptions") %>%
    dplyr::bind_rows() %>%
    dplyr::filter(.data$PutCall == "Call", .data$TradingStatus == "Tradable")

  specific_options
}


#' Create a price subscription on an instrument
#'
#' @param token either a character or a token2.0 reference class (RC) object
#' as returned by `httr::oauth2.0_token()`. Sim environment uses character,
#' (a '24 hour token'); live environment a token object.
#' @param live boolean, TRUE for live environment, i.e. real money.
#' Defaults to FALSE, i.e. simulation environment.
#' @param uic character, instrument identifier
#' @param asset_type character, type of asset, e.g. "Stock" or "StockOption"
#'
#' @return tibble
#' @export
#'
make_subscription <- function(token, live = FALSE, uic, asset_type) {
  body <- list(
    "Arguments" = list(
      "Uic" = uic,
      "AssetType" = asset_type,
      "FieldGroups" = list(
        "Commissions",
        "PriceInfo",
        "PriceInfoDetails",
        "Quote",
        "Greeks"
      )
    ),
    "ContextId" = random_id(),
    "ReferenceId" = random_id()
  )

  if (live) {
    r <-
      httr::POST(
        "https://gateway.saxobank.com/openapi/trade/v1/prices/subscriptions",
        body = body,
        config = token,
        encode = "json"
      )
  } else {
    r <-
      httr::POST(
        "https://gateway.saxobank.com/sim/openapi/trade/v1/prices/subscriptions",
        body = body,
        config = httr::add_headers(Authorization = token),
        encode = "json"
      )
  }

  prices <- r %>% response_df()
  prices
}
