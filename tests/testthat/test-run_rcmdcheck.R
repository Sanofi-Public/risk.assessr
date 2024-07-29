test_that("running rcmd check for test package in tar file - no notes", {

  dp <- system.file("test-data/test.package.0001_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  
  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args

  if (package_installed == TRUE ) {

    # remove CRAN from args so results pass without any notes or warnings
    temp_args <- c("--ignore-vignettes", 
                          "--no-vignettes", 
                          "--no-manual")
    
    rcmdcheck_args$args <- temp_args
    
    rcmdcheck_args$path <- pkg_source_path
    
    testthat::expect_message(
         results$check <- run_rcmdcheck(pkg_source_path, rcmdcheck_args),
            glue::glue("rcmdcheck for {basename(pkg_source_path)} passed"),
            fixed = TRUE
    )

    testthat::expect_identical(length(results$check$res_check), 21L)
    
    testthat::expect_true(checkmate::check_class(results$check$res_check, "rcmdcheck"))
    
    testthat::expect_true(!is.na(results$check$res_check$test_output))
    
    testthat::expect_true(checkmate::test_numeric(results$check$check_score))

    testthat::expect_gt(results$check$check_score, 0.7)
    
  }
})

test_that("running rcmd check for test package in tar file - 1 note 1 warning", {


  dp <- system.file("test-data/test.package.0002_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  
  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args

  if (package_installed == TRUE ) {

        rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)

    rcmdcheck_args$path <- pkg_source_path
    
    testthat::expect_message(
      results$check <- run_rcmdcheck(pkg_source_path, rcmdcheck_args),
      glue::glue("rcmdcheck for {basename(pkg_source_path)} passed with warnings and/or notes"),
      fixed = TRUE
    )

    
    testthat::expect_identical(length(results$check$res_check), 21L)
    
    testthat::expect_true(checkmate::check_class(results$check$res_check, "rcmdcheck"))
    
    testthat::expect_true(!is.na(results$check$res_check$test_output))
    
    testthat::expect_true(checkmate::test_numeric(results$check$check_score))
    
    testthat::expect_gt(results$check$check_score, 0.4)

  }

})

test_that("running rcmd check for test package in tar file - 1 note 1 error", {

  dp <- system.file("test-data/test.package.0003_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args

  if (package_installed == TRUE ) {

    rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)

    rcmdcheck_args$path <- pkg_source_path

    testthat::expect_message(
      results$check <- run_rcmdcheck(pkg_source_path, rcmdcheck_args),
       glue::glue("rcmdcheck for {basename(pkg_source_path)} failed"),
       fixed = TRUE
    )

    testthat::expect_identical(length(results$check$res_check), 21L)
    
    testthat::expect_true(checkmate::check_class(results$check$res_check, "rcmdcheck"))
    
    testthat::expect_true(checkmate::check_list(results$check$res_check$test_output))
    
    testthat::expect_true(checkmate::test_numeric(results$check$check_score))
    
    testthat::expect_equal(results$check$check_score, 0)

  }
})
