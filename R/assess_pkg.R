#' Assess package
#'  
#' @description assess package for risk metrics
#' 
#' @param pkg_source_path - source path for install local
#' @param rcmdcheck_args - arguments for R Cmd check - these come from setup_rcmdcheck_args
#' @param covr_timeout - setting for covr time out
#'
#' @return list containing results - list containing metrics, covr, tm - trace matrix, and R CMD check
#' 
#' @examples
#' \dontrun{
#' library(sanofi.risk.metric)
#' # set CRAN repo 
#' r = getOption("repos")
#' r["CRAN"] = "http://cran.us.r-project.org"
#' options(repos = r)
#' 
#' dp <- system.file("test-data/test.package.0001_0.1.0.tar.gz",
#'                   package = "sanofi.risk.metric")
#' 
#' # set up package
#' install_list <- sanofi.risk.metric::set_up_pkg(dp)
#' 
#' build_vignettes <- install_list$build_vignettes
#' package_installed <- install_list$package_installed
#' pkg_source_path <- install_list$pkg_source_path
#' rcmdcheck_args <- install_list$rcmdcheck_args
#' 
#' if (package_installed == TRUE ) {
#'    
#'   assess_package <- 
#'     sanofi.risk.metric::assess_pkg(pkg_source_path,
#'                                    rcmdcheck_args)
#' }
#' }  
#' @export
#'
assess_pkg <- function(
    pkg_source_path,
    rcmdcheck_args,
    covr_timeout = Inf
) {
  # record covr tests
  options(covr.record_tests = TRUE)
  
  # Input checking
  checkmate::assert_string(pkg_source_path)
  checkmate::assert_directory_exists(pkg_source_path)
  checkmate::assert_list(rcmdcheck_args)
  checkmate::assert_numeric(rcmdcheck_args$timeout)
  checkmate::anyInfinite(rcmdcheck_args$timeout)
  checkmate::check_character(rcmdcheck_args$args, pattern = "--no-manual")
  checkmate::check_character(rcmdcheck_args$args, pattern = "--ignore-vignettes")
  checkmate::check_character(rcmdcheck_args$args, pattern = "--no-vignettes")
  checkmate::check_character(rcmdcheck_args$args, pattern = "--as-cran")
  checkmate::check_character(rcmdcheck_args$build_args, pattern = "--no-build-vignettes|NULL")
  checkmate::assert_string(rcmdcheck_args$env)
  checkmate::check_logical(rcmdcheck_args$quiet)
  
  
  # Get package name and version
  pkg_desc <- sanofi.risk.metric::get_pkg_desc(pkg_source_path, 
                                               fields = c("Package", 
                                                          "Version"))
  pkg_name <- pkg_desc$Package
  pkg_ver <- pkg_desc$Version
  pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
  
  metadata <- sanofi.risk.metric::get_risk_metadata()
  
  results <- sanofi.risk.metric::create_empty_results(pkg_name,
                                                      pkg_ver,
                                                      pkg_source_path,
                                                      metadata)
  
  pscore <- sanofi.risk.metric::pkg_riskmetric(pkg_source_path)
  
  results <- sanofi.risk.metric::update_pscore_results(results, pscore)
  
  # run R code coverage
  covr_list <- run_coverage(
    pkg_source_path,  # must use untarred package dir
    covr_timeout
  )
  
  # add total coverage to results
  results$covr <- covr_list$total_cov
  
  if (is.na(results$covr)) {
    #  create empty traceability matrix
    tm <- sanofi.risk.metric::create_empty_tm(pkg_name)
  } else {
    #  create traceability matrix
    tm <- create_traceability_matrix(pkg_name, 
                                     pkg_source_path,
                                     covr_list$res_cov) 
  }
  # run R Cmd check
  rcmdcheck_args$path <- pkg_source_path
  check_list <- run_rcmdcheck(pkg_source_path, rcmdcheck_args) # use tarball
  
  # add rcmd check score to results
  results$check <- check_list$check_score
  
  deps_list <- sanofi.risk.metric::calc_dependencies(pkg_source_path)
  
  results$dependencies <- paste( unlist(deps_list$deps), collapse = '#')
  
  results$dep_score <- deps_list$dep_score
  
  results$revdep_score <- sanofi.risk.metric::calc_reverse_dependencies(pkg_source_path)
  
  results$export_calc <- sanofi.risk.metric::assess_exports(pkg_source_path)
 
  # convert NAs and NANs to zero
  results <- rapply( results, f=function(x) ifelse(is.nan(x),0,x), how="replace" )	  
  results <- rapply( results, f=function(x) ifelse(is.na(x),0,x), how="replace" )
  
  # calculate risk score with user defined metrics
  results$overall_risk_score <- 
    sanofi.risk.metric::calc_overall_risk_score(results, 
                                                default_weights = FALSE)
  
  # calculate risk profile with user defined thresholds
  results$risk_profile <- 
    sanofi.risk.metric::calc_risk_profile(results$overall_risk_score)
  
  return(list(
              results = results,
              covr_list = covr_list,
              tm = tm,
              check_list = check_list
              ))
}
