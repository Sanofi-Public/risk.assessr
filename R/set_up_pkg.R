#' Creates information on package installation
#'
#' @param dp data path and name for the package. 
#' 
#' @return list with local package install
#' 
#' @export
set_up_pkg <- function(dp) {
  
  build_vignettes <- TRUE
  
  suppressWarnings(pkg_source_path <-   
                     sanofi.risk.metric::unpack_tarball(dp))
  
  # check for vignettes folder
  bv_result <- sanofi.risk.metric::contains_vignette_folder(dp)
  
  #set up build vignettes for R CMD check
  if (bv_result == FALSE) {
    build_vignettes <- TRUE
  } else {
    build_vignettes <- FALSE
  }
  
  if (length(pkg_source_path) == 0) {
    package_installed <- FALSE
    results <- ""
    pkg_source_path <- ""
    out_dir <- ""
    build_vignettes <- ""
  } else { 
    if (fs::file_exists(pkg_source_path)) {
      package_installed <- 
        sanofi.risk.metric::install_package_local(pkg_source_path)
    }  
  } 
  
  if (package_installed == TRUE ) {	
    
    rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)
  } 
  install_list <- list(
    build_vignettes = build_vignettes,
    package_installed = package_installed,
    pkg_source_path = pkg_source_path,
    rcmdcheck_args = rcmdcheck_args
  )
  return(install_list)
}
