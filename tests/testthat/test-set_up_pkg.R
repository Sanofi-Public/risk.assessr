test_that("set up package for tar file works correctly", {
  
  dp <- system.file("test-data/test.package.0001_0.1.0.tar.gz", 
                    package = "sanofi.risk.metric")
  
  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp)
  
  expect_identical(length(install_list), 4L)
  
  expect_true(checkmate::check_list(install_list, 
                                    any.missing = FALSE)
  )
  
  expect_true(checkmate::check_list(install_list, 
                                    types = c("logical",
                                              "character",
                                              "list")
                                    )
  )
  
})  