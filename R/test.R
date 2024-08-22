# 
# modify_description_file <- function(tar_file, package_name) {
#   # Create a temporary directory
#   temp_dir <- tempdir()
#   
#   # Try to untar the file and stop if there's an error
#   tryCatch({
#     untar(tar_file, exdir = temp_dir)
#   }, error = function(e) {
#     stop("Error in untarring the file: ", e$message)
#   })
#   
#   package_dir <- file.path(temp_dir, package_name)
#   description_file <- file.path(package_dir, "DESCRIPTION")
#   
#   if (!file.exists(description_file)) {
#     stop("DESCRIPTION file not found in the extracted package directory.")
#   }
#   
#   # Modify the DESCRIPTION file
#   description_content <- readLines(description_file)
#   description_content <- c(description_content, "Config/build/clean-inst-doc: false")
#   writeLines(description_content, description_file)
#   
#   # Recreate a new tar.gz file
#   modified_tar_file <- tempfile(fileext = ".tar.gz")
#   
#   current_wd <- getwd()
#   setwd(temp_dir)
#   tryCatch({
#     tar(modified_tar_file, files = package_name, compression = "gzip", tar = "internal")
#   }, error = function(e) {
#     setwd(current_wd)  # Ensure we return to the original directory on error
#     stop("Error in creating the tar.gz file: ", e$message)
#   })
#   setwd(current_wd)
#   
#   return(modified_tar_file)
# }
# 
# assess_pkg_r_package <- function(package_name, version=NA) {
# 
#   package_data <- sanofi.risk.metric::get_tar_package(package_name, version=version)
# 
#   if (is.null(package_data$error)) {
#     package_url <- package_data$tar_link
#   } else {
#     return(package_data)
#   }
# 
#   # Create a temporary file to store the downloaded package
#   file_name <- basename(package_url)
# 
#   # Create a full path for the temporary file using the extracted filename
#   temp_file <- file.path(tempdir(), file_name)
# 
#   # Download the package to the temporary file
#   download.file(package_url, temp_file, mode = "wb")
# 
#   modified_tar_file <- modify_description_file(temp_file, package_name)
# 
#   # Set up the package using the temporary file
#   install_list <- sanofi.risk.metric::set_up_pkg(modified_tar_file)
# 
#   # Extract information from the installation list
#   build_vignettes <- install_list$build_vignettes
#   package_installed <- install_list$package_installed
#   pkg_source_path <- install_list$pkg_source_path
#   rcmdcheck_args <- install_list$rcmdcheck_args
# 
#   # Check if the package was installed successfully
#   if (package_installed == TRUE) {
#     # Assess the package
#     assess_package <- sanofi.risk.metric::assess_pkg(pkg_source_path, rcmdcheck_args)
#     # Output the assessment result
#   } else {
#     message("Package installation failed.")
#   }
# 
#   # Clean up: remove the temporary file
#   unlink(temp_file)
#   return(assess_package)
# }
# 
# 
# result <- assess_pkg_r_package("dplyr")
# 
# 
# 
# 
# 
# 
# 
# 
