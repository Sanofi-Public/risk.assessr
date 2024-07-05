
test_that("running rcmd check for actual package in tar file works correctly", {

  dp <- system.file("test-data/diffdf-1.0.4.tar.gz",
                     package = "sanofi.risk.metric")
  pkg_disp <- stringr::str_extract(dp, "/testdata/[^-]+")

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
    results$check <- run_rcmdcheck(pkg_source_path, out_dir, rcmdcheck_args) # use tarball

    testthat::expect_true(checkmate::test_numeric(results$check))

    testthat::expect_gt(results$check, 0.1)

  }
})

test_that("running rcmd check for created package in tar file with notes", {
  local_check_envvar()
  # Create temp package that will succeed
  pkg_setup <- pkg_dirs$pkg_setups_df %>% dplyr::filter(pkg_type == "pass_success")
  
  build_vignettes <- TRUE
  
  metadata <- sanofi.risk.metric::get_risk_metadata()
  
  pkg_name <- pkg_setup$pkg_name
  pkg_ver <- ""
  pkg_source_path <- pkg_setup$tar_file
  
  results <- sanofi.risk.metric::create_empty_results(pkg_name,
                                                      pkg_ver,
                                                      pkg_source_path,
                                                      metadata)
  
  rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)
  
  # Run check and coverage - expect message
  rcmdcheck_args$path <- pkg_setup$tar_file
  out_dir <- "no audit trail"
  testthat::expect_message(
    res_check <- run_rcmdcheck(pkg_setup$pkg_result_dir, out_dir, rcmdcheck_args),
    glue::glue("rcmdcheck for {basename(pkg_setup$pkg_result_dir)} passed"),
    fixed = TRUE
  )
  
  # confirm success
  testthat::expect_gt(res_check, 0.1) 
  testthat::expect_equal(res_check, 0.7)
})  

test_that("running rcmd check for created package in tar file with warnings", {
  local_check_envvar()
  # Create temp package that will succeed
  pkg_setup <- pkg_dirs$pkg_setups_df %>% dplyr::filter(pkg_type == "pass_warning")
  
  build_vignettes <- TRUE
  
  metadata <- sanofi.risk.metric::get_risk_metadata()
  
  pkg_name <- pkg_setup$pkg_name
  pkg_ver <- ""
  pkg_source_path <- pkg_setup$tar_file
  
  results <- sanofi.risk.metric::create_empty_results(pkg_name,
                                                      pkg_ver,
                                                      pkg_source_path,
                                                      metadata)
  
  rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)
  
  # Run check and coverage - expect message
  rcmdcheck_args$path <- pkg_setup$tar_file
  out_dir <- "no audit trail"
  testthat::expect_message(
    res_check <- run_rcmdcheck(pkg_setup$pkg_result_dir, out_dir, rcmdcheck_args),
    glue::glue("rcmdcheck for {basename(pkg_setup$pkg_result_dir)} passed with warnings and/or notes"),
    fixed = TRUE
  )
  
  # confirm success
  testthat::expect_gte(res_check, 0) 
  testthat::expect_equal(res_check, 0.4)
})

test_that("running rcmd check for created package in tar file with test failures", {
  local_check_envvar()
  # Create temp package that will succeed
  pkg_setup <- pkg_dirs$pkg_setups_df %>% dplyr::filter(pkg_type == "fail_test")
  
  build_vignettes <- TRUE
  
  metadata <- sanofi.risk.metric::get_risk_metadata()
  
  pkg_name <- pkg_setup$pkg_name
  pkg_ver <- ""
  pkg_source_path <- pkg_setup$tar_file
  
  results <- sanofi.risk.metric::create_empty_results(pkg_name,
                                                      pkg_ver,
                                                      pkg_source_path,
                                                      metadata)
  
  rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)
  
  # Run check and coverage - expect message
  rcmdcheck_args$path <- pkg_setup$tar_file
  out_dir <- "no audit trail"
  testthat::expect_message(
    res_check <- run_rcmdcheck(pkg_setup$pkg_result_dir, out_dir, rcmdcheck_args),
    glue::glue("rcmdcheck for {basename(pkg_setup$pkg_result_dir)} failed"),
    fixed = TRUE
  )
  
  # confirm failure
  testthat::expect_equal(res_check, 0)
})

test_that("running rcmd check for created package in tar file with bad functions - failure before tests are run", {
  local_check_envvar()
  # Create temp package that will succeed
  pkg_setup <- pkg_dirs$pkg_setups_df %>% dplyr::filter(pkg_type == "fail_func_syntax")
  
  build_vignettes <- TRUE
  
  metadata <- sanofi.risk.metric::get_risk_metadata()
  
  pkg_name <- pkg_setup$pkg_name
  pkg_ver <- ""
  pkg_source_path <- pkg_setup$tar_file
  
  results <- sanofi.risk.metric::create_empty_results(pkg_name,
                                                      pkg_ver,
                                                      pkg_source_path,
                                                      metadata)
  
  rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)
  
  # Run check and coverage - expect message
  rcmdcheck_args$path <- pkg_setup$tar_file
  out_dir <- "no audit trail"
  testthat::expect_message(
    res_check <- run_rcmdcheck(pkg_setup$pkg_result_dir, out_dir, rcmdcheck_args),
    glue::glue("rcmdcheck for {basename(pkg_setup$pkg_result_dir)} failed"),
    fixed = TRUE
  )
  
  # confirm failure
  testthat::expect_equal(res_check, 0)
})