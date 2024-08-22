test_that("modify_description_file modifies DESCRIPTION correctly", {
  # Construct the path to the tar.gz file in the inst/ folder
  tar_file_path <- file.path("inst", "test-data", "test.package.0001_0.1.0.tar.gz")
  package_name <- "test.package.0001"
  
  # Check if the file exists before attempting to download
  if (!file.exists(tar_file_path)) {
    stop("The tar file does not exist at the specified path.")
  }
  
  # Create a temporary file to store the downloaded package
  file_name <- basename(tar_file_path) # Use the base name for temporary file
  temp_file <- file.path(tempdir(), file_name)
  
  # Copy the file to the temporary file instead of downloading it
  file.copy(tar_file_path, temp_file, overwrite = TRUE)
  
  # Verify that the copy was successful
  if (!file.exists(temp_file)) {
    stop("File copy failed: temporary file not found.")
  }
  
  # Run the function to modify the DESCRIPTION file
  modified_tar_file <- modify_description_file(temp_file, package_name)
  
  # Extract the modified tarball to a temporary directory
  temp_dir <- tempdir()
  untar(modified_tar_file, exdir = temp_dir)
  
  # Check if the DESCRIPTION file exists in the modified package directory
  package_dir <- file.path(temp_dir, package_name)
  
  if (!dir.exists(package_dir)) {
    stop("Package directory not found after untarring.")
  }
  
  description_file <- file.path(package_dir, "DESCRIPTION")
  expect_true(file.exists(description_file))
  
  # Check if the DESCRIPTION file contains the new line
  description_content <- readLines(description_file)
  expect_true("Config/build/clean-inst-doc: false" %in% description_content)
})

