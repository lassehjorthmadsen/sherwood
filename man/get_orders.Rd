% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wrappers.R
\name{get_orders}
\alias{get_orders}
\title{Get active orders for logged-in client}
\usage{
get_orders(token, live = FALSE, ...)
}
\arguments{
\item{token}{either a character or a token2.0 reference class (RC) object
as returned by \code{httr::oauth2.0_token()}. Sim environment uses character,
(a '24 hour token'); live environment a token object.}

\item{live}{boolean, TRUE for live environment, i.e. real money.
Defaults to FALSE, i.e. simulation environment.}

\item{...}{parameters passed on to \code{response_df()}}
}
\value{
tibble with active orders
}
\description{
Get active orders for logged-in client
}
