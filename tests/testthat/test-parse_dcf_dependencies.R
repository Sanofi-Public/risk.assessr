test_that("parse deps for tar file works correctly", {
  
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data/here-1.0.1.tar.gz", 
                    package = "sanofi.risk.metric")
  
  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  if (package_installed == TRUE ) {	
    deps <- sanofi.risk.metric::parse_dcf_dependencies(pkg_source_path)
    
    expect_identical(length(deps), 2L)
    
    expect_true(checkmate::check_data_frame(deps, 
                                            any.missing = FALSE))
    
    expect_true(checkmate::check_data_frame(deps, 
                                            col.names = "named")
    )
  }
  
})
