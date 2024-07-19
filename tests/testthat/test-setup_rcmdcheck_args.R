test_that("test setup_rcmdcheck_args", {

  build_vignettes <- FALSE
  
  rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)
  
  expect_identical(length(rcmdcheck_args), 5L)
  
  expect_true(checkmate::check_list(rcmdcheck_args, all.missing = FALSE))
  
  expect_true(checkmate::check_list(rcmdcheck_args, any.missing = FALSE))
  
  build_vignettes <- TRUE
  
  rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)
  
  expect_identical(length(rcmdcheck_args), 4L)
  
  expect_true(checkmate::check_list(rcmdcheck_args, all.missing = FALSE))
  
  expect_true(checkmate::check_list(rcmdcheck_args, any.missing = FALSE))

})
