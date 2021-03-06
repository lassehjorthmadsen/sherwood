% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wrappers.R
\name{get_details}
\alias{get_details}
\title{Get detailed information for list of instruments, e.g. stocks}
\usage{
get_details(token, live = FALSE, uics, asset_type = "Stock", ...)
}
\arguments{
\item{token}{either a character or a token2.0 reference class (RC) object
as returned by \code{httr::oauth2.0_token()}. Sim environment uses character,
(a '24 hour token'); live environment a token object.}

\item{live}{boolean, TRUE for live environment, i.e. real money.
Defaults to FALSE, i.e. simulation environment.}

\item{uics}{character, comma separated list of identifiers}

\item{asset_type}{character, type of asset, e.g. "Stock" or "StockOption"}

\item{...}{parameters passed on to \code{response_df()}}
}
\value{
tibble with instruments (e.g. stocks)
}
\description{
Get detailed information for list of instruments, e.g. stocks
}
