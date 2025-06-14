% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{get_result_path}
\alias{get_result_path}
\title{Assign output file path for various outputs during scorecard rendering}
\usage{
get_result_path(
  out_dir,
  ext = c("check.rds", "covr.rds", "tm_doc.rds", "tm_doc.xlsx")
)
}
\arguments{
\item{out_dir}{output directory for saving results}

\item{ext}{file name and extension}
}
\description{
Assign output file path for various outputs during scorecard rendering
}
\details{
The basename of `out_dir` should be the package name and version pasted together
}
\keyword{internal}
