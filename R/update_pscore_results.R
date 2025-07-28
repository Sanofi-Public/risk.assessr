#' update pscore results
#' 
#' @description This updates results list
#' for pscore risk metrics
#'
#' @param results list with results
#' @param pscore results from open source risk metrics
#' 
#' @return - list with updated risk result values
#' @keywords internal
update_pscore_results <- function(results,
                                  pscore) {

  results$has_bug_reports_url <- pscore$has_bug_reports_url
  results$license <- pscore$license
  results$has_examples <- pscore$has_examples
  results$has_maintainer <- pscore$has_maintainer
  
  # reverse size_codebase scores to fix issue
  #  pharmaR/riskmetric#330
  
  pscore$size_codebase <- 1 - pscore$size_codebase
  
  results$size_codebase <- pscore$size_codebase 
  results$has_news <- pscore$has_news
  results$has_source_control <- pscore$has_source_control
  results$has_vignettes <- pscore$has_vignettes
  results$has_website <- pscore$has_website
  results$news_current <- pscore$news_current
  results$export_help <- pscore$export_help 
  
  return(results)
}