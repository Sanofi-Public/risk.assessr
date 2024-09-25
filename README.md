
<!-- README.md is generated from README.Rmd. Please edit that file -->

# risk.assessr <a><img src="man/figures/logo.png" align="right" height="138" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/Sanofi-GitHub/bp-art-risk.assessr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Sanofi-GitHub/bp-art-risk.assessr/actions/workflows/R-CMD-check.yaml)
[![test-coverage](https://github.com/Sanofi-GitHub/bp-art-risk.assessr/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/Sanofi-GitHub/bp-art-sanofi.risk.assessr/actions/workflows/test-coverage.yaml)
![Coverage](https://img.shields.io/badge/coverage-95%25-brightgreen.svg)


<!-- badges: end -->

# sanofi.risk.assessr

# Overview

Open-source projects can improve how clinical trials work by making them more transparent and collaborative to solve problems and define a common standard in the clinical trial ecosystem.

Successful open source packages such as `admiral`, `tern` and as well as collaborative initiatives (`Pharmaverse`, `Transcellerate`, `Phuse`) could greatly standardize and harmonize processes for different laboratories as well as allowing for faster deliverable for submission.

However, open source raises inherent challenges in terms of:

::: {#tbl:info-table}
| Aspect         | Security                                                | Legal                                                 | Operational                                                                                                          |
|----------------|---------------------------------------------------------|-------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| Considerations | \- Vulnerability issues <br> - Confidentiality concerns | \- Is the source code under a non-permissive license? | \- Is the package maintained by an active community? <br> - Does it follow good practices? <br> - Is it sustainable? |
:::

We need to use open-source projects responsibly and safely by adhering to best practices and ensure the reliability of the package being utilized for FDA submission.


Ours goal is to establish a comprehensive and reliable package
that helps in the initial determining of a package’s reliability and
security in terms of maintenance, documentation, and dependencies.

This package is designed to carry out a risk assessment of R packages at an early stage of development may be internal and/or contrary to open-source package.


This packages can:

-   Actively run `R CMD check` (a series of technical checks that ensure examples run\
    successfully, tests pass, the packages are compatible with other packages on CRAN)

-   Provide some answers as to why certain steps are not passing

-   Actively run `test coverage` checks to ensure tests pass and calculate unit test coverage

-   create a `traceability matrix` that matches the function / test descriptions to tests\
    and match to test pass/fail and associated test coverage

-   Can be executed in several environments (different OS, wise) and with different R\
    versions

-   Can work with package versions


-   Provide a overall risk score



It calculates risk metrics such as:

**Core metrics** - includes R command check, unit test coverage and
composite coverage of dependencies

**Documentation metrics** - availability of vignettes, news tracking,
example(s), return object description for exported functions, and type
of license



# Description

This package has the following steps in the workflow to assess the risk
of an R package using riskmetric:

Finding a source for package information locally (**renv.lock** file or
installed local package **tar.gz** file Assessing the package under
validation criteria and scoring the assessment criteria `assess_pkg()`

The results are assembled in a dataset of validation criteria containing
an overall risk score for each package as shown in the example below.

This package executes the following tasks:

1.  upload the source package(`tar.gz` file) locally

2.  Unpack the `tar.gz` file

3.  Install the package locally

4.  Run code coverage

5.  Run a traceability matrix

6.  Run R CMD check

7.  Run risk assessment metrics using default or user defined weighting



# Installation

## from github repository

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

``` r
auth_token = Sys.getenv("GITHUBTOKEN")
devtools::install_github("Sanofi-GitHub/bp-art-risk.assessr", ref = "main", auth_token = auth_token)

```

  
## from CRAN

``` r
install.package("risk.assessr")
```

# Assessing your own package

To assess your package, do the following steps:

1 - save your package as a `tar.gz` file

- This can be done in `RStudio` -\> `Build Tab` -\> `More` -\>
  `Build Source Package`

2 - Run the following code sample and use `file.choose` to load your
`tar.gz` file

``` r
library(risk.assessr)

# for local tar.gz R package
risk_assess_package <- risk.assessr::risk_assess_pkg()
```

# Result: Metrics and Risk assessment

``` r
# to check the overall riskmetric results
risk_assess_package$results
```
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


# Traceability Matrix

``` r
risk_assess_package$tm
```

    # A tibble: 4 × 5
      exported_function code_script  documentation description                   coverage_percent
      <chr>             <chr>        <chr>         <chr>                                    <dbl>
    1 dr_here           R/dr_here.R  dr_here.Rd    "dr_here() shows a message t…            100  
    2 here              R/here.R     here.Rd       "here() uses a reasonable he…            100  
    3 i_am              R/i_am.R     i_am.Rd       "Add a call to here::i_am(\"…             95.8
    4 set_here          R/set_here.R set_here.Rd   "html<a href='https://www.ti…            100



# Current/Future directions

- Experimental analysis to define overall risk profile
- Open source database with `risk.assessr` data on `Sanofi` package and on internal environment
- Module to automatically fetch source R package `tar.gz` file with package name and version:

``` r
library(risk.assessr)

# for local tar.gz R package
risk_assess_package <- risk.assessr::assess_pkg_r_package("ggplot2", version = "3.5.1")

```

# Acknowledgements

The project is inspired by the
[`riskmetric`](https://github.com/pharmaR/riskmetric) package and the
[`mpn.scorecard`](https://github.com/metrumresearchgroup/mpn.scorecard)
package and draws on some of their ideas and functions.

