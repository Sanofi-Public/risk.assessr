test_that("parse authors for tar file works correctly", {
  
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
    result <- get_pkg_author("test", pkg_source_path)
    
    print(result)
    
    expect_equal(result$maintainer[[1]]$email, "krlmlr+r@mailbox.org")
    expect_equal(result$funder, "No package foundation found")
    # Check the authors
    expect_true(!is.null(result$authors))
    expect_equal(length(result$authors), 2)
    expect_equal(result$authors[[1]]$email, "krlmlr+r@mailbox.org")
    expect_equal(result$authors[[2]]$email, "jenny@rstudio.com")
  }
})


test_that("parse authors for tar file works correctly with fnd", {
  
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data", "stringr-1.5.1.tar.gz", 
                    package = "risk.assessr")
  
  # set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  if (package_installed == TRUE ) {	
    result <- get_pkg_author("test", pkg_source_path)
    
    expect_equal(result$maintainer[[1]]$email, "hadley@posit.co")
    expect_equal(as.character(result$funder), c("Posit Software, PBC [cph, fnd]"))
    
    expect_equal(length(result$authors), 2)
    expect_equal(as.character(result$maintainer[[1]]$email), "hadley@posit.co")

  }
})