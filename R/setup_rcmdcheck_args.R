#' set up rcmdcheck arguments
#' 
#' @description This sets up rcmdcheck arguments
#' @details {Some packages need to have build vignettes as a 
#' build argument as their vignettes structure is inst/doc or inst/docs} 
#' 
#' @param check_type basic R CMD check type - "1" CRAN R CMD check_type - "2"
#' @param build_vignettes Logical (T/F). Whether or not to build vignettes
#' 
#' @return - list with rcmdcheck arguments
#' 
#' @export
#'
setup_rcmdcheck_args <- function(check_type = "1", 
                                 build_vignettes) {
if (check_type == "1") {
  rcmdcheck_args = list(
    timeout = Inf,
    args = c("--no-manual"),
    env = c(`_R_CHECK_FORCE_SUGGESTS_` = "FALSE"),
    quiet = FALSE
  )
} else { 
  
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
}  
  return(rcmdcheck_args)
}

  
