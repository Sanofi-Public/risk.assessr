% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_bioconductor_data.R
\name{parse_bioconductor_releases}
\alias{parse_bioconductor_releases}
\title{Parse Bioconductor Release Announcements}
\usage{
parse_bioconductor_releases(html_content)
}
\arguments{
\item{html_content}{The parsed HTML document from `fetch_bioconductor_releases`.}
}
\value{
A list of lists containing Bioconductor release details: release version, date,
        number of software packages, and corresponding R version.
}
\description{
This function extracts Bioconductor release details such as version number,
release date, number of software packages, and required R version from the 
release announcements HTML page.
}
\examples{
\dontrun{
html_content <- fetch_bioconductor_releases()
release_data <- parse_bioconductor_releases(html_content)

[[1]]
[[1]]$release
[1] "3.20"

[[1]]$date
[1] "October 30, 2024"

[[1]]$software_packages
[1] "2289"

[[1]]$r_version
[1] "4.4"

}
}
