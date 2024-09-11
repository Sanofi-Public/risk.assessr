
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![R-CMD-check](https://github.com/Sanofi-GitHub/bp-art-sanofi.risk.metric/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Sanofi-GitHub/bp-art-sanofi.risk.metric/actions/workflows/R-CMD-check.yaml)
[![test-coverage](https://github.com/Sanofi-GitHub/bp-art-sanofi.risk.metric/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/Sanofi-GitHub/bp-art-sanofi.risk.metric/actions/workflows/test-coverage.yaml)
![Coverage](https://img.shields.io/badge/coverage-0%25-brightgreen.svg)


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

# for local tar.gz R package
risk_assess_package <- sanofi.risk.metric::risk_assess_pkg()
```

``` r
# to check the overall riskmetric results
risk_assess_package$results
```

## Metrics and Risk assessment

    risk_assess_package$results
    $pkg_name
    [1] "here"

    $pkg_version
    [1] "1.0.1"

    $pkg_source_path
      /tmp/RtmpBPtvSG/temp_file_22f8324c0828/here-1.0.1 
    "/tmp/RtmpBPtvSG/temp_file_22f8324c0828/here-1.0.1" 

    $date_time
    [1] "2024-09-10 10:35:58"

    $executor
    [1] "u1004798"

    $sysname
    [1] "Linux"

    $version
    [1] "#1 SMP Tue Aug 18 14:50:17 EDT 2020"

    $release
    [1] "3.10.0-1160.el7.x86_64"

    $machine
    [1] "x86_64"

    $comments
    [1] " "

    $has_bug_reports_url
    [1] 1

    $license
    [1] 1

    $has_examples
    [1] 1

    $has_maintainer
    [1] 0

    $size_codebase
    [1] 0.4680851

    $has_news
    [1] 1

    $has_source_control
    [1] 1

    $has_vignettes
    [1] 1

    $has_website
    [1] 1

    $news_current
    [1] 1

    $export_help
    [1] 1

    $export_calc
    [1] 0.6791787

    $check
    [1] 1

    $covr
    [1] 0.9867

    $dependencies
    [1] "rprojroot (>= 2.0.2)#conflicted#covr#fs#knitr#palmerpenguins#plyr#readr#rlang#rmarkdown#testthat#uuid#withr#Imports#Suggests#Suggests#Suggests#Suggests#Suggests#Suggests#Suggests#Suggests#Suggests#Suggests#Suggests#Suggests"

    $dep_score
    [1] 0.04742587

    $revdep_score
    [1] 0.9662389

    $overall_risk_score
    [1] 0.1806717

    $risk_profile
    [1] "Low"

# Check the RCMD check results

``` r

risk_assess_package$check_list$res_check
```

## R CMD check results

    risk_assess_package$check_list$res_check
    ── R CMD check results ─────────────────────────────────────────────────────────── here 1.0.1 ────
    Duration: 46.9s

    0 errors ✔ | 0 warnings ✔ | 0 notes ✔
    > 
    > # to check the RCMD check score
    > risk_assess_package$check_list$check_score
    [1] 1

# Check the test coverage results

``` r

risk_assess_package$covr_list
```

# Test coverage results

    risk_assess_package$covr_list
    $total_cov
    [1] 0.9867

    $res_cov
    $res_cov$name
    [1] "here-1.0.1"

    $res_cov$coverage
    $res_cov$coverage$filecoverage
         R/aaa.R  R/dr_here.R     R/here.R     R/i_am.R R/set_here.R      R/zzz.R 
          100.00       100.00       100.00        95.83       100.00       100.00 

    $res_cov$coverage$totalcoverage
    [1] 98.67


    $res_cov$errors
    [1] NA

    $res_cov$notes
    [1] NA

# Check the traceability matrix

``` r
risk_assess_package$tm
```

# Traceability Matrix

    # A tibble: 4 × 5
      exported_function code_script  documentation description                   coverage_percent
      <chr>             <chr>        <chr>         <chr>                                    <dbl>
    1 dr_here           R/dr_here.R  dr_here.Rd    "dr_here() shows a message t…            100  
    2 here              R/here.R     here.Rd       "here() uses a reasonable he…            100  
    3 i_am              R/i_am.R     i_am.Rd       "Add a call to here::i_am(\"…             95.8
    4 set_here          R/set_here.R set_here.Rd   "html<a href='https://www.ti…            100

# R package on CRAN or bioconductor

To check a package on `CRAN` or `bioconductor`, run the following code:

``` r
library(sanofi.risk.metric)
risk_assess_package <- sanofi.risk.metric::assess_pkg_r_package("here", 
                                                                version = "1.0.1")
```

This will produce similar results to the example with
`Assessing your own package` with a `tar` file.
