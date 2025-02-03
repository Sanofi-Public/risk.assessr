test_that("test setup_rcmdcheck_args", {

  check_type <- "1"
  
  rcmdcheck_args <- risk.assessr::setup_rcmdcheck_args(check_type, 
                                                             build_vignettes)
  
  expect_identical(length(rcmdcheck_args), 4L)
  
  expect_true(checkmate::check_list(rcmdcheck_args, all.missing = FALSE))
  
  expect_true(checkmate::check_list(rcmdcheck_args, any.missing = FALSE))
  
  check_type <- "2"
  
  build_vignettes <- FALSE
  
  rcmdcheck_args <- risk.assessr::setup_rcmdcheck_args(check_type, 
                                                             build_vignettes)
  
  expect_identical(length(rcmdcheck_args), 5L)
  
  expect_true(checkmate::check_list(rcmdcheck_args, all.missing = FALSE))
  
  expect_true(checkmate::check_list(rcmdcheck_args, any.missing = FALSE))
  
  check_type <- "2"
  
  build_vignettes <- TRUE
  
  rcmdcheck_args <- risk.assessr::setup_rcmdcheck_args(check_type, 
                                                             build_vignettes)
  
  expect_identical(length(rcmdcheck_args), 4L)
  
  expect_true(checkmate::check_list(rcmdcheck_args, all.missing = FALSE))
  
  expect_true(checkmate::check_list(rcmdcheck_args, any.missing = FALSE))

})
