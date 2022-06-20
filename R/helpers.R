utils::globalVariables("where")

#' Convert HTTP response to dataframe
#'
#' @param response A response object from `httr::`
#' @param remove_constant_cols Logical. Should columns with constant values be removed? Defaults to TRUE.
#'
#' @return Tibble with response content
#' @export
#'
response_df <- function(response, remove_constant_cols = FALSE) {
  df <- response %>%
    httr::content(as = "text") %>%
    jsonlite::fromJSON(flatten = T) %>%
    purrr::compact() %>%
    as.data.frame() %>%
    dplyr::as_tibble() %>%
    dplyr::mutate(dplyr::across(dplyr::ends_with(
      c("LastUpdated", "EndTime", "StartTime", "OrderTime")
    ), lubridate::as_datetime))

  if (remove_constant_cols & nrow(df) > 1) {
    df <- df %>% dplyr::select(where( ~ dplyr::n_distinct(.) > 1))
  }

  df
}


#' Generate a random id
#'
#' Useful for `context_id` and `reference_id` parameters
#' in `subscriptions` endpoint.
#'
#' @param no_chars, numeric, number of characters in randdom id
#'
#' @return character with random id
#' @export
#'
#' @examples
#' random_id(5)
#'
random_id <- function(no_chars = 10) {
  id <- c(letters, LETTERS, 0:9, "-") %>%
    sample(size = no_chars, replace = TRUE) %>%
    paste(collapse = "")
  id
}
