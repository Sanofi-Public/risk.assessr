test_that("Unpacking a tar file works correctly", {
  pkg <- system.file("test-data/here-1.0.1.tar.gz", 
                     package = "sanofi.risk.assessr")
  
  extract_files <-  
    suppressWarnings(sanofi.risk.assessr::unpack_tarball(pkg))
  
  expect_true(checkmate::checkVector(extract_files))
  
  expect_true(checkmate::check_class(extract_files, "fs_path"))
  
  expect_true(checkmate::check_string(extract_files))
  
  expect_true(checkmate::check_directory_exists(extract_files))
})

test_that("Unpacking an empty tar file works correctly", {
  pkg <- system.file("test-data/empty.tar.gz", 
                     package = "sanofi.risk.assessr")
  
  extract_files <-  
    suppressWarnings(sanofi.risk.assessr::unpack_tarball(pkg))
  
  expect_true(checkmate::checkVector(extract_files))
  
  expect_true(checkmate::check_class(extract_files, "fs_path"))
  
  expect_identical(checkmate::check_string(extract_files), 
                   "Must have length 1"
  )
  
  expect_identical(checkmate::check_directory_exists(extract_files), 
                   "No directory provided"
  )
})  