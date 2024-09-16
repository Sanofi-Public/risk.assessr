test_that("install_package_local works correctly", {
  # toy package for testing install_package_local
  uninstall_package("toyPackage")
  temp_dir <- tempdir()
  toy_pkg_path <- file.path(temp_dir, "toyPackage")
  dir.create(toy_pkg_path)
  writeLines("Package: toyPackage\nVersion: 0.1.0\n", file.path(toy_pkg_path, "DESCRIPTION"))
  
  result <- suppressWarnings(install_package_local(toy_pkg_path))
  expect_true(result)
  # Clean up
  # 
  unlink(temp_dir, recursive = TRUE)
  # uninstall_package("toyPackage")
})

test_that("install_package_local handles errors correctly", {
  
  uninstall_package("invalidPackage")
  temp_dir <- tempdir()
  
  # Create an invalid path to generate an error
  invalid_pkg_path <- file.path(temp_dir, "invalidPackage")
  
  expect_message(
    result <- install_package_local(invalid_pkg_path),
    regexp = "No such file or directory"
  )
  
  expect_false(result)
  # Clean up
  unlink(temp_dir, recursive = TRUE)
})

test_that("install_package_local skips installation if already installed", {
  uninstall_package("toyPackage")
  temp_dir <- tempdir()
  toy_pkg_path <- file.path(temp_dir, "toyPackage")
  dir.create(toy_pkg_path)
  writeLines("Package: toyPackage\nVersion: 0.1.0\n", file.path(toy_pkg_path, "DESCRIPTION"))
  
  # First installation
  install_package_local(toy_pkg_path)
  
  # Second installation should skip
  result <- install_package_local(toy_pkg_path)
  expect_true(result)
  
  # Clean up
  uninstall_package("toyPackage")
  unlink(temp_dir, recursive = TRUE)
  
})
