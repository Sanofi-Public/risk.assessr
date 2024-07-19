#' install package locally with source
#'
#' @param pkg_source_path directory path to R project
#' @param pkg_disp vector with package name for display
#' 
#' @export
install_package_local <- function (pkg_source_path, pkg_disp) {
  message(glue::glue("installing {pkg_disp} locally"))
  tryCatch(
    {
      remotes::install_local(
        pkg_source_path,
        upgrade = "never",
        force = TRUE,
        quiet = TRUE,
        INSTALL_opts = "--with-keep.source"
      )
      message(glue::glue("{pkg_disp} installed locally"))
      return(TRUE)
    },  
    error=function(cond) {
      message(glue::glue("Local installation issue is: {cond}"))
      message(glue::glue("{pkg_disp} not installed locally"))
      return(FALSE)
    })    
}