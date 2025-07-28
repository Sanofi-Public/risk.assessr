#' Create risk profile
#' 
#' @description This creates a risk profile 
#' for all risk metrics
#'
#' @return - list with risk profile values
#' @keywords internal
create_risk_profile <- function() {
  
  risk_profile <- list(
    high_risk_threshold = 1,
    medium_risk_threshold = .35,
    low_risk_threshold = .25
    
  )
  return(risk_profile)
}