#' assess_export_help
#'
#' @param pkg_name - name of the package 
#' @param pkg_source_path - pkg_source_path - source path for install local
#'
#' @return - export_help_score - variable with score
#' @export
#'
assess_export_help <- function(pkg_name, pkg_source_path) {
  
  exported_functions <- getNamespaceExports(pkg_name)
  db <- tools::Rd_db(pkg_name, pkg_source_path)
  missing_docs <- setdiff(exported_functions, gsub("\\.Rd$", "", names(db)))
  if (length(missing_docs) == 0) {
    message(glue::glue("All exported functions have corresponding help files in {pkg_name}"))
    export_help_score <- 1
  } else {
    message(glue::glue("The following exported functions are missing help files in {pkg_name}"))
    print(missing_docs)
    export_help_score <- 0
  }
  return(export_help_score)
}

#' Run all relevant documentation riskmetric checks
#'
#' @param pkg_name name of the package
#' @param pkg_source_path path to package source code (untarred)
#'
#' @returns raw riskmetric outputs
#'  
#' @export
#'
doc_riskmetric <- function(pkg_name, pkg_source_path) {
  
  export_help <- 
    sanofi.risk.metric::assess_export_help(pkg_name, pkg_source_path)
  
  doc_scores <- list(
    export_help = export_help
  )
  
  # passess <- riskmetric::pkg_assess(
  #   pref,
  #   assessments = list(
  #     riskmetric::assess_export_help, 
  #     riskmetric::assess_has_bug_reports_url,
  #     riskmetric::assess_size_codebase, 
  #     riskmetric::assess_has_maintainer,
  #     riskmetric::assess_has_examples,
  #     riskmetric::assess_has_news,
  #     riskmetric::assess_has_source_control, # R/pkg_ref_cache_source_control_url.R
  #     riskmetric::assess_has_vignettes,
  #     riskmetric::assess_has_website,
  #     riskmetric::assess_license, 
  #     riskmetric::assess_news_current
  #   )
  # )
  
  return(doc_scores)
}