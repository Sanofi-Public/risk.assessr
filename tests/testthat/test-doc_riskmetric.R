test_that("test doc_riskmetrics", {
  
  library(risk.assessr)
  # set CRAN repo 
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
  
  pkg_desc <- get_pkg_desc(pkg_source_path, 
                                               fields = c("Package", 
                                                          "Version"))
  pkg_name <- pkg_desc$Package
  pkg_ver <- pkg_desc$Version
  pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
  
  doc_riskmetric_test <- 
    doc_riskmetric(pkg_name,
                                       pkg_ver,
                                       pkg_source_path)
  
  expect_identical(length(doc_riskmetric_test), 11L)
  
  expect_true(checkmate::check_list(doc_riskmetric_test, all.missing = FALSE))
  
  expect_true(checkmate::check_list(doc_riskmetric_test, any.missing = TRUE))
})
