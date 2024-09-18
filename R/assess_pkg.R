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
#' library(sanofi.risk.assessr)
#' # set CRAN repo to enable running of reverse dependencies
#' r = getOption("repos")
#' r["CRAN"] = "http://cran.us.r-project.org"
#' options(repos = r)
#' 
#' pkg_source_path <- file.choose()
#' pkg_name <- sub("\\.tar\\.gz$", "", basename(pkg_source_path)) 
#' modified_tar_file <- modify_description_file(pkg_source_path)
#' 
#' # Set up the package using the temporary file
#' install_list <- sanofi.risk.assessr::set_up_pkg(modified_tar_file)
#' 
#' # Extract information from the installation list
#' build_vignettes <- install_list$build_vignettes
#' package_installed <- install_list$package_installed
#' pkg_source_path <- install_list$pkg_source_path
#' rcmdcheck_args <- install_list$rcmdcheck_args
#' 
#' # check if the package needs to be installed locally
#' package_installed <- 
#'   sanofi.risk.assessr::install_package_local(pkg_source_path)
#' 
#' # Check if the package was installed successfully
#' if (package_installed == TRUE) {
#'   # Assess the package
#'   assess_package <- sanofi.risk.assessr::assess_pkg(pkg_source_path, rcmdcheck_args)
#'   # Output the assessment result
#' } else {
#'   message("Package installation failed.")
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
  pkg_desc <- sanofi.risk.assessr::get_pkg_desc(pkg_source_path, 
                                               fields = c("Package", 
                                                          "Version"))
  pkg_name <- pkg_desc$Package
  pkg_ver <- pkg_desc$Version
  pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)

  metadata <- sanofi.risk.assessr::get_risk_metadata()
  
  results <- sanofi.risk.assessr::create_empty_results(pkg_name,
                                                      pkg_ver,
                                                      pkg_source_path,
                                                      metadata)
  
  doc_scores <- 
    sanofi.risk.assessr::doc_riskmetric(pkg_name, 
                                       pkg_ver, 
                                       pkg_source_path)
  
  results <- 
    sanofi.risk.assessr::update_results_doc_scores(results, 
                                                  doc_scores)
  # run R code coverage
  covr_list <- run_coverage(
    pkg_source_path,  # must use untarred package dir
    covr_timeout
  )
  
  # add total coverage to results
  results$covr <- covr_list$total_cov
  
  if (is.na(results$covr) | results$covr == 0L) {
    #  create empty traceability matrix
    tm <- sanofi.risk.assessr::create_empty_tm(pkg_name)
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
  
  deps_list <- sanofi.risk.assessr::calc_dependencies(pkg_source_path)
  
  results$dependencies <- paste( unlist(deps_list$deps), collapse = '#')
  
  results$dep_score <- deps_list$dep_score
  
  results$revdep_score <- sanofi.risk.assessr::calc_reverse_dependencies(pkg_source_path)
  
  results$export_calc <- sanofi.risk.assessr::assess_exports(pkg_source_path)
 
  # convert NAs and NANs to zero
  results <- rapply( results, f=function(x) ifelse(is.nan(x),0,x), how="replace" )	  
  results <- rapply( results, f=function(x) ifelse(is.na(x),0,x), how="replace" )
  
  # calculate risk score with user defined metrics
  results$overall_risk_score <- 
    sanofi.risk.assessr::calc_overall_risk_score(results, 
                                                default_weights = FALSE)
  
  # calculate risk profile with user defined thresholds
  results$risk_profile <- 
    sanofi.risk.assessr::calc_risk_profile(results$overall_risk_score)
  
  return(list(
              results = results,
              covr_list = covr_list,
              tm = tm,
              check_list = check_list
              ))
}
