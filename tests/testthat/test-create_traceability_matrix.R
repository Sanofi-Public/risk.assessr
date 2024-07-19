test_that("running tm for created package in tar file with no notes", {

  dp <- system.file("test-data/stringr-1.5.1.tar.gz",
                    package = "sanofi.risk.metric")
  pkg_disp <- "test here package"

  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp, pkg_disp)

  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  out_dir <- install_list$out_dir
  results <- install_list$results

  if (package_installed == TRUE ) {

    # setup parameters for running covr
    pkg_desc <- sanofi.risk.metric::get_pkg_desc(pkg_source_path,
                                                 fields = c("Package",
                                                            "Version"))
    pkg_name <- pkg_desc$Package

    covr_timeout <- Inf

    covr_list <- sanofi.risk.metric::run_coverage(
      pkg_source_path,  # must use untarred package dir
      out_dir,
      covr_timeout
    )

    tm <- create_traceability_matrix(pkg_name,
                                     pkg_source_path,
                                     covr_list$res_cov,
                                     out_dir)

    testthat::expect_identical(length(tm), 5L)

    testthat::expect_true(checkmate::check_data_frame(tm,
                                            any.missing = FALSE))

    testthat::expect_true(checkmate::check_data_frame(tm,
                                            col.names = "named")
    )

  } else {
    message(glue::glue("cannot run traceability matrix for {basename(pkg_source_path)}"))
  }

})

test_that("running tm for created package in tar file with no tests", {

  dp <- system.file("test-data/test.package.0004_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  pkg_disp <- "test package with no tests"

  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp, pkg_disp)

  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  out_dir <- install_list$out_dir
  results <- install_list$results

  if (package_installed == TRUE ) {

    # setup parameters for running covr
    pkg_desc <- sanofi.risk.metric::get_pkg_desc(pkg_source_path,
                                                 fields = c("Package",
                                                            "Version"))
    pkg_name <- pkg_desc$Package

    covr_timeout <- Inf

    covr_list <- suppressMessages(sanofi.risk.metric::run_coverage(
      pkg_source_path,  # must use untarred package dir
      out_dir,
      covr_timeout)
    )
    
    tm <- sanofi.risk.metric::create_traceability_matrix(pkg_name,
                                       pkg_source_path,
                                       covr_list$res_cov,
                                       out_dir)

    testthat::expect_identical(length(tm), 5L)
    
    testthat::expect_true(checkmate::check_data_frame(tm,
                                                      any.missing = FALSE))
    
    testthat::expect_true(checkmate::check_data_frame(tm,
                                                      col.names = "named")
    )
    
    testthat::expect_equal(covr_list$total_cov, 0)
    
    testthat::expect_equal(covr_list$res_cov$coverage$totalcoverage, 0)
    
  } else {
    message(glue::glue("cannot run traceability matrix for {basename(pkg_source_path)}"))
  }

})

test_that("running tm for created package in tar file with no R directory", {
  
  dp <- system.file("test-data/test.package.0006_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  pkg_disp <- "test package with no R directory"
  
  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp, pkg_disp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  out_dir <- install_list$out_dir
  results <- install_list$results
  
  if (package_installed == TRUE ) {
    
    # setup parameters for running covr
    pkg_desc <- sanofi.risk.metric::get_pkg_desc(pkg_source_path, 
                                                 fields = c("Package", 
                                                            "Version"))
    pkg_name <- pkg_desc$Package
    
    covr_timeout <- Inf
    
    covr_list <- suppressMessages(sanofi.risk.metric::run_coverage(
      pkg_source_path,  # must use untarred package dir
      out_dir,
      covr_timeout)
    )
    
    testthat::expect_error(
      tm <- create_traceability_matrix(pkg_name, 
                                       pkg_source_path, 
                                       covr_list$res_cov, 
                                       out_dir),
      "an R directory is needed to create a traceability matrix"
    )
    
  } else {
    message(glue::glue("cannot run traceability matrix for {basename(pkg_source_path)}"))
  } 
  
})

test_that("running tm for created package in tar file with empty R directory", {
  
  dp <- system.file("test-data/test.package.0007_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  pkg_disp <- "test package with empty R directory"
  
  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp, pkg_disp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  out_dir <- install_list$out_dir
  results <- install_list$results
  
  if (package_installed == TRUE ) {
    
    # setup parameters for running covr
    pkg_desc <- sanofi.risk.metric::get_pkg_desc(pkg_source_path, 
                                                 fields = c("Package", 
                                                            "Version"))
    pkg_name <- pkg_desc$Package
    
    covr_timeout <- Inf
    
    covr_list <- suppressMessages(sanofi.risk.metric::run_coverage(
      pkg_source_path,  # must use untarred package dir
      out_dir,
      covr_timeout)
    )
    
    testthat::expect_error(
      tm <- create_traceability_matrix(pkg_name, 
                                       pkg_source_path, 
                                       covr_list$res_cov, 
                                       out_dir),
      "an R directory is needed to create a traceability matrix"
    )
    
  } else {
    message(glue::glue("cannot run traceability matrix for {basename(pkg_source_path)}"))
  } 
  
})