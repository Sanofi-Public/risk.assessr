#' update results doc_metrics
#' 
#' @description This updates results list
#' for documentation risk metrics
#'
#' @param results list with results
#' @param doc_scores results from documentation risk metrics
#' 
#' @return - list with updated risk result values
#' 
#' @export
#'
update_results_doc_scores <- function(results,
                                      doc_scores) {
  
  results$has_bug_reports_url <- doc_scores$has_bug_reports_url
  results$license <- doc_scores$license
  results$has_examples <- doc_scores$has_examples
  results$has_maintainer <- doc_scores$has_maintainer
  results$size_codebase <- doc_scores$size_codebase 
  results$has_news <- doc_scores$has_news
  results$has_source_control <- doc_scores$has_source_control
  results$has_vignettes <- doc_scores$has_vignettes
  results$has_website <- doc_scores$has_website
  results$news_current <- doc_scores$news_current
  results$export_help <- doc_scores$export_help 
  
  return(results)
}