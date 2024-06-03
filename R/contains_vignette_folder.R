library(utils)
#' Check for Vignette Folder and .Rmd Files in a .tar File
#'
#' This function checks if a given .tar file contains a 'vignettes' folder
#' and if there is at least one .Rmd file within that folder.
#'
#' @param tar_file A character string specifying the path to the .tar file to be checked.
#' 
#' @return A logical value: \code{TRUE} if the 'vignettes' folder exists and contains at least one .Rmd file,
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
  
  # Check if the file has a .tar extension
  if (!grepl("\\.tar$", tar_file) && !grepl("\\.tar\\.gz$", tar_file) && !grepl("\\.tgz$", tar_file) &&
      !grepl("\\.tar\\.bz2$", tar_file) && !grepl("\\.tbz2$", tar_file)) {
    stop("Unsupported file type. Please provide a .tar file.")
  }
  
  # List the contents of the .tar file
  file_list <- utils::untar(tar_file, list = TRUE)
  
  # Normalize file paths to use forward slashes for consistency
  normalized_paths <- gsub("\\\\", "/", file_list)
  
  # Extract paths that contain the vignettes folder
  vignette_folder <- grep("/vignettes(/|$)", normalized_paths, value = TRUE)
  
  # Check if the vignettes folder exists
  if (length(vignette_folder) == 0) {
    return(FALSE)
  }
  
  # Check for .Rmd files specifically within the vignette folder
  vignette_rmd_files <- grep("/vignettes/[^/]+\\.Rmd$", normalized_paths, value = TRUE)
  
  # Determine if there are any .Rmd files in the vignette folder
  has_rmd_in_vignette <- length(vignette_rmd_files) > 0
  
  return(has_rmd_in_vignette)
}
