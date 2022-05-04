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
    dplyr::mutate(dplyr::across(dplyr::ends_with("LastUpdated"), lubridate::as_datetime))

  if (remove_constant_cols) {
    df <- df %>% dplyr::select(where(~ dplyr::n_distinct(.) > 1))
  }

  df
}


#' Get stock names and identifiers
#'
#' @param token character
#'
#' @return tibble
#' @export
#'
get_cse_stocks <- function(token) {
  r <- httr::GET("https://gateway.saxobank.com/sim/openapi/ref/v1/instruments",
      query = list(ExchangeId = "CSE",
                   AssetTypes = "Stock"),
      httr::add_headers(Authorization = token)
    )

  if (httr::http_type(r) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  stocks <- response_df(r)
  stocks
}

#' Get info (non-tradeable) prices for list of instruments
#'
#' @param token character, authorization token, for demo environments
#' possibly a 24 hour token
#' @param uics character, comma separated list of identifiers
#' @param asset_type character, defaults to "stock"
#' @param amount numeric, defaults to 10000
#'
#' @return
#' tibble with instruments (e.g. stocks)
#' @export
#'
get_info_prices <- function(token, uics, asset_type = "Stock", amount = 10000) {
  r <- httr::GET("https://gateway.saxobank.com/sim/openapi/trade/v1/infoprices/list",
           query = list(Uics = uics,
                        AssetType = asset_type,
                        Amount = amount,
                        FieldGroups = "DisplayAndFormat,Quote"),
           httr::add_headers(Authorization = token)
  )

  prices <- response_df(r)
  prices
}

#' Get detailed information for list of instruments, e.g. stocks
#'
#' @param token character, authorization token, for demo environments
#' possibly a 24 hour token
#' @param uics character, comma separated list of identifiers
#' @param asset_type character, defaults to "stock"
#'
#' @return
#' tibble with instruments (e.g. stocks)
#' @export
#'
get_info_detail <- function(token, uics, asset_type = "Stock") {
  r <- httr::GET("https://gateway.saxobank.com/sim/openapi/ref/v1/instruments/details",
      query = list(Uics = uics,
                   AssetType = asset_type),
      httr::add_headers(Authorization = token)
    )

  info <- response_df(r)
  info
}

