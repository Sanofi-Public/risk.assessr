# The following test is commented out temporarily 
# the test with devtools::test() but the problem is caused by 
#  https://github.com/hadley/testthat/issues/144
# and https://github.com/r-lib/testthat/issues/86

# test_that("running assess_pkg for test package in tar file - no notes", {
#   
#   r = getOption("repos")
#   r["CRAN"] = "http://cran.us.r-project.org"
#   options(repos = r)
#   
#   dp <- system.file("test-data/test.package.0001_0.1.0.tar.gz",
#                     package = "sanofi.risk.metric")
#   
#   
#   # set up package
#   install_list <- sanofi.risk.metric::set_up_pkg(dp)
#   
#   build_vignettes <- install_list$build_vignettes
#   package_installed <- install_list$package_installed
#   pkg_source_path <- install_list$pkg_source_path
#   rcmdcheck_args <- install_list$rcmdcheck_args
#   
#   if (package_installed == TRUE ) {
#     
#     
#     assess_package <- 
#       sanofi.risk.metric::assess_pkg(pkg_source_path,
#                                      rcmdcheck_args)
#     
#     testthat::expect_identical(length(assess_package), 4L)
#     
#     testthat::expect_true(checkmate::check_class(assess_package, "list"))
#     
#     testthat::expect_identical(length(assess_package$results), 29L)
#     
#     testthat::expect_true(!is.na(assess_package$results$pkg_name))
#     
#     testthat::expect_true(!is.na(assess_package$results$pkg_version))
#     
#     testthat::expect_true(!is.na(assess_package$results$pkg_source_path))
#     
#     testthat::expect_true(!is.na(assess_package$results$date_time))
#     
#     testthat::expect_true(!is.na(assess_package$results$executor))
#     
#     testthat::expect_true(!is.na(assess_package$results$sysname))
#     
#     testthat::expect_true(!is.na(assess_package$results$version))
#     
#     testthat::expect_true(!is.na(assess_package$results$release))
#     
#     testthat::expect_true(!is.na(assess_package$results$machine))
#     
#     testthat::expect_true(!is.na(assess_package$results$comments))
#     
#     testthat::expect_true(!is.na(assess_package$results$has_bug_reports_url))
#     
#     testthat::expect_true(checkmate::test_numeric(assess_package$results$has_bug_reports_url))
#     
#     testthat::expect_true(!is.na(assess_package$results$license))
#     
#     testthat::expect_true(checkmate::test_numeric(assess_package$results$license))
#     
#     testthat::expect_true(!is.na(assess_package$results$size_codebase))
#     
#     testthat::expect_true(checkmate::test_numeric(assess_package$results$size_codebase))
#     
#     testthat::expect_true(checkmate::test_numeric(assess_package$results$check))
#     
#     testthat::expect_gt(assess_package$results$check, 0.7)
#     
#     testthat::expect_true(checkmate::test_numeric(assess_package$results$covr))
#     
#     testthat::expect_gt(assess_package$results$covr, 0.7)
#     
#     testthat::expect_true(checkmate::test_numeric(assess_package$results$dep_score))
#     
#     testthat::expect_true(checkmate::test_numeric(assess_package$results$overall_risk_score))
#     
#     testthat::expect_true(!is.na(assess_package$results$risk_profile))
#     
#     testthat::expect_identical(length(assess_package$covr_list), 2L)
#     
#     testthat::expect_true(!is.na(assess_package$covr_list$res_cov$name))
#     
#     testthat::expect_identical(length(assess_package$covr_list$res_cov$coverage), 2L)
#     
#     testthat::expect_identical(length(assess_package$tm), 5L)
#     
#     testthat::expect_true(!is.na(assess_package$tm$exported_function))
#     
#     testthat::expect_true(!is.na(assess_package$tm$code_script))
#     
#     testthat::expect_true(!is.na(assess_package$tm$documentation))
#     
#     testthat::expect_true(!is.na(assess_package$tm$description))
#     
#     testthat::expect_true(!is.na(assess_package$tm$coverage_percent))
#     
#     testthat::expect_identical(length(assess_package$check_list), 2L)
#     
#     testthat::expect_identical(length(assess_package$check_list$res_check), 21L)
#     
#     testthat::expect_true(!is.na(assess_package$check_list$res_check$platform))
#     
#     testthat::expect_true(!is.na(assess_package$check_list$res_check$package))
#     
#     testthat::expect_identical(length(assess_package$check_list$res_check$test_output), 1L)
#     
#     testthat::expect_true(!is.na(assess_package$check_list$res_check$test_output$testthat))
#     
#     testthat::expect_identical(length(assess_package$check_list$res_check$session_info$platform), 10L)
#     
#   }
# })

test_that("running assess_pkg for test package in tar file - no exports", {

  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)

  dp <- system.file("test-data/test.package.0005_0.1.0.tar.gz",
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

    testthat::expect_identical(length(assess_package), 4L)

    testthat::expect_true(checkmate::check_class(assess_package, "list"))

    testthat::expect_identical(length(assess_package$results), 29L)

    testthat::expect_true(!is.na(assess_package$results$pkg_name))

    testthat::expect_true(!is.na(assess_package$results$pkg_version))

    testthat::expect_true(!is.na(assess_package$results$pkg_source_path))

    testthat::expect_true(!is.na(assess_package$results$date_time))

    testthat::expect_true(!is.na(assess_package$results$executor))

    testthat::expect_true(!is.na(assess_package$results$sysname))

    testthat::expect_true(!is.na(assess_package$results$version))

    testthat::expect_true(!is.na(assess_package$results$release))

    testthat::expect_true(!is.na(assess_package$results$machine))

    testthat::expect_true(!is.na(assess_package$results$comments))

    testthat::expect_true(!is.na(assess_package$results$has_bug_reports_url))

    testthat::expect_true(checkmate::test_numeric(assess_package$results$has_bug_reports_url))

    testthat::expect_true(!is.na(assess_package$results$license))

    testthat::expect_true(checkmate::test_numeric(assess_package$results$license))

    testthat::expect_true(!is.na(assess_package$results$size_codebase))

    testthat::expect_true(checkmate::test_numeric(assess_package$results$size_codebase))

    testthat::expect_true(checkmate::test_numeric(assess_package$results$check))

    testthat::expect_gt(assess_package$results$check, 0.7)

    testthat::expect_true(checkmate::test_numeric(assess_package$results$covr))

    testthat::expect_gte(assess_package$results$covr, 0)

    testthat::expect_true(checkmate::test_numeric(assess_package$results$dep_score))

    testthat::expect_true(checkmate::test_numeric(assess_package$results$overall_risk_score))

    testthat::expect_true(!is.na(assess_package$results$risk_profile))

    testthat::expect_identical(length(assess_package$covr_list), 2L)

    testthat::expect_true(!is.na(assess_package$covr_list$res_cov$name))

    testthat::expect_identical(length(assess_package$covr_list$res_cov$coverage), 2L)

    testthat::expect_identical(length(assess_package$tm), 4L)

    testthat::expect_true(is.null(assess_package$tm$exported_function))

    testthat::expect_true(is.null(assess_package$tm$code_script))

    testthat::expect_true(is.null(assess_package$tm$documentation))

    testthat::expect_true(is.null(assess_package$tm$description))

    testthat::expect_true(is.null(assess_package$tm$coverage_percent))

    testthat::expect_identical(length(assess_package$check_list), 2L)

    testthat::expect_identical(length(assess_package$check_list$res_check), 21L)

    testthat::expect_true(!is.na(assess_package$check_list$res_check$platform))

    testthat::expect_true(!is.na(assess_package$check_list$res_check$package))

    testthat::expect_identical(length(assess_package$check_list$res_check$test_output), 0L)

    testthat::expect_true(is.null(assess_package$check_list$res_check$test_output$testthat))

    testthat::expect_identical(length(assess_package$check_list$res_check$session_info$platform), 10L)

  }
})



test_that("running rcmd check for test package - error handling", {
  
  check_type <- "2"
  
  dp <- system.file("test-data/test.package.0003_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp, check_type)
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  if (package_installed == TRUE ) {
    
    assess_package <- 
      sanofi.risk.metric::assess_pkg(pkg_source_path,
                                     rcmdcheck_args)
    
    testthat::expect_identical(assess_package$results$check, 0)
    
    testthat::expect_identical(assess_package$check_list$check_score, 0)
    
    testthat::expect_false(is.null(assess_package$check$res_check$errors))
    
    testthat::expect_true(length(nzchar(assess_package$check$res_check$errors)) > 0)
  }
})





