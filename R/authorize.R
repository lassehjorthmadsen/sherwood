#' Authorize sherwood for live environment
#'
#' Wrapper around `httr::oauth2.0_token()`. Authorize sherwood app
#' for live environment in Saxo Banks OpenAPI, ie. enables trading
#' for real money.
#'
#' The returned token object must be pased to subsequent API calls
#' using the `config` parameter in e.g. `httr::GET()`.
#'
#' @return A Token2.0 reference class (RC) object
#'
#' @details
#' For more information about the oauth flow with `httr` see [this
#' example](https://github.com/r-lib/httr/blob/main/demo/oauth2-github.r).
#'
#' @export
#'
authorize_live <- function() {

  sherwood_key <- Sys.getenv("sherwood_key")
  sherwood_secret <- Sys.getenv("sherwood_secret")

  if (identical(sherwood_key, "") | identical(sherwood_secret, "")) {
    stop("`sherwood_key or sherwood_secret` env variables have not been set. Use file.edit(\"~/.Renviron\") to add them.")
  }

  saxo_endpoint <- httr::oauth_endpoint(authorize = "authorize",
                         access = "token",
                         base_url = "https://live.logonvalidation.net")

  sherwood_app <- httr::oauth_app(appname = "sherwood",
                     key = sherwood_key,
                     secret = sherwood_secret)

  my_token <- httr::oauth2.0_token(saxo_endpoint, sherwood_app, cache = FALSE)
  #my_token <- oauth2.0_token(saxo, myapp, cache = TRUE)
  my_token
}

