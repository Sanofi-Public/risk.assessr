#' Modify the DESCRIPTION File in a R Package Tarball
#'
#' This function recreate a `.tar.gz` R package file after modifying its `DESCRIPTION` file
#' by appending Config/build/clean-inst-doc: false parameter.
#'
#' @param tar_file A string representing the path to the `.tar.gz` file that contains the R package.
#' @param package_name A string representing the name of the package, which should match the directory name after extraction.
#'
#' @return A string containing the path to the newly created modified `.tar.gz` file.
#' @export
#'
#' @examples
#' \dontrun{
#'   modified_tar <- modify_description_file("path/to/mypackage.tar.gz", "mypackage")
#'   print(modified_tar)
#'   # Unpack the tar.gz file
#'   contents <- sanofi.risk.metric::unpack_tarball(modified_tar)
#    # Read and display the DESCRIPTION file
#'   description_path <- file.path(contents, "DESCRIPTION")
#'   description_content <- readLines(description_path)
#'   cat(description_content, sep = "\n")
#' }
#'
#' @importFrom utils untar tar
modify_description_file <- function(tar_file, package_name) {
  # Create a temporary directory
  temp_dir <- tempdir()

  tryCatch({
    suppressWarnings({
      untar(tar_file, exdir = temp_dir)
    })
  }, error = function(e) {
    stop("Error in untarring the file: ", e$message)
  })
  

  package_dir <- file.path(temp_dir, package_name)
  
  # Check if the package directory exists
  if (!dir.exists(package_dir)) {
    stop("Package directory not found")
  }
  
  description_file <- file.path(package_dir, "DESCRIPTION")

  if (!file.exists(description_file)) {
    stop("DESCRIPTION file not found in the extracted package directory.")
  }

  # Modify the DESCRIPTION file
  description_content <- readLines(description_file)
  # Check if the line already exists
  if ("Config/build/clean-inst-doc: FALSE" %in% description_content) {
    return(tar_file)
  }

  description_content <- c(description_content, "Config/build/clean-inst-doc: FALSE")
  writeLines(description_content, description_file)

  # Recreate a new tar.gz file
  modified_tar_file <- tempfile(fileext = ".tar.gz")

  current_wd <- getwd()
  setwd(temp_dir)

  tryCatch({
    suppressWarnings({
      tar(modified_tar_file, files = package_name, compression = "gzip", tar = "internal")
    })
  }, error = function(e) {
    setwd(current_wd)  # Ensure we return to the original directory on error
    stop("Error in creating the tar.gz file: ", e$message)
  })
  setwd(current_wd)

  return(modified_tar_file)
}

