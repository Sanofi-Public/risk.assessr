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
#' @details The function if the specified file exists and has a valid .tar extension.
#' It then attempts to list the contents of the .tar file using \code{utils::untar}. If the file is empty or
#' any error occurs during the extraction, the function stops and returns an error message. If the 'vignettes'
#' folder exists and contains at least one .Rmd file, the function returns \code{TRUE}. Otherwise, it returns \code{FALSE}.
#'
#' @examples
#' \dontrun{
#'   tar_file <- "path/to/your/package.tar.gz"
#'   result <- contains_vignette_folder(tar_file)
#'   print(result)
#' }
#' 
#' @import utils
#' @export
contains_vignette_folder <- function(tar_file) {
  
  if (!file.exists(tar_file)) {
    stop("File does not exist. Please provide a valid .tar file.")
  }
  
  # Check if the file has a .tar extension
  if (!grepl("\\.tar$", tar_file) && !grepl("\\.tar\\.gz$", tar_file) && !grepl("\\.tgz$", tar_file) &&
      !grepl("\\.tar\\.bz2$", tar_file) && !grepl("\\.tbz2$", tar_file)) {
    stop("Unsupported file type. Please provide a .tar file.")
  }
  
  # Try to list the contents of the .tar file, handling any errors
  file_list <- tryCatch(
    {
      suppressWarnings(utils::untar(tar_file, list = TRUE))
    },
    error = function(e) {
      stop("Error in untar: ", conditionMessage(e))
    }
  )
  
  # If the tar file is empty, return FALSE
  if (length(file_list) == 0) {
    stop("Error in untar: file is empty")
  }
  
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
