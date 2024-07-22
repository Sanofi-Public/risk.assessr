test_that("get package description works correctly", {
  
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data/here-1.0.1.tar.gz", 
                    package = "sanofi.risk.metric")
  pkg_disp <- stringr::str_extract(dp, "/test-data/[^_]+")
  
  comments <- "test get pkg desc"
  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp, 
                                                 pkg_disp,
                                                 comments)
  
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  
  if (package_installed == TRUE ) {	
    pkg_desc <- sanofi.risk.metric::get_pkg_desc(pkg_source_path)
    
    expect_identical(length(pkg_desc), 17L)
    
    expect_true(checkmate::check_list(pkg_desc, 
                                            any.missing = FALSE)
    )
    
    expect_true(checkmate::check_list(pkg_desc, 
                                      types = "character")
    )
    
  }
  
})