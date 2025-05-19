test_that("parse deps for tar file works correctly", {
  skip_on_cran()
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data", "here-1.0.1.tar.gz", 
                    package = "risk.assessr")
  
  # set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args

  if (package_installed == TRUE ) {	
    
    rcmdcheck_args$path <- pkg_source_path
    
    deps_list <- calc_dependencies(pkg_source_path)
    
    expect_identical(length(deps_list), 2L)
    
    expect_true(checkmate::check_data_frame(deps_list$deps, 
                                            any.missing = FALSE)
                )
    
    expect_true(checkmate::check_data_frame(deps_list$deps, 
                                            col.names = "named"
                                            )
               )
    
    testthat::expect_gt(deps_list$dep_score, 0) 
  }
  
})