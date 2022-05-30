utils::globalVariables("where")

#' Convert HTTP response to dataframe
#'
#' @param response A response object from {httr}
#' @param remove_constant_cols Logical. Should columns with constant values be removed? Defaults to TRUE.
#'
#' @return Tibble with response content
#' @export
#'
response_df <- function(response, remove_constant_cols = TRUE) {

  df <- response %>%
    httr::content(as = "text") %>%
    jsonlite::fromJSON(flatten = T) %>%
    as.data.frame() %>%
    dplyr::as_tibble() %>%
    dplyr::mutate(dplyr::across(dplyr::ends_with(c("LastUpdated", "Time")), lubridate::as_datetime))

  if (remove_constant_cols & nrow(df) > 1) {
    df <- df %>% dplyr::select(where(~ dplyr::n_distinct(.) > 1))
  }

  df
}


#' Get exchange names and data
#'
#' @param token character
#'
#' @return tibble
#' @export
#'
get_exchanges <- function(token) {

  r <- httr::GET("https://gateway.saxobank.com/sim/openapi/ref/v1/exchanges",
      query = list(`$top` = 1000),
      httr::add_headers(Authorization = token)
    )

  if (httr::http_type(r) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  exchanges <- response_df(r)
  exchanges
}


#' Get stock names and identifiers
#'
#' @param token character
#' @param exchange_id character
#' @param asset_type character
#' @param ... parameters passed on to response_df()
#'
#' @return tibble
#' @export
#'
get_instruments <- function(token, exchange_id = "CSE", asset_type = "Stock", ...) {
  r <- httr::GET("https://gateway.saxobank.com/sim/openapi/ref/v1/instruments",
      query = list(ExchangeId = exchange_id,
                   AssetTypes = asset_type,
                   `$top` = 1000),
      httr::add_headers(Authorization = token)
    )

  if (httr::http_type(r) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  stocks <- response_df(r, ...)
  stocks
}

#' Get info (non-tradeable) prices for list of instruments
#'
#' @param token character, authorization token, for demo environments
#' possibly a 24 hour token
#' @param uics character, comma separated list of identifiers
#' @param asset_type character, defaults to "stock"
#' @param amount numeric, defaults to 10000
#' @param ... parameters passed on to response_df()
#'
#' @return
#' tibble with instruments (e.g. stocks)
#' @export
#'
get_info_prices <- function(token, uics, asset_type = "Stock", amount = 10000, ...) {
  r <- httr::GET("https://gateway.saxobank.com/sim/openapi/trade/v1/infoprices/list",
           query = list(Uics = uics,
                        AssetType = asset_type,
                        Amount = amount,
                        FieldGroups = "DisplayAndFormat, Quote"),
           httr::add_headers(Authorization = token)
  )

  prices <- response_df(r, ...)
  prices
}

#' Get detailed information for list of instruments, e.g. stocks
#'
#' @param token character, authorization token, for demo environments
#' possibly a 24 hour token
#' @param uics character, comma separated list of identifiers
#' @param asset_type character, defaults to "stock"
#' @param ... parameters passed on to response_df()
#'
#' @return
#' tibble with instruments (e.g. stocks)
#' @export
#'
get_details <- function(token, uics, asset_type = "Stock", ...) {
  r <- httr::GET("https://gateway.saxobank.com/sim/openapi/ref/v1/instruments/details",
      query = list(Uics = uics,
                   AssetType = asset_type),
      httr::add_headers(Authorization = token)
    )

  info <- response_df(r, ...)
  info
}


#' Get trading schedule for a given uic and asset type
#'
#' @param token character, authorization token, for demo environments
#' possibly a 24 hour token
#' @param uic character, instrument identifier
#' @param asset_type character, type of asset
#' @param ... parameters passed on to response_df()
#'
#' @return tibble with trading schedule
#' @export
#'
get_schedule <- function(token, uic, asset_type = "Stock", ...) {
  url <- paste("https://gateway.saxobank.com/sim/openapi/ref/v1/instruments/tradingschedule",
               uic, asset_type, sep = "/")

  r <- httr::GET(url, query = list(Uic = uic, AssetType = asset_type),
                 httr::add_headers(Authorization = token)
  )

  httr::stop_for_status(r)

  schedule <- response_df(r, ...)
  schedule
}
