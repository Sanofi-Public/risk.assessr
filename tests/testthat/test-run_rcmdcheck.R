test_that("running rcmd check for test package in tar file - no notes", {

  dp <- system.file("test-data/test.package.0001_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  pkg_disp <- "test package with no notes"

  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp, pkg_disp)

  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  out_dir <- install_list$out_dir
  results <- install_list$results

  if (package_installed == TRUE ) {

    # get home directory

    pkg_desc <- get_pkg_desc(pkg_source_path,
                             fields = c("Package",
                                        "Version"))
    pkg_name <- pkg_desc$Package
    pkg_ver <- pkg_desc$Version

    out_dir <- "no audit trail"

    metadata <- sanofi.risk.metric::get_risk_metadata()

    results <- sanofi.risk.metric::create_empty_results(pkg_name,
                                                        pkg_ver,
                                                        pkg_source_path,
                                                        metadata)

    rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)

    # remove CRAN from args so results pass without any notes or warnings
    temp_args <- c("--ignore-vignettes", 
                          "--no-vignettes", 
                          "--no-manual")
    
    rcmdcheck_args$args <- temp_args
    
    rcmdcheck_args$path <- pkg_source_path
    
    testthat::expect_message(
         results$check <- run_rcmdcheck(pkg_source_path, out_dir, rcmdcheck_args),
            glue::glue("rcmdcheck for {basename(pkg_source_path)} passed"),
            fixed = TRUE
    )

    testthat::expect_true(checkmate::test_numeric(results$check))

    testthat::expect_gt(results$check, 0.7)
    # testthat::expect_equal(results$check, 0.8)

  }
})

test_that("running rcmd check for test package in tar file - 1 note 1 warning", {


  dp <- system.file("test-data/test.package.0002_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  pkg_disp <- "test package with 1 note and 1 warning"

  # set up package
  install_list <- set_up_pkg(dp, pkg_disp)

  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  out_dir <- install_list$out_dir
  results <- install_list$results

  if (package_installed == TRUE ) {

    # get home directory

    pkg_desc <- get_pkg_desc(pkg_source_path,
                             fields = c("Package",
                                        "Version"))
    pkg_name <- pkg_desc$Package
    pkg_ver <- pkg_desc$Version

    out_dir <- "no audit trail"

    metadata <- sanofi.risk.metric::get_risk_metadata()

    results <- sanofi.risk.metric::create_empty_results(pkg_name,
                                                        pkg_ver,
                                                        pkg_source_path,
                                                        metadata)

    rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)

    rcmdcheck_args$path <- pkg_source_path
    
    testthat::expect_message(
      results$check <- run_rcmdcheck(pkg_source_path, out_dir, rcmdcheck_args),
      glue::glue("rcmdcheck for {basename(pkg_source_path)} passed with warnings and/or notes"),
      fixed = TRUE
    )

    
    testthat::expect_true(checkmate::test_numeric(results$check))
    
    testthat::expect_gt(results$check, 0.4)
   # testthat::expect_equal(results$check, 0.65)

  }

})

test_that("running rcmd check for test package in tar file - 1 note 1 error", {

  dp <- system.file("test-data/test.package.0003_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  pkg_disp <- "test package with 1 note and 1 error"

  # set up package
  install_list <- set_up_pkg(dp, pkg_disp)

  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  out_dir <- install_list$out_dir
  results <- install_list$results

  if (package_installed == TRUE ) {

    # get home directory

    pkg_desc <- get_pkg_desc(pkg_source_path,
                             fields = c("Package",
                                        "Version"))
    pkg_name <- pkg_desc$Package
    pkg_ver <- pkg_desc$Version

    out_dir <- "no audit trail"

    metadata <- sanofi.risk.metric::get_risk_metadata()

    results <- sanofi.risk.metric::create_empty_results(pkg_name,
                                                        pkg_ver,
                                                        pkg_source_path,
                                                        metadata)

    rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)

    rcmdcheck_args$path <- pkg_source_path

    testthat::expect_message(
      results$check <- run_rcmdcheck(pkg_source_path, out_dir, rcmdcheck_args),
       glue::glue("rcmdcheck for {basename(pkg_source_path)} failed"),
       fixed = TRUE
    )

    testthat::expect_true(checkmate::test_numeric(results$check))

    testthat::expect_equal(results$check, 0)

  }
})
