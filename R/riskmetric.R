#' Run all relevant riskmetric checks
#'
#' @param pkg_source_path path to package source code (untarred)
#'
#' @returns raw riskmetric outputs
#'  
#' @export
#'
pkg_riskmetric <- function(pkg_source_path) {
  
  pref <- riskmetric::pkg_ref(pkg_source_path)
  
  passess <- riskmetric::pkg_assess(
    pref,
    assessments = list(
      riskmetric::assess_export_help, 
      riskmetric::assess_has_bug_reports_url,
      riskmetric::assess_size_codebase, 
      riskmetric::assess_has_maintainer,
      riskmetric::assess_has_examples,
      riskmetric::assess_has_news,
      riskmetric::assess_has_source_control, # R/pkg_ref_cache_source_control_url.R
      riskmetric::assess_has_vignettes,
      riskmetric::assess_has_website,
      riskmetric::assess_license, 
      riskmetric::assess_news_current
    )
  )
  
  pscore <- riskmetric::pkg_score(passess)
  
  return(pscore)
}