
modify_description_file <- function(tar_file, package_name) {
  # Create a temporary directory
  temp_dir <- tempdir()
  
  # Try to untar the file and stop if there's an error
  tryCatch({
    untar(tar_file, exdir = temp_dir)
  }, error = function(e) {
    stop("Error in untarring the file: ", e$message)
  })
  
  package_dir <- file.path(temp_dir, package_name)
  description_file <- file.path(package_dir, "DESCRIPTION")
  
  if (!file.exists(description_file)) {
    stop("DESCRIPTION file not found in the extracted package directory.")
  }
  
  # Modify the DESCRIPTION file
  description_content <- readLines(description_file)
  description_content <- c(description_content, "Config/build/clean-inst-doc: false")
  writeLines(description_content, description_file)
  
  # Recreate a new tar.gz file
  modified_tar_file <- tempfile(fileext = ".tar.gz")
  
  current_wd <- getwd()
  setwd(temp_dir)
  
  tryCatch({
    tar(modified_tar_file, files = package_name, compression = "gzip", tar = "internal")
  }, error = function(e) {
    setwd(current_wd)  # Ensure we return to the original directory on error
    stop("Error in creating the tar.gz file: ", e$message)
  })
  setwd(current_wd)
  
  return(modified_tar_file)
}


