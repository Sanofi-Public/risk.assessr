test_that("set up package for tar file with default check type", {
  
  dp <- system.file("test-data", "test.package.0001_0.1.0.tar.gz", 
                    package = "risk.assessr")
  
  # set up package
  install_list <- set_up_pkg(dp)
  
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

test_that("set up package for tar file with check type 1", {    
  dp <- system.file("test-data", "test.package.0001_0.1.0.tar.gz", 
                    package = "risk.assessr")
  
  check_type <- "1"
  
  # set up package
  install_list <- set_up_pkg(dp, 
                                                 check_type 
                                                 )
  
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

test_that("set up package for tar file with check type 1", {    
  dp <- system.file("test-data", "test.package.0001_0.1.0.tar.gz", 
                    package = "risk.assessr")
  
  check_type <- "2"
  
  # set up package
  install_list <- set_up_pkg(dp, 
                                                 check_type 
  )
  
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