# setting R_TESTS to empty string because of
# https://github.com/hadley/testthat/issues/144
# and https://github.com/r-lib/testthat/issues/86
# revert this when that issue in R is fixed.
Sys.setenv("R_TESTS" = "")

library(testthat)
library(sanofi.risk.metric)

test_check("sanofi.risk.metric")
