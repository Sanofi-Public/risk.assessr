test_that("running assess_pkg for test package in tar file - no notes", {
  
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data/test.package.0001_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  pkg_disp <- "test package with no notes"
  
  
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
    pkg <- pkg_desc$Package
    out_dir <- "no audit trail"
    
    # set up current package
    current_package <- "sanofi.risk.metric"
    
    # check if risk score data exists and set up path to risk score data
    riskscore_data_list <- 
      sanofi.risk.metric::check_riskscore_data_internal()
    
    riskscore_data_path <- riskscore_data_list$riskscore_data_path
    
    message("data path is ", riskscore_data_path)
    
    riskscore_data_exists <- riskscore_data_list$riskscore_data_exists
    
    message("data path exists ", riskscore_data_exists)
    
    
    rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)
    
    # remove CRAN from args so results pass without any notes or warnings
    # temp_args <- c("--ignore-vignettes", 
    #                "--no-vignettes", 
    #                "--no-manual")
    # 
    # rcmdcheck_args$args <- temp_args
    
    # rcmdcheck_args$path <- pkg_source_path
    
    assess_package <- 
      sanofi.risk.metric::assess_pkg(pkg,
                                     dp,
                                     pkg_source_path,
                                     out_dir,
                                     riskscore_data_path,
                                     riskscore_data_exists,
                                     overwrite = TRUE,
                                     rcmdcheck_args
      ) 
    
    
    testthat::expect_true(checkmate::test_numeric(assess_package$results$check))
    
    testthat::expect_gt(assess_package$results$check, 0.7)
    
  }
})