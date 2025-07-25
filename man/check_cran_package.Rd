% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_package_host_info.R
\name{check_cran_package}
\alias{check_cran_package}
\title{Check if a Package Exists on CRAN}
\usage{
check_cran_package(package_name)
}
\arguments{
\item{package_name}{A character string specifying the name of the package to check.}
}
\value{
A logical value: `TRUE` if the package exists on CRAN, `FALSE` otherwise.
}
\description{
This function checks if a given package is available on CRAN.
}
\examples{
\dontrun{
# Check if the package "ggplot2" exists on CRAN
check_cran_package("ggplot2")
}
}
\keyword{internal}
