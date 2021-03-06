% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wrappers.R
\name{place_order}
\alias{place_order}
\title{Place a new order}
\usage{
place_order(
  token,
  live = FALSE,
  uic,
  buy_sell,
  asset_type = "Stock",
  amount = 1,
  amount_type = "Quantity",
  order_price = 1,
  order_type = "Market",
  ...
)
}
\arguments{
\item{token}{either a character or a token2.0 reference class (RC) object
as returned by \code{httr::oauth2.0_token()}. Sim environment uses character,
(a '24 hour token'); live environment a token object.}

\item{live}{boolean, TRUE for live environment, i.e. real money.
Defaults to FALSE, i.e. simulation environment.}

\item{uic}{character, instrument identifier}

\item{buy_sell}{character, "Buy" or "Sell}

\item{asset_type}{character, type of asset to buy or sell, e.g. "Stock" (default)}

\item{amount}{numeric, amount to buy or sell, either by number of stocks
("Quantity") or by value ("CashAmount") as specified by \code{amount_type}}

\item{amount_type}{character, either "CashAmount" or "Quantity" (default)}

\item{order_price}{numeric, the price of the order, optional for market orders, see
\code{order_type} parameter}

\item{order_type}{character, defaults to "Market", see link in Details for more
information}

\item{...}{parameters passed on to \code{response_df()}}
}
\value{
tibble
}
\description{
Place a new order
}
\details{
See the \href{https://www.developer.saxo/openapi/referencedocs/trade/v2/orders/placeorder/6cd02ecfc9130d34dc5c59fb182fc5b4}{Open API Documentation}
}
