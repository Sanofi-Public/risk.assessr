#' Create weights profile
#' 
#' @description This creates a specific weights profile 
#' for all risk metrics
#'
#' @return - numeric vector with weights profile
#' 
#' @examples
#' \donttest{
#' create_weights_profile()
#'}
#' @export
create_weights_profile <- function() {
  weights <- c(
    has_bug_reports_url = .2,
    license = .1,
    has_examples = .4,
    has_maintainer = .2,
    has_news = .2,
    size_codebase = .2,
    has_source_control = .1,
    has_vignettes = .4,
    has_website = .4,
    news_current = .2,
    export_help = .2,
    export_calc = .2,
    check = .75,
    covr = .6,
    dep_score = .5,
    revdep_score = .1
  )
  return(weights)
}