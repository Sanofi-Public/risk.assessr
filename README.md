
<!-- README.md is generated from README.Rmd. Please edit that file -->

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

5.  Save the code coverage results

6.  Run a traceability matrix

7.  Run R CMD check

8.  Save the R CMD check results

9.  Run risk assessment metrics using default or user defined weighting

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
- background/batch processor to create risk metrics for a larger number
  of packages  
- write data to SQLite DB
- check package versions with **verdepcheck**

# Acknowledgements

The project is inspired by the
[`riskmetric`](https://github.com/pharmaR/riskmetric) package and the
[`mpn.scorecard`](https://github.com/metrumresearchgroup/mpn.scorecard)
package and draws on some of their ideas and functions.

# Installation
