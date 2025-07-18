% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_package_host_info.R
\name{get_cran_package_url}
\alias{get_cran_package_url}
\title{Get CRAN Package URL}
\usage{
get_cran_package_url(package_name, version, last_version, all_versions)
}
\arguments{
\item{package_name}{A character string specifying the name of the package.}

\item{version}{An optional character string specifying the version of the package.}

\item{last_version}{A character string specifying the latest available version of the package.}

\item{all_versions}{A character vector of all available versions of the package.}
}
\value{
A character string containing the URL to download the package tarball, or `NULL`
if the version is not found in the list of available versions.
}
\description{
This function constructs the CRAN package URL for a specified package and version.
}
\examples{
\dontrun{
# Get the URL for the latest version of "dplyr"
get_cran_package_url("dplyr", NULL, "1.0.10", c("1.0.0", "1.0.10"))
# "https://cran.r-project.org/src/contrib/dplyr_1.0.10.tar.gz"
}
}
\keyword{internal}
