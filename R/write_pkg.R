#' write package
#'  
#' @description write package data for risk metrics
#' 
#' @param
#' 
#' #' @examples
#' \dontrun{
#' 
#' }
#' 
#' @export
#'
# write_pkg <- function(  ) {
# 
#   if (out_dir != "no audit trail") {
#     checkmate::assert_string(out_dir)
#     checkmate::assert_directory_exists(out_dir)
#   }
#   checkmate::check_logical(riskscore_data_exists)
#   checkmate::assert_string(riskscore_data_path)
#   checkmate::check_logical(overwrite)
#   checkmate::assert_string(comments)
# 
# # Get package name and version
#     pkg_desc <- get_pkg_desc(pkg_source_path, fields = c("Package", "Version"))
#     pkg_name <- pkg_desc$Package
#     pkg_ver <- pkg_desc$Version
#     pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
# 
#   if (out_dir != "no audit trail") {
#     # Add pkg_name sub-directory and create if it doesn't exist
# 
#     out_dir <- file.path(out_dir, pkg_name_ver)
#     if (!fs::dir_exists(out_dir)) fs::dir_create(out_dir)
#     out_path <- sanofi.risk.metric::get_result_path(out_dir, "covr.rds")
#     sanofi.risk.metric::check_exists_and_overwrite(out_path, overwrite)
#   }
# 
#    if (out_dir == "no audit trail") {
#      message(glue::glue("not writing code coverage results for {pkg_name}"))
#    } else {  
#    # write results to RDS
#      saveRDS(
#        res_cov,
#        sanofi.risk.metric::get_result_path(out_dir, "covr.rds")
#      )
#      message(glue::glue("writing code coverage results for {pkg_name}"))
#    }  
#     
#   # write traceability matrix  
#   if (results_dir == "no audit trail") {
#     message(glue::glue("not writing traceability matrix for {pkg_name} "))
#   } else {
#     write_tm_rds(tm, pkg_name, results_dir)
# 
#     # write tm to excel
#     write_tm_excel(tm, pkg_name, results_dir)
# 
#     message(glue::glue("traceability matrix for {pkg_name} successful"))
#   }
# 
#   # write results to RDS
#   if (out_dir == "no audit trail") {
#     message(glue::glue("not writing rcmdcheck results for {pkg_name}"))
#   } else {
#     saveRDS(
#       res_check,
#       get_result_path(out_dir, "check.rds")
#     )
#     message(glue::glue("writing rcmdcheck results for {pkg_name}"))
#   }
# 
# 
#   if (out_dir == "no audit trail") {
#     message(glue::glue("not writing rcmdcheck results for {pkg_name}"))
#   } else {
#     # write data to csv
#     sanofi.risk.metric::write_data_csv(results,
#                                        riskscore_data_path,
#                                        riskscore_data_exists)
#   }
# }