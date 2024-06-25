#' Creates package scaffold
#'
#' @param dp data path and name for the package. 
#' @param pkg_disp package name for display

set_up_pkg <- function(dp, pkg_disp) {
  
  build_vignettes <- TRUE
  
  suppressWarnings(pkg_source_path <-   
                     sanofi.risk.metric::unpack_tarball(dp, pkg_disp))
  
  if (length(pkg_source_path) == 0) {
    package_installed <- FALSE
    results <- ""
    pkg_source_path <- ""
    out_dir <- ""
    build_vignettes <- ""
  } else { 
    if (fs::file_exists(pkg_source_path)) {
      package_installed <- 
        sanofi.risk.metric::install_package_local(pkg_source_path, 
                                                  pkg_disp)
    }  
  } 

  if (package_installed == TRUE ) {	
    
    # get home directory
    
    pkg_desc <- get_pkg_desc(pkg_source_path, 
                             fields = c("Package", 
                                        "Version"))
    pkg_name <- pkg_desc$Package
    pkg_ver <- pkg_desc$Version
    
    out_dir <- "no audit trail"
    
    message("out_dir is ", out_dir)
    
    metadata <- sanofi.risk.metric::get_risk_metadata()
    
    results <- sanofi.risk.metric::create_empty_results(pkg_name,
                                                        pkg_ver,
                                                        pkg_source_path,
                                                        metadata)
  } else {
    message(glue::glue("local package install for {pkg_disp} unsuccessful"))
  } 
  install_list <- list(
    build_vignettes = build_vignettes,
    package_installed = package_installed,
    results = results,
    pkg_source_path = pkg_source_path,
    out_dir = out_dir
  )
  return(install_list)
}