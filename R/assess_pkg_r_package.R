


assess_pkg_r_package <- function(package_name, version=NA) {

  package_data <- sanofi.risk.metric::get_tar_package(package_name, version=version)
  
  if (is.null(package_data$error)) {
    package_url <- package_data$tar_link
  } else {
    return(package_data)
  }

  # Create a temporary file to store the downloaded package
  temp_file <- tempfile(fileext = ".tar.gz")

  # Download the package to the temporary file
  download.file(package_url, temp_file, mode = "wb")

  # Set up the package using the temporary file
  install_list <- sanofi.risk.metric::set_up_pkg(temp_file)

  # Extract information from the installation list
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args

  # Check if the package was installed successfully
  if (package_installed == TRUE) {
    # Assess the package
    assess_package <- sanofi.risk.metric::assess_pkg(pkg_source_path, rcmdcheck_args)
    # Output the assessment result
  } else {
    message("Package installation failed.")
  }

  # Clean up: remove the temporary file
  unlink(temp_file)
  return(assess_package)
}

# result <- assess_pkg_r_package("mixOmics") # actual CMD check no passing for this package
# 
# result <- assess_pkg_r_package("dplyr", version="1.1.4")
# result <- assess_pkg_r_package("admiral")
# result <- assess_pkg_r_package("sdtmchecks")
# 
# # working
# result <- assess_pkg_r_package("here")








