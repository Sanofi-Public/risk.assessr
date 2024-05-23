#' Check for Vignette Folder and .Rmd Files in a .tar File
#'
#' This function checks if a given .tar file contains a 'vignette' folder
#' and if there is at least one .Rmd file within that folder.
#'
#' @param tar_file A character string specifying the path to the .tar file to be checked.
#' 
#' @return A logical value: \code{TRUE} if the 'vignette' folder exists and contains at least one .Rmd file,
#' \code{FALSE} otherwise.
#'
#' @examples
#' \dontrun{
#'   tar_file <- "path/to/your/package.tar.gz"
#'   result <- contains_vignette_folder(tar_file)
#'   print(result)
#' }
#' 
#' @export
contains_vignette_folder <- function(tar_file) {
  
  # List the contents of the .tar file
  file_list <- untar(tar_file, list = TRUE)
  
  # Normalize file paths to use forward slashes for consistency
  normalized_paths <- gsub("\\\\", "/", file_list)
  
  # Extract paths that contain the vignette folder
  vignette_folder <- grep("/vignette(/|$)", normalized_paths, value = TRUE)
  
  # Check if the vignette folder exists
  if (length(vignette_folder) == 0) {
    return(FALSE)
  }
  
  # Check for .Rmd files specifically within the vignette folder
  vignette_rmd_files <- grep("/vignette/[^/]+\\.Rmd$", normalized_paths, value = TRUE)
  
  # Determine if there are any .Rmd files in the vignette folder
  has_rmd_in_vignette <- length(vignette_rmd_files) > 0
  
  return(has_rmd_in_vignette)
}