#' Assess package
#'  
#' @description assess package for risk metrics
#' 
#' @param pkg - name of the package
#' @param datapath - datapath with 0.gz file
#' @param pkg_source_path - source path for install local
#' @param out_dir path for writing results
#' @param riskscore_data_path data path of current risk assessment package
#' @param riskscore_data_exists logical with T/F if risk score data exists
#' @param overwrite Logical (T/F). Whether or not to overwrite existing scorecard results
#' @param rcmdcheck_args - arguments for R Cmd check
#' @param covr_timeout - setting for covr time out
#'
#' @return results - list containing metrics
#' @export
#'
assess_pkg <- function(
    pkg,
    datapath,
    pkg_source_path,
    out_dir,
    riskscore_data_path,
    riskscore_data_exists,
    overwrite = TRUE,
    rcmdcheck_args = list(
      timeout = Inf,
      args = c("--ignore-vignettes", "--no-vignettes", "--no-manual"),
      build_args = "--no-build-vignettes",
      env = c(`_R_CHECK_FORCE_SUGGESTS_` = "FALSE"),
      quiet = FALSE
    ),
    covr_timeout = Inf
) {
  # record covr tests
  options(covr.record_tests = TRUE)
  
  # Input checking
  checkmate::assert_string(pkg)
  checkmate::assert_file_exists(datapath)
  checkmate::assert_string(pkg_source_path)
  checkmate::assert_directory_exists(pkg_source_path)
  checkmate::assert_string(out_dir)
  checkmate::assert_directory_exists(out_dir)
  checkmate::check_logical(riskscore_data_exists)
  checkmate::assert_string(riskscore_data_path)
  checkmate::check_logical(overwrite)
  checkmate::assert_list(rcmdcheck_args)
  checkmate::assert_numeric(rcmdcheck_args$timeout)
  checkmate::anyInfinite(rcmdcheck_args$timeout)
  checkmate::check_character(rcmdcheck_args$args, pattern = "--no-manual")
  checkmate::check_character(rcmdcheck_args$args, pattern = "--ignore-vignettes")
  checkmate::check_character(rcmdcheck_args$args, pattern = "--no-vignettes")
  checkmate::check_character(rcmdcheck_args$build_args, pattern = "--no-build-vignettes")
  checkmate::assert_string(rcmdcheck_args$env)
  checkmate::check_logical(rcmdcheck_args$quiet)
  
  # Get package name and version
  pkg_desc <- get_pkg_desc(pkg_source_path, fields = c("Package", "Version"))
  pkg_name <- pkg_desc$Package
  pkg_ver <- pkg_desc$Version
  pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
  
  # Add pkg_name sub-directory and create if it doesn't exist
  out_dir <- file.path(out_dir, pkg_name_ver)
  if (!fs::dir_exists(out_dir)) fs::dir_create(out_dir)
  out_path <- sanofi.risk.metric::get_result_path(out_dir, "covr.rds")
  sanofi.risk.metric::check_exists_and_overwrite(out_path, overwrite)
  
  metadata <- sanofi.risk.metric::get_risk_metadata()
  
  results <- list(
    pkg_name = pkg_name,
    pkg_version = pkg_ver,
    pkg_source_path = pkg_source_path,
    date_time = metadata$datetime,
    executor = metadata$executor,
    sysname = metadata$info$sys$sysname,
    version = metadata$info$sys$version,
    release = metadata$info$sys$release,
    machine = metadata$info$sys$machine,
    has_bug_reports_url = "",
    license = "",
    has_examples = "",
    has_maintainer = "",
    size_codebase = "",
    has_news = "",
    has_source_control= "",
    has_vignettes = "",
    has_website = "",
    news_current = "",
    export_help = "",
    export_calc = "",
    check = "",
    covr = "",
    dependencies = "",
    dep_score = "",
    revdep_score = ""
  )
  
  pscore <- sanofi.risk.metric::pkg_riskmetric(pkg_source_path)
  
  results$has_bug_reports_url <- pscore$has_bug_reports_url
  results$license <- pscore$license
  results$has_examples <- pscore$has_examples
  results$has_maintainer <- pscore$has_maintainer
  results$size_codebase <- pscore$size_codebase 
  results$has_news <- pscore$has_news
  results$has_source_control <- pscore$has_source_control
  results$has_vignettes <- pscore$has_vignettes
  results$has_website <- pscore$has_website
  results$news_current <- pscore$news_current
  results$export_help <- pscore$export_help 
  
  # run R code coverage
  results$covr <- add_coverage(
    pkg_source_path,  # must use untarred package dir
    out_dir,
    covr_timeout
  )
  
  # run R Cmd check
  rcmdcheck_args$path <- pkg_source_path
  results$check <- add_rcmdcheck(pkg_source_path, out_dir, rcmdcheck_args) # use tarball
  
  deps_list <- sanofi.risk.metric::calc_dependencies(pkg_source_path)
  
  results$dependencies <- paste( unlist(deps_list$deps), collapse = '#')
  
  results$dep_score <- deps_list$dep_score
  
  results$revdep_score <- sanofi.risk.metric::calc_reverse_dependencies(pkg_source_path)
  
  results$export_calc <- sanofi.risk.metric::assess_exports(pkg_source_path)
 
  # calculate risk score with user defined metrics
  results$overall_risk_score <- 
    sanofi.risk.metric::calc_overall_risk_score(results, 
                                                default_weights = FALSE)
  
  # write data to csv
  sanofi.risk.metric::write_data_csv(results, 
                                     riskscore_data_path, 
                                     riskscore_data_exists)
  
  return(results)
}
