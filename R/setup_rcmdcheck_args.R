build_vignettes <- FALSE

#' set up rcmdcheck arguments
#' 
#' @description This sets up rcmdcheck arguments
#' @details {Some packages need to have build vignettes as a 
#' build argument as their vignettes structure is inst/doc or inst/docs} 
#' 
#' @param build_vignettes Logical (T/F). Whether or not to build vignettes
#' 
#' @return - list with rcmdcheck arguments
#' 
#' @export
#'
setup_rcmdcheck_args <- function(build_vignettes) {
if (build_vignettes == FALSE) {
  rcmdcheck_args = list(
    timeout = Inf,
    args = c("--ignore-vignettes", 
             "--no-vignettes", 
             "--as-cran",
             "--no-manual"),
    build_args = "--no-build-vignettes",
    env = c(`_R_CHECK_FORCE_SUGGESTS_` = "FALSE"),
    quiet = FALSE
  )
} else {
  rcmdcheck_args = list(
    timeout = Inf,
    args = c("--ignore-vignettes", 
             "--no-vignettes", 
             "--as-cran",
             "--no-manual"),
    env = c(`_R_CHECK_FORCE_SUGGESTS_` = "FALSE"),
    quiet = FALSE
  )
}
  return(rcmdcheck_args)
}

  
