test_that("running tm for created package in tar file with no notes", {

  dp <- system.file("test-data/stringr-1.5.1.tar.gz",
                    package = "risk.assessr")
  
  # set up package
  install_list <- risk.assessr::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args

  if (package_installed == TRUE ) {

    # setup parameters for running covr
    pkg_desc <- risk.assessr::get_pkg_desc(pkg_source_path,
                                                 fields = c("Package",
                                                            "Version"))
    pkg_name <- pkg_desc$Package
    pkg_ver <- pkg_desc$Version
    pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)

    covr_timeout <- Inf

    covr_list <- risk.assessr::run_coverage(
      pkg_source_path,  # must use untarred package dir
      covr_timeout
    )

    tm <- create_traceability_matrix(pkg_name,
                                     pkg_source_path,
                                     covr_list$res_cov
                                     )

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


# The following test is commented out temporarily
# the test with devtools::test() but the problem is caused by
#  httpss://github.com/hadley/testthat/issues/144
# and httpss://github.com/r-lib/testthat/issues/86
test_that("running tm for created package in tar file with no tests", {

  dp <- system.file("test-data/test.package.0004_0.1.0.tar.gz",
                    package = "risk.assessr")

  # set up package
  install_list <- risk.assessr::set_up_pkg(dp)

  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args

  # install package locally to ensure test works
  package_installed <- 
    install_package_local(pkg_source_path)
  package_installed <- TRUE
  
  if (package_installed == TRUE ) {

    # ensure path is set to package source path
    rcmdcheck_args$path <- pkg_source_path
    
    # setup parameters for running covr
    pkg_desc <- risk.assessr::get_pkg_desc(pkg_source_path,
                                                 fields = c("Package",
                                                            "Version"))
    pkg_name <- pkg_desc$Package
    pkg_ver <- pkg_desc$Version
    pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)

    covr_timeout <- Inf

    covr_list <- suppressMessages(risk.assessr::run_coverage(
      pkg_source_path,  # must use untarred package dir
      covr_timeout)
    )

    tm <- risk.assessr::create_traceability_matrix(pkg_name,
                                       pkg_source_path,
                                       covr_list$res_cov)

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
                    package = "risk.assessr")
  
  # set up package
  install_list <- risk.assessr::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args

  if (package_installed == TRUE ) {
    
    # setup parameters for running covr
    pkg_desc <- risk.assessr::get_pkg_desc(pkg_source_path, 
                                                 fields = c("Package", 
                                                            "Version"))
    pkg_name <- pkg_desc$Package
    pkg_ver <- pkg_desc$Version
    pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
    
    covr_timeout <- Inf
    
    covr_list <- suppressMessages(risk.assessr::run_coverage(
      pkg_source_path,  # must use untarred package dir
      covr_timeout)
    )
    
    testthat::expect_message(
      tm <- create_traceability_matrix(pkg_name, 
                                       pkg_source_path, 
                                       covr_list$res_cov),
      glue::glue("creating traceability matrix for {basename(pkg_source_path)}"),
      fixed = TRUE
    )
    
    testthat::expect_message(
      tm <- create_traceability_matrix(pkg_name, 
                                       pkg_source_path, 
                                       covr_list$res_cov),
      glue::glue("traceability matrix for {basename(pkg_source_path)} unsuccessful"),
      fixed = TRUE
    )
    
    testthat::expect_message(
      tm <- create_traceability_matrix(pkg_name, 
                                       pkg_source_path, 
                                       covr_list$res_cov),
      glue::glue("no R folder to create traceability matrix for {basename(pkg_source_path)}"),
      fixed = TRUE
    )
    
  } else {
    message(glue::glue("cannot run traceability matrix for {basename(pkg_source_path)}"))
  } 
  
})

# The following test will be reactivated when 
# httpss://github.com/Sanofi-GitHub/bp-art-risk.assessr/issues/78 is fixed

test_that("running tm for created package in tar file with empty R directory", {

  dp <- system.file("test-data/test.package.0005_0.1.0.tar.gz",
                    package = "risk.assessr")

  # set up package
  install_list <- risk.assessr::set_up_pkg(dp)

  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args

  if (package_installed == TRUE ) {

    # setup parameters for running covr
    pkg_desc <- risk.assessr::get_pkg_desc(pkg_source_path,
                                                 fields = c("Package",
                                                            "Version"))
    pkg_name <- pkg_desc$Package
    pkg_ver <- pkg_desc$Version
    pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)

    covr_timeout <- Inf

    covr_list <- suppressMessages(risk.assessr::run_coverage(
      pkg_source_path,  # must use untarred package dir
      covr_timeout)
    )

    testthat::expect_message(
      tm <- create_traceability_matrix(pkg_name, 
                                       pkg_source_path, 
                                       covr_list$res_cov),
      glue::glue("creating traceability matrix for {basename(pkg_source_path)}"),
      fixed = TRUE
    )
    
    testthat::expect_message(
      tm <- create_traceability_matrix(pkg_name, 
                                       pkg_source_path, 
                                       covr_list$res_cov),
      glue::glue("traceability matrix for {basename(pkg_source_path)} unsuccessful"),
      fixed = TRUE
    )
    
    testthat::expect_message(
      tm <- create_traceability_matrix(pkg_name, 
                                       pkg_source_path, 
                                       covr_list$res_cov),
      glue::glue("No top level assignments found in R folder for {basename(pkg_source_path)}"),
      fixed = TRUE
    )

  } else {
    message(glue::glue("cannot run traceability matrix for {basename(pkg_source_path)}"))
  }

})