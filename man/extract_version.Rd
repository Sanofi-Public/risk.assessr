% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_bioconductor_data.R
\name{extract_version}
\alias{extract_version}
\title{Extract Package Version from File Path}
\usage{
extract_version(path, package_name)
}
\arguments{
\item{path}{A character string specifying the file path or URL.}

\item{package_name}{A character string specifying the name of the package.}
}
\value{
A character string representing the extracted version number, or `NULL` if no match is found.
}
\description{
This function extracts the version number from a package source file name
based on the package name and expected file pattern.
}
\examples{
\dontrun{
link <- "https://bioconductor.org/packages/3.14/bioc/src/contrib/GenomicRanges_1.42.0.tar.gz"
extract_version(link, "GenomicRanges")
}
}
\keyword{internal}
