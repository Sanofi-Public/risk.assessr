#' write package
#'  
#' @description write package data for risk metrics
#' 
#' @param assess_package - nested list with risk metrics
#' @param results_dir - path for writing results
#' @param overwrite Logical (T/F). Whether or not to overwrite existing risk metric results
#' @param comments - comments about the batch run
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
#'   
#'   assess_package$results$comments <- "test run"
#'                                     
#'   sanofi.risk.metric::write_pkg(assess_package, 
#'                                 results_dir = "no audit trail")                                  
#' }
#' }
#' 
#' @export
#'
write_pkg <- function(assess_package, 
                      results_dir,
                      overwrite = TRUE
                      ) {

  # if (results_dir != "no audit trail") {
  #   checkmate::assert_string(results_dir)
  #   checkmate::assert_directory_exists(results_dir)
  # }
  checkmate::check_class(assess_package, "list")
  checkmate::check_logical(overwrite)
  

  
  # check if risk score data exists and set up path to risk score data
  riskscore_data_list <- 
    sanofi.risk.metric::check_riskscore_data_location(results_dir)
    
  riskscore_data_path <- riskscore_data_list$riskscore_data_path
    
  message("data path is ", riskscore_data_path)
    
  riskscore_data_exists <- riskscore_data_list$riskscore_data_exists
    
  message("data path exists ", riskscore_data_exists)
  
  results_dir <- riskscore_data_list$results_dir
  
  message("results data path is ", results_dir)
  
  results_dir_exists <- riskscore_data_list$results_dir_exists

  message("results data path exists ", results_dir_exists)
  
  # set up pkg_source_path
  pkg_source_path <- assess_package$results$pkg_source_path
  
  # Get package name and version
  pkg_desc <- get_pkg_desc(pkg_source_path, 
                           fields = c("Package", 
                                      "Version"))
  pkg_name <- pkg_desc$Package
  pkg_ver <- pkg_desc$Version
  pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)

  if (results_dir != "no audit trail") {
    # Add pkg_name sub-directory and create if it doesn't exist

    results_dir <- file.path(results_dir, pkg_name_ver)
    if (!fs::dir_exists(results_dir)) fs::dir_create(results_dir)
    results_path <- sanofi.risk.metric::get_result_path(results_dir, "covr.rds")
    sanofi.risk.metric::check_exists_and_overwrite(results_path, overwrite)
  }

  if (results_dir == "no audit trail") {
     message(glue::glue("not writing code coverage results for {pkg_name}"))
  } else {
  # write results to RDS
    saveRDS(
      assess_package$covr_list$res_cov,
      sanofi.risk.metric::get_result_path(results_dir, "covr.rds")
    )
    message(glue::glue("writing code coverage results for {pkg_name}"))
  }

  # write traceability matrix
  if (results_dir == "no audit trail") {
    message(glue::glue("not writing traceability matrix for {pkg_name} "))
  } else {
    write_tm_rds(assess_package$tm, pkg_name, results_dir)

    # write tm to excel
    write_tm_excel(assess_package$tm, pkg_name, results_dir)

    message(glue::glue("traceability matrix for {pkg_name} successful"))
  }

  # write results to RDS
  if (results_dir == "no audit trail") {
    message(glue::glue("not writing rcmdcheck results for {pkg_name}"))
  } else {
    saveRDS(
      assess_package$check_list$res_check,
      get_result_path(results_dir, "check.rds")
    )
    message(glue::glue("writing rcmdcheck results for {pkg_name}"))
  }


  if (results_dir == "no audit trail") {
    message(glue::glue("not writing risk metric data results for {pkg_name}"))
  } else {
    # write data to csv
    sanofi.risk.metric::write_data_csv(assess_package$results,
                                       riskscore_data_path,
                                       riskscore_data_exists)
  }
}