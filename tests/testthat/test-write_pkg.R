test_that("checking write_pkg no audit trail", {

  library(sanofi.risk.metric)
  # set CRAN repo
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)

  dp <- system.file("test-data/test.package.0002_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")

  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp)

  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args

  if (package_installed == TRUE ) {

    assess_package <-
      sanofi.risk.metric::assess_pkg(pkg_source_path,
                                     rcmdcheck_args)

    assess_package$results$comments <- "test run July 29 2024"


    output <-
      capture.output(sanofi.risk.metric::write_pkg(assess_package,
                                  results_dir = "no audit trail" 
                                  ), type = "message")
    
    print(output)
    str(output)
    
    output_df <- as.data.frame(output)

    testthat::expect_equal(nrow(output_df), 8L)

    testthat::expect_true(checkmate::check_data_frame(output_df,
                                                      any.missing = FALSE,
                                                      nrows = 8,
                                                      ncols = 1))

    
  }
})
