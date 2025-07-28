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
#' # set CRAN repo to enable running of reverse dependencies
#' r = getOption("repos")
#' r["CRAN"] = "http://cran.us.r-project.org"
#' old <- options(repos = r)
#' 
#' pkg_source_path <- system.file("test-data", "here-1.0.1.tar.gz", 
#'    package = "risk.assessr")
#' pkg_name <- sub("\\.tar\\.gz$", "", basename(pkg_source_path)) 
#' modified_tar_file <- modify_description_file(pkg_source_path)
#' 
#' # Set up the package using the temporary file
#' install_list <- set_up_pkg(modified_tar_file)
#' 
#' # Extract information from the installation list
#' build_vignettes <- install_list$build_vignettes
#' package_installed <- install_list$package_installed
#' pkg_source_path <- install_list$pkg_source_path
#' rcmdcheck_args <- install_list$rcmdcheck_args
#' 
#' # check if the package needs to be installed locally
#' package_installed <- install_package_local(pkg_source_path)
#' 
#' # Check if the package was installed successfully
#' if (package_installed == TRUE) {
#'   # Assess the package
#'   assess_package <- assess_pkg(pkg_source_path, rcmdcheck_args)
#'   # Output the assessment result
#' } else {
#'   message("Package installation failed.")
#' }
#' options(old)
#' }
#' @export
#'
assess_pkg <- function(
    pkg_source_path,
    rcmdcheck_args,
    covr_timeout = Inf
) {
  
  old_options <- options()
  old_wd <- getwd()
  
  # Ensure cleanup on exit
  on.exit({
    options(old_options)
    setwd(old_wd)
  }, add = TRUE)
  
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
  pkg_desc <- get_pkg_desc(pkg_source_path, 
                           fields = c("Package", 
                                      "Version"))
  pkg_name <- pkg_desc$Package
  pkg_ver <- pkg_desc$Version
  pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
  
  metadata <- get_risk_metadata()
  
  results <- create_empty_results(pkg_name, pkg_ver, pkg_source_path,metadata)
  
  doc_scores <- doc_riskmetric(pkg_name, pkg_ver, pkg_source_path)
  
  results <- update_results_doc_scores(results, doc_scores)
  # run R code coverage
  covr_list <- run_coverage(
    pkg_source_path,  # must use untarred package dir
    covr_timeout
  )
  
  # add total coverage to results
  results$covr <- covr_list$total_cov
  
  if (is.na(results$covr) | results$covr == 0L) {
    #  create empty traceability matrix
    tm <- create_empty_tm(pkg_name)
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
  
  deps_list <- calc_dependencies(pkg_source_path)
  
  results$dep_score <- deps_list$dep_score
  
  # tryCatch to allow for continued processing of risk metric data
  results$suggested_deps <- tryCatch(
    withCallingHandlers(
      check_suggested_exp_funcs(pkg_name, pkg_source_path, deps_list$deps),
      error = function(e) {
        results$suggested_deps <<- rbind(results$suggested_deps, data.frame(
          source = pkg_name,
          function_type = "Unknown",
          suggested_function = "Error in checking suggested functions",
          where = NA,
          stringsAsFactors = FALSE
        ))
        invokeRestart("muffleError")
      }
    ),
    error = function(e) {
      message("An error occurred in checking suggested functions: ", e$message)
      NULL
    }
  )
  
  revdeps_list <- calc_reverse_dependencies(pkg_source_path)
  
  results$rev_deps <- revdeps_list$rev_deps
  
  results$revdep_score <- revdeps_list$revdep_score
  
  results$export_calc <- assess_exports(pkg_source_path)
  
  # calculate risk score with user defined metrics
  results$overall_risk_score <- calc_overall_risk_score(results, default_weights = FALSE)
  
  # calculate risk profile with user defined thresholds
  results$risk_profile <- calc_risk_profile(results$overall_risk_score)
  
  results$dependencies <- risk.assessr::get_session_dependencies(deps_list$deps)
  
  # author
  pkg_author <- get_pkg_author(pkg_name, pkg_source_path)
  results$author <- pkg_author
  
  # license
  pkg_license <- get_pkg_license(pkg_name, pkg_source_path)
  results$license_name <- pkg_license
  
  # get host repo
  pkg_host <- get_host_package(pkg_name, pkg_ver, pkg_source_path)
  results$host <- pkg_host
  
  if (!is.null(pkg_host$github_links) && pkg_host$github_links != "No GitHub link found") {  
    owner <- sub("https://github.com/([^/]+)/.*", "\\1", pkg_host$github_links)
  } else {
    owner <- NA
  }
  
  
  # get github Data
  github_data <- get_github_data(owner, pkg_name)
  results$github_data <- github_data
  
  download_list <- list("total_download" = get_package_download(pkg_name, "grand-total"),
                        "last_month_download" = get_package_download(pkg_name, "last-month")
  )
  
  results$download <- download_list
  
  # Get version
  version_info <- NULL
  
  if (pkg_host$cran != "No CRAN link found") {
    result_cran <- check_and_fetch_cran_package(pkg_name, pkg_ver)
    
    version_info <- list("available_version" = result_cran$all_versions,
                         "last_version" =  result_cran$last_version)
    
  } else if (pkg_host$bioconductor_links != "No Bioconductor link found") {
    
    html_content <- fetch_bioconductor_releases()
    release_data <- parse_bioconductor_releases(html_content)
    result_bio <- get_bioconductor_package_url(pkg_name, pkg_ver, release_data)
    
    available_version <- result_bio$all_versions
    last_version <- result_bio$last_version
    bioconductor_version_package <- result_bio$bioconductor_version_package
    
    version_info <- list("available_version" = available_version,
                         "last_version" =  last_version,
                         "bioconductor_version_package" = bioconductor_version_package)
  }
  
  results$version_info <- version_info
  
  # convert NAs and NANs to zero
  results <- rapply( results, f=function(x) ifelse(is.nan(x),0,x), how="replace" )	  
  results <- rapply( results, f=function(x) ifelse(is.na(x),0,x), how="replace" )
  
  return(list(
    results = results,
    covr_list = covr_list,
    tm = tm,
    check_list = check_list
  ))
}