test_that("contains_vignette_folder handles non-existent file", {
  expect_error(contains_vignette_folder("nonexistent_file.tar.gz"), "File does not exist")
})

test_that("contains_vignette_folder handles non-existent file", {
  expect_error(contains_vignette_folder("eezrfrfrr"), "File does not exist")
})

test_that("empty folder", {
  
  # Temporary directory for testing
  temp_dir <- tempdir()
  
  # Define the folder structure using the temporary directory
  main_dir <- file.path(temp_dir, "old_structure")
  
  # Step 1: Create the Folder Structure and Multiple .Rmd Files
  dir.create(main_dir, showWarnings = FALSE)
  
  # Step 2: Create the .tar Archive
  tar_file <- file.path(temp_dir, "old_structure.tar.gz")
  tar(tar_file, files = main_dir)
  
  # Ensure cleanup happens even if the test fails
  defer(unlink(main_dir, recursive = TRUE))
  defer(unlink(tar_file))
  
  # Check that the tar file contains .Rmd files
  expect_error(contains_vignette_folder(tar_file), "Error in untar: file is empty")
})

test_that("correct repo with Non-tar file throws an error", {

  # Temporary directory for testing
  temp_dir <- tempdir()

  # Define the folder structure using the temporary directory
  main_dir <- file.path(temp_dir, "got_vignette")
  sub_dir <- file.path(main_dir, "vignettes")

  # Step 1: Create the Folder Structure and Multiple .Rmd Files
  dir.create(main_dir, showWarnings = FALSE)
  dir.create(sub_dir, showWarnings = FALSE)

  for (i in 1:5) {
    rmd_file <- file.path(sub_dir, paste0("sample_", i, ".Rmd"))
    writeLines(c(paste0("# Sample R Markdown ", i), "", "This is a sample R Markdown file."), rmd_file)
  }

  # Step 2: Create the .tar Archive
  tar_file <- file.path(temp_dir, "got_vignette.teeeeeeear")
  tar(tar_file, files = main_dir)

  # Ensure cleanup happens even if the test fails
  defer(unlink(main_dir, recursive = TRUE))
  defer(unlink(tar_file))

  # Check that the tar file contains .Rmd files
  expect_error(contains_vignette_folder(tar_file), "Unsupported file type. Please provide a .tar file.")
})



test_that("test on package with vignette folder", {

  # Temporary directory for testing
  temp_dir <- tempdir()

  # Define the folder structure using the temporary directory
  main_dir <- file.path(temp_dir, "got_vignette")
  sub_dir <- file.path(main_dir, "vignettes")

  # Step 1: Create the Folder Structure and Multiple .Rmd Files
  dir.create(main_dir, showWarnings = FALSE)
  dir.create(sub_dir, showWarnings = FALSE)

  for (i in 1:5) {
    rmd_file <- file.path(sub_dir, paste0("sample_", i, ".Rmd"))
    writeLines(c(paste0("# Sample R Markdown ", i), "", "This is a sample R Markdown file."), rmd_file)
  }

  # Step 2: Create the .tar Archive
  tar_file <- file.path(temp_dir, "got_vignette.tar.gz")
  tar(tar_file, files = main_dir)

  # Ensure cleanup happens even if the test fails
  defer(unlink(main_dir, recursive = TRUE))
  defer(unlink(tar_file))

  # Check that the tar file contains .Rmd files
  expect_true(contains_vignette_folder(tar_file))
  expect_silent(contains_vignette_folder(tar_file))
})


test_that("test on package without vignette folder", {

  # Temporary directory for testing
  temp_dir <- tempdir()

  # Define the folder structure using the temporary directory
  main_dir <- file.path(temp_dir, "no_vignette")
  sub_dir <- file.path(main_dir, "vignettezzzzzz")

  # Step 1: Create the Folder Structure and Multiple .Rmd Files
  dir.create(main_dir, showWarnings = FALSE)
  dir.create(sub_dir, showWarnings = FALSE)

  for (i in 1:5) {
    rmd_file <- file.path(sub_dir, paste0("sample_", i, ".Rmd"))
    writeLines(c(paste0("# Sample R Markdown ", i), "", "This is a sample R Markdown file."), rmd_file)
  }

  # Step 2: Create the .tar Archive
  tar_file <- file.path(temp_dir, "got_vignette.tar.gz")
  tar(tar_file, files = main_dir)

  # Ensure cleanup happens even if the test fails
  defer(unlink(main_dir, recursive = TRUE))
  defer(unlink(tar_file))

  # Check that the tar file contains .Rmd files
  expect_false(contains_vignette_folder(tar_file))
  expect_silent(contains_vignette_folder(tar_file))
})


test_that("test on package with vignette folder but no .rmd file", {

  # Temporary directory for testing
  temp_dir <- tempdir()

  # Define the folder structure using the temporary directory
  main_dir <- file.path(temp_dir, "no_vignette")
  sub_dir <- file.path(main_dir, "vignettezzzzzz")

  # Step 1: Create the Folder Structure and Multiple .Rmd Files
  dir.create(main_dir, showWarnings = FALSE)
  dir.create(sub_dir, showWarnings = FALSE)

  # Step 2: Create the .tar Archive
  tar_file <- file.path(temp_dir, "got_vignette.tar.gz")
  tar(tar_file, files = main_dir)

  # Ensure cleanup happens even if the test fails
  defer(unlink(main_dir, recursive = TRUE))
  defer(unlink(tar_file))

  # Check that the tar file contains .Rmd files
  expect_false(contains_vignette_folder(tar_file))
  expect_silent(contains_vignette_folder(tar_file))
})



test_that("test on package with inst/doc and .Rmd", {

  # Temporary directory for testing
  temp_dir <- tempdir()

  # Define the folder structure using the temporary directory
  main_dir <- file.path(temp_dir, "old_structure")
  sub_dir <- file.path(main_dir, "inst")
  subsub_dir <- file.path(sub_dir, "doc")

  # Step 1: Create the Folder Structure and Multiple .Rmd Files
  dir.create(main_dir, showWarnings = FALSE)
  dir.create(sub_dir, showWarnings = FALSE)
  dir.create(subsub_dir, showWarnings = FALSE)

  for (i in 1:5) {
    rmd_file <- file.path(subsub_dir, paste0("sample_", i, ".Rmd"))
    writeLines(c(paste0("# Sample R Markdown ", i), "", "This is a sample R Markdown file."), rmd_file)
  }

  # Step 2: Create the .tar Archive
  tar_file <- file.path(temp_dir, "old_structure.tar.gz")
  tar(tar_file, files = main_dir)

  # Ensure cleanup happens even if the test fails
  defer(unlink(main_dir, recursive = TRUE))
  defer(unlink(tar_file))

  # Check that the tar file contains .Rmd files
  expect_false(contains_vignette_folder(tar_file))
  expect_silent(contains_vignette_folder(tar_file))
})



test_that("test on package with inst/doc and no .Rmd", {

  # Temporary directory for testing
  temp_dir <- tempdir()

  # Define the folder structure using the temporary directory
  main_dir <- file.path(temp_dir, "old_structure")
  sub_dir <- file.path(main_dir, "inst")
  subsub_dir <- file.path(sub_dir, "doc")

  # Step 1: Create the Folder Structure and Multiple .Rmd Files
  dir.create(main_dir, showWarnings = FALSE)
  dir.create(sub_dir, showWarnings = FALSE)
  dir.create(subsub_dir, showWarnings = FALSE)

  # Step 2: Create the .tar Archive
  tar_file <- file.path(temp_dir, "old_structure.tar.gz")
  tar(tar_file, files = main_dir)

  # Ensure cleanup happens even if the test fails
  defer(unlink(main_dir, recursive = TRUE))
  defer(unlink(tar_file))

  # Check that the tar file contains .Rmd files
  expect_false(contains_vignette_folder(tar_file))
  expect_silent(contains_vignette_folder(tar_file))
})




test_that("test on package with both inst/doc and vignette with .Rmd", {
  
  # Temporary directory for testing
  temp_dir <- tempdir()
  
  # Define the folder structure using the temporary directory
  main_dir <- file.path(temp_dir, "old_structure")
  # vignettes
  sub_dir_vignette <- file.path(main_dir, "vignettes")
  
  # inst/doc
  sub_dir <- file.path(main_dir, "inst")
  subsub_dir <- file.path(sub_dir, "doc")
  
  # Step 1: Create the Folder Structure and Multiple .Rmd Files
  dir.create(main_dir, showWarnings = FALSE)
  dir.create(sub_dir, showWarnings = FALSE)
  dir.create(subsub_dir, showWarnings = FALSE)
  dir.create(sub_dir_vignette, showWarnings = FALSE)
  
  for (i in 1:5) {
    rmd_file <- file.path(sub_dir_vignette, paste0("sample_", i, ".Rmd"))
    writeLines(c(paste0("# Sample R Markdown ", i), "", "This is a sample R Markdown file."), rmd_file)
  }
  
  # Step 2: Create the .tar Archive
  tar_file <- file.path(temp_dir, "old_structure.tar.gz")
  tar(tar_file, files = main_dir)
  
  # Step 2: Create the .tar Archive
  tar_file <- file.path(temp_dir, "old_structure.tar.gz")
  tar(tar_file, files = main_dir)
  
  # Ensure cleanup happens even if the test fails
  defer(unlink(main_dir, recursive = TRUE))
  defer(unlink(tar_file))
  
  # Check that the tar file contains .Rmd files
  expect_false(contains_vignette_folder(tar_file))
  expect_silent(contains_vignette_folder(tar_file))
})


test_that("test on package with both inst/doc and vignette without .Rmd", {
  
  # Temporary directory for testing
  temp_dir <- tempdir()
  
  # Define the folder structure using the temporary directory
  main_dir <- file.path(temp_dir, "old_structure")
  
  # vignettes
  sub_dir_vignette <- file.path(main_dir, "vignettes")
  
  # inst/doc
  sub_dir <- file.path(main_dir, "inst")
  subsub_dir <- file.path(sub_dir, "doc")
  
  # Step 1: Create the Folder Structure and Multiple .Rmd Files
  dir.create(main_dir, showWarnings = FALSE)
  dir.create(sub_dir, showWarnings = FALSE)
  dir.create(subsub_dir, showWarnings = FALSE)
  dir.create(sub_dir_vignette, showWarnings = FALSE)
  
  # Step 2: Create the .tar Archive
  tar_file <- file.path(temp_dir, "old_structure.tar.gz")
  tar(tar_file, files = main_dir)
  
  # Step 2: Create the .tar Archive
  tar_file <- file.path(temp_dir, "old_structure.tar.gz")
  tar(tar_file, files = main_dir)
  
  # Ensure cleanup happens even if the test fails
  defer(unlink(main_dir, recursive = TRUE))
  defer(unlink(tar_file))
  
  # Check that the tar file contains .Rmd files
  expect_false(contains_vignette_folder(tar_file))
  expect_silent(contains_vignette_folder(tar_file))
})
