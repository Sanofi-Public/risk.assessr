
test_that("Unpacking an empty tar file works correctly", {
  
  dp <- system.file("testdata/diffdf-1.0.4.tar.gz", 
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
    
    message("out_dir is ", out_dir)
    
    metadata <- sanofi.risk.metric::get_risk_metadata()
    
    results <- sanofi.risk.metric::create_empty_results(pkg_name,
                                                        pkg_ver,
                                                        pkg_source_path,
                                                        metadata)
    
    rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)
    
    rcmdcheck_args$path <- pkg_source_path
    results$check <- run_rcmdcheck(pkg_source_path, out_dir, rcmdcheck_args) # use tarball
  
    expect_true(checkmate::test_numeric(results$check))
    
    testthat::expect_gt(results$check, 0.1) 
      
  }
})
