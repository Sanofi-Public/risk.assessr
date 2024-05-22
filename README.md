<!-- badges: start -->
[![R-CMD-check](https://github.com/Sanofi-GitHub/bp-art-sanofi.risk.metric/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Sanofi-GitHub/bp-art-sanofi.risk.metric/actions/workflows/R-CMD-check.yaml)

[![test-coverage](https://github.com/Sanofi-GitHub/bp-art-sanofi.risk.metric/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/Sanofi-GitHub/bp-art-sanofi.risk.metric/actions/workflows/test-coverage.yaml)


![Coverage](https://img.shields.io/badge/coverage-17%25-red.svg)

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

**Unit testing metrics** - includes R command check, unit test coverage
and composite coverage of dependencies

**Documentation metrics** - availability of vignettes, news tracking,
example(s), return object description for exported functions, and type
of license

**Dependency Metrics** - package dependencies and reverse dependencies

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

5.  Save the code coverage results

6.  Run R CMD check

7.  Save the R CMD check results

8.  Run risk assessment metrics using default or user defined weighting

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

# Future directions

- user defined weights
- check package versions with **verdepcheck**
- write data to SQLite DB
- traceability matrix – matching the function / test descriptions to
  tests and match to test pass/fail

# Installation
