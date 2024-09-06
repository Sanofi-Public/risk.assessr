
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![R-CMD-check](https://github.com/Sanofi-GitHub/bp-art-sanofi.risk.metric/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Sanofi-GitHub/bp-art-sanofi.risk.metric/actions/workflows/R-CMD-check.yaml)
[![test-coverage](https://github.com/Sanofi-GitHub/bp-art-sanofi.risk.metric/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/Sanofi-GitHub/bp-art-sanofi.risk.metric/actions/workflows/test-coverage.yaml)

<!-- badges: end -->

# sanofi.risk.metrics

# Overview

The business case is to establish a comprehensive and reliable package
that helps in the initial determining of a package’s reliability and
security in terms of maintenance, documentation, and dependencies.

This package is designed to carry out a risk assessment of R packages at
the beginning of the validation process when packages are not on github
(either internal or open source).

It calculates risk metrics such as:

**Core metrics** - includes R command check, unit test coverage and
composite coverage of dependencies

**Documentation metrics** - availability of vignettes, news tracking,
example(s), return object description for exported functions, and type
of license

**Dependency Metrics** - package dependencies and reverse dependencies

It also calculates a:

**Traceability matrix** - matching the function / test descriptions to
tests and match to test pass/fail

# Description

This package has the following steps in the workflow to assess the risk
of an R package using riskmetric:

Finding a source for package information locally (**renv.lock** file or
installed local package **tar.gz** file Assessing the package under
validation criteria and scoring the assessment criteria `assess_pkg()`

The results are assembled in a dataset of validation criteria containing
an overall risk score for each package as shown in the example below.

This package executes the following tasks:

1.  upload the source package(`renv.lock` or `tar.gz` file)

2.  Unpack the `tar.gz` file

3.  Install the package locally

4.  Run code coverage

5.  Run a traceability matrix

6.  Run R CMD check

7.  Run risk assessment metrics using default or user defined weighting

# Notes

This package fixes a number of errors in `pharmaR/riskmetric`

1.  running R CMD check and code coverage with locally installed
    packages
2.  user defined weighting works
3.  `Suggests` added to checking dependencies
4.  `assess_dependencies` and `assess_reverse_dependencies` has sigmoid
    point increased
5.  `assess_dependencies` has value range changed to fit in with other
    scoring metrics

# Current/Future directions

- overall risk profile - `DONE`
- traceability matrix - matching the function / test descriptions to
  tests and match to test pass/fail - `DONE`
- check package versions with **verdepcheck**

# Acknowledgements

The project is inspired by the
[`riskmetric`](https://github.com/pharmaR/riskmetric) package and the
[`mpn.scorecard`](https://github.com/metrumresearchgroup/mpn.scorecard)
package and draws on some of their ideas and functions.

# Installation

- Create a `Personal Access Token` (PAT) on `github`

  - Log into your `github` account
  - Go to the token settings URL using the [Token Settings
    URL](https://github.com/settings/tokens)
    - (do not forget to add the SSH `Sanofi-GitHub` authorization)

- Create a `.Renviron` file with your GITHUBTOKEN as:

<!-- -->

    # .Renviron
    GITHUBTOKEN=dfdxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxfdf

- restart R session
- You can install the package with:

<!-- -->

    auth_token = Sys.getenv("GITHUBTOKEN")
    devtools::install_github("Sanofi-GitHub/bp-art-sanofi.risk.metric", ref = "main", auth_token = auth_token)

## Assessing your own package

To assess your package, do the following steps:

1 - save your package as a `tar.gz` file

- This can be done in `RStudio` -\> `Build Tab` -\> `More` -\>
  `Build Source Package`

2 - Run the following code sample and use `file.choose` to load your
`tar.gz` file

``` r
library(sanofi.risk.metric)
# set CRAN repo to enable running of reverse dependencies
r = getOption("repos")
r["CRAN"] = "http://cran.us.r-project.org "
options(repos = r)
pkg_source_path <- file.choose()
pkg_name <- sub("\\.tar\\.gz$", "", basename(pkg_source_path))  

modified_tar_file <- modify_description_file(pkg_source_path, pkg_name)
# Set up the package using the temporary file
install_list <- sanofi.risk.metric::set_up_pkg(modified_tar_file)
# Extract information from the installation list
build_vignettes <- install_list$build_vignettes
package_installed <- install_list$package_installed
pkg_source_path <- install_list$pkg_source_path
rcmdcheck_args <- install_list$rcmdcheck_args
# Check if the package was installed successfully
if (package_installed == TRUE) {
  # ensure path is set to package source path
  rcmdcheck_args$path <- pkg_source_path
  
  # Assess the package
  
  assess_package <- sanofi.risk.metric::assess_pkg(pkg_source_path, rcmdcheck_args)
  
  # Output the assessment result
  
  } else {
  message("Package installation failed.")
  }
# Inspect the R object to find out details of the risk assessment 
head(assess_package)
```
