% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_traceability_matrix.R
\name{create_traceability_matrix}
\alias{create_traceability_matrix}
\title{Create a Traceability Matrix}
\usage{
create_traceability_matrix(
  pkg_name,
  pkg_source_path,
  func_covr,
  verbose = FALSE
)
}
\arguments{
\item{pkg_name}{name of package}

\item{pkg_source_path}{path to a source package}

\item{func_covr}{function coverage}

\item{verbose}{Logical (`TRUE`/`FALSE`). If `TRUE`, show any warnings/messages per function.}
}
\value{
a tibble with traceability matrix
}
\description{
Returns a table that links all exported functions and their aliases to their documentation (`man` files),
the R scripts containing them, and the test scripts that reference them.
}
\keyword{internal}
