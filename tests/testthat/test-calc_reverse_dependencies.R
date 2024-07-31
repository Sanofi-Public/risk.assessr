test_that("parse deps for tar file works correctly", {
  
  dp <- system.file("test-data/here-1.0.1.tar.gz", 
                    package = "sanofi.risk.metric")
  
  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args

  if (package_installed == TRUE ) {	
    revdep_score <- suppressWarnings(sanofi.risk.metric::calc_reverse_dependencies(pkg_source_path))
    
    expect_identical(length(revdep_score), 1L)
    
    expect_vector(revdep_score)
    
    expect_true(checkmate::check_numeric(revdep_score, 
                                            any.missing = FALSE)
                )
    
    testthat::expect_gt(revdep_score, 0.010) 
  }
  
})