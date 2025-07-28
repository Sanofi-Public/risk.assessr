
test_that("check_suggested_exp_funcs returns 2 matches", {
  skip_on_cran()
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data", "here-1.0.1.tar.gz", 
                    package = "risk.assessr")
  
  # set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  package_installed <- 
    install_package_local(pkg_source_path)
  package_installed <- TRUE
  
  if (package_installed == TRUE ) {
  
    pkg_name <- "here"
    
    result <- check_suggested_exp_funcs(pkg_name, 
                                        pkg_source_path, 
                                        deps_df)
    
    expect_true(all(!is.na(result$source)))
    expect_true(all(is.na(result$targeted_package)))
    expect_true(all(!is.na(result$message)))
  }
})

test_that("check_suggested_exp_funcs returns matches messages for S3 functions", {
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)

  dp <- system.file("test-data", "test.package.0009_0.1.0.tar.gz",
                    package = "risk.assessr")

  # set up package
  install_list <- risk.assessr::set_up_pkg(dp)

  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args


  # install package locally to ensure test works
  package_installed <-
    install_package_local(pkg_source_path)
  package_installed <- TRUE

  if (package_installed == TRUE ) {

    rcmdcheck_args$path <- pkg_source_path
    pkg_name <- "test.package.0009"

    #set up deps_df for this package
    package <- c("magrittr", "checkmate",
                 "testthat", "dplyr"
    )
    type <- c("Imports", "Suggests", "Suggests",
              "Suggests"
    )
    deps_df <- data.frame(package, type)


    result <- check_suggested_exp_funcs(pkg_name,
                                        pkg_source_path,
                                        deps_df)

    expect_equal(nrow(result), 10L)

    test_that("Messages are correct for S3 function", {
      expect_true(all(grepl("Please check if the targeted package should be in Imports", result$message)))
    })
  }
})

# Define the mocked numeric variable
value <- structure(2.845276, class = "numeric")

test_that("get_function_details handles numeric values", {
  # Mock data for rlang_fake_data_pronoun
  package_name <- "test_package"
  
  # Set up exp_func for this package
  exported_function <- c("test_function")
  function_type <- c(NA) 
  
  exp_func <- dplyr::tibble(exported_function, function_type)
  
  # Mock the class function to return "numeric"
  mock_class <- mockery::mock("numeric")
  mockery::stub(get_function_details, "class", mock_class)
  
  # Mock the require function to simulate package loading
  mock_require <- mockery::mock(TRUE)
  mockery::stub(get_function_details, "require", mock_require)
  
  # Mock the eval function to return the mocked value
  mock_eval <- mockery::mock(value)
  mockery::stub(get_function_details, "eval", mock_eval)
  
  # Call the actual function
  results <- get_function_details(package_name, exp_func, pkg_source_path)
  
  # Check the results
  expected <- data.frame(
    source = "test_function",
    function_type = "numeric",
    suggested_function = "\"2.845276\"",
    where = "test_package",
    stringsAsFactors = FALSE
  )
  
  expect_equal(nrow(results), 1)
  expect_equal(results$source, exp_func$exported_function)
  expect_equal(results$function_type, "numeric")
  actual <- results$suggested_function
  expected <- "\"2.845276\""
  expect_true(grepl(expected, actual))
  expect_equal(results$where, package_name)
})

# Define the mocked rlang_fake_data_pronoun variable
value <- structure(list(), class = "rlang_fake_data_pronoun")

test_that("get_function_details handles rlang_fake_data_pronoun", {
  # Mock data for rlang_fake_data_pronoun
  package_name <- "test_package"
  
  #set up exp_func for this package
  exported_function <- c("test_function")
  function_type <- c(NA) 
  
  
  exp_func <- dplyr::tibble(exported_function, function_type)
  
  # Mock the class function to return "rlang_fake_data_pronoun"
  
  mock_class <- mockery::mock("rlang_fake_data_pronoun")
  mockery::stub(get_function_details, "class", mock_class)
  
  # Mock the require function to simulate package loading
  mock_require <- mockery::mock(TRUE)
  mockery::stub(get_function_details, "require", mock_require)
  
  # Mock the eval function to return the mocked value
  mock_eval <- mockery::mock(value)
  mockery::stub(get_function_details, "eval", mock_eval)
  
  # Call the actual function
  results <- get_function_details(package_name, exp_func, pkg_source_path)
  
  # Check the results
  expected <- data.frame(
    source = "test_function",
    function_type = "rlang tidy eval",
    suggested_function = "check rlang as this is a re-export",
    where = "test_package",
    stringsAsFactors = FALSE
  )
  
  expect_equal(nrow(results), 1)
  expect_equal(results$source, exp_func$exported_function)
  expect_equal(results$function_type, "rlang tidy eval")
  actual <- results$suggested_function
  expected <- "check rlang as this is a re-export"
  expect_true(grepl(expected, actual))
  expect_equal(results$where, package_name)
  
})

# Define the mocked ggproto variable
value <- structure(list(), class = "ggproto")

test_that("get_function_details handles ggproto", {
  # Mock data for ggproto
  package_name <- "test_package"
  
  #set up exp_func for this package
  exported_function <- c("test_function")
  function_type <- c(NA) 
  
  
  exp_func <- dplyr::tibble(exported_function, function_type)
  
  # Mock the ggplot2::is.ggproto function to return TRUE
  mock_is_ggproto <- mockery::mock(TRUE)
  mockery::stub(get_function_details, "ggplot2::is.ggproto", mock_is_ggproto)
  
  # Mock the extract_ggproto_methods function to return a function body
  mock_func_body <- function() { "mocked function body" }
  mock_extract_ggproto_methods <- mockery::mock(mock_func_body)
  mockery::stub(get_function_details, "extract_ggproto_methods", mock_extract_ggproto_methods)
  
  # Mock the require function to simulate package loading
  mock_require <- mockery::mock(TRUE)
  mockery::stub(get_function_details, "require", mock_require)
  
  # Mock the eval function to return the mocked value
  mock_eval <- mockery::mock(value)
  mockery::stub(get_function_details, "eval", mock_eval)
  
  # Call the actual function
  results <- get_function_details(package_name, exp_func, pkg_source_path)
  
  # Check the results
  expected <- data.frame(
    source = "test_function",
    function_type = "ggproto",
    suggested_function = "mocked function body",
    where = "test_package",
    stringsAsFactors = FALSE
  )
  
  expect_equal(nrow(results), 1)
  expect_equal(results$source, exp_func$exported_function)
  expect_equal(results$function_type, "ggproto")
  actual <- results$suggested_function
  expected <- "mocked function body"
  expect_true(grepl(expected, actual))
  expect_equal(results$where, package_name)

})
    
test_that("get_function_details handles S3 function with no body", {
  # Mock data for an S3 function
  package_name <- "test_package"
  
  #set up exp_func for this package
  exported_function <- c("test_function")
  function_type <- c(NA) 
  
  
  exp_func <- dplyr::tibble(exported_function, function_type)
  
  # Mock the eval(parse(text = func_full_name)) to return the S3 function
  mock_eval <- mockery::mock(s3_function_no_body.dataframe_with_y)
  mockery::stub(get_function_details, "eval", mock_eval)
  
  # Mock the require function to simulate package loading
  mock_require <- mockery::mock(TRUE)
  mockery::stub(get_function_details, "require", mock_require)
  
  # Call the actual function
  results <- get_function_details(package_name, exp_func, pkg_source_path)
  
  # Check the results
  expect_equal(nrow(results), 1)
  expect_equal(results$source, exp_func$exported_function)
  expect_equal(results$function_type, "regular")
  expect_equal(results$suggested_function, "Function body not found")
  expect_equal(results$where, package_name)
  
})

test_that("check_suggested_exp_funcs returns matches messages for S3 functions", {
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)

  dp <- system.file("test-data", "test.package.0009_0.1.0.tar.gz",
                    package = "risk.assessr")

  # set up package
  install_list <- risk.assessr::set_up_pkg(dp)

  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args


  # install package locally to ensure test works
  package_installed <-
    install_package_local(pkg_source_path)
  package_installed <- TRUE

  if (package_installed == TRUE ) {

    rcmdcheck_args$path <- pkg_source_path
    pkg_name <- "test.package.0009"

    #set up deps_df for this package
    package <- c("magrittr", "checkmate",
                 "testthat", "dplyr"
    )
    type <- c("Imports", "Suggests", "Suggests",
              "Suggests"
    )
    deps_df <- data.frame(package, type)


    result <- check_suggested_exp_funcs(pkg_name,
                                        pkg_source_path,
                                        deps_df)

    expect_equal(nrow(result), 10L)

    test_that("Messages are correct for S3 function", {
      expect_true(all(grepl("Please check if the targeted package should be in Imports", result$message)))
    })
  }
})

test_that("check_suggested_exp_funcs returns matches messages for S4 functions", {
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data", "test.package.0010_0.1.0.tar.gz", 
                    package = "risk.assessr")
  
  # set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  
  # install package locally to ensure test works
  package_installed <- 
    install_package_local(pkg_source_path)
  package_installed <- TRUE
  
  if (package_installed == TRUE ) {
    
    rcmdcheck_args$path <- pkg_source_path
    pkg_name <- "test.package.0010"
    
    #set up deps_df for this package
    package <- c("checkmate",
                 "testthat", "methods"
    )
    type <- c("Suggests", "Suggests",
              "Suggests"
    ) 
    deps_df <- data.frame(package, type)
    
    
    result <- check_suggested_exp_funcs(pkg_name, 
                                        pkg_source_path, 
                                        deps_df)
    
    expect_equal(nrow(result), 1L)
    
    test_that("Messages are correct for S4 function", {
      expect_true(all(grepl("Please check if the targeted package should be in Imports", result$message)))
    })
  }
})

test_that("check_suggested_exp_funcs returns no exported functions message", {
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data", "test.package.0005_0.1.0.tar.gz", 
                    package = "risk.assessr")
  
  # set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  # install package locally to ensure test works
  package_installed <- 
    install_package_local(pkg_source_path)
  package_installed <- TRUE
  
  if (package_installed == TRUE ) {
  
    pkg_name <- "test.package.0005"
    
    #set up deps_df for this package
    package <- c("magrittr", "checkmate",
                 "testthat", "dplyr"
    )
    type <- c("Imports", "Suggests", "Suggests",
              "Suggests"
    ) 
    deps_df <- data.frame(package, type)
    
    
    result <- check_suggested_exp_funcs(pkg_name, 
                                        pkg_source_path, 
                                        deps_df)
    
    expect_equal(nrow(result), 1L)
    
    expect_true(all(!is.na(result$source)))
    expect_true(all(!is.na(result$message)))
    testthat::expect_message(
      result <- check_suggested_exp_funcs(pkg_name, 
                                          pkg_source_path, 
                                          deps_df),
      glue::glue("No exported functions from source package {pkg_name}"),
      fixed = TRUE
    )
  }
})

test_that("check_suggested_exp_funcs returns No R folder found in the package source path message", {
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data", "test.package.0006_0.1.0.tar.gz", 
                    package = "risk.assessr")
  
  # set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  # install package locally to ensure test works
  package_installed <- 
    install_package_local(pkg_source_path)
  package_installed <- TRUE
  
  if (package_installed == TRUE ) {
    pkg_name <- "test.package.0006"
    
    #set up deps_df for this package
    package <- c("magrittr", "checkmate",
                 "testthat", "dplyr"
    )
    type <- c("Imports", "Suggests", "Suggests",
              "Suggests"
    ) 
    deps_df <- data.frame(package, type)
    
    
    result <- check_suggested_exp_funcs(pkg_name, 
                                        pkg_source_path, 
                                        deps_df)
    
    expect_equal(nrow(result), 1L)
    
    expect_true(all(!is.na(result$source)))
    expect_true(all(!is.na(result$message)))
    testthat::expect_message(
      result <- check_suggested_exp_funcs(pkg_name, 
                                          pkg_source_path, 
                                          deps_df),
      glue::glue("No R folder found in the package source path"),
      fixed = TRUE
    )
  }
})


test_that("check_suggested_exp_funcs handles NULL suggested_exp_func correctly", {
  
  mock_contains_r_folder <- function(...) TRUE
  mock_get_exports <- function(...) data.frame(exported_function = c("func1", "func2", "func3"))
  mock_get_suggested_exp_funcs <- function(...) NULL
  mock_get_function_details <- function(...) data.frame(details = "mocked details")
  
  pkg_name <- "target_pkg"
  pkg_source_path <- "dummy_path"
  suggested_deps <- data.frame(package = c("pkgA", "pkgB"))
  
  testthat::local_mocked_bindings(
    `contains_r_folder` = mock_contains_r_folder,
    `get_exports` = mock_get_exports,
    `get_suggested_exp_funcs` = mock_get_suggested_exp_funcs,
    `get_function_details` = mock_get_function_details
  )
  
  result <- check_suggested_exp_funcs(pkg_name, pkg_source_path, suggested_deps)
  
  expect_true(any(grepl("No Suggested packages in the DESCRIPTION file", result$message)))
})
  

# Create toy datasets for testing create_items_matched
extracted_functions <- dplyr::tibble(
  suggested_function = c("dplyr::mutate", "stringr::str_detect", "ggplot2::ggplot", "base::mean")
)

suggested_exp_func <- dplyr::tibble(
  package = c("dplyr", "stringr"),
  exported_functions = c("mutate", "str_detect")
)

# Expected output
expected_output <- dplyr::tibble(
  suggested_function = c("dplyr::mutate", "stringr::str_detect")
)

# Test the function
test_that("create_items_matched works correctly", {
  result <- create_items_matched(extracted_functions, suggested_exp_func) %>% 
    dplyr::ungroup() # Convert to regular tibble
  expect_equal(result, expected_output)
})

# Create toy datasets for process_items_matched testing
items_matched <- dplyr::tibble(
  source = c("file1", "file2", "file3"),
  suggested_function = c("dplyr::mutate", "stringr::str_detect", "base::mean")
)

suggested_exp_func <- dplyr::tibble(
  package = c("dplyr", "stringr", "base"),
  functions = c("mutate", "str_detect", "mean")
)

# Expected output
expected_output <- dplyr::tibble(
  source = c("file1", "file2", "file3"),
  suggested_function = c("mutate", "str_detect", "mean"),
  targeted_package = c("dplyr", "stringr", "base"),
  message = rep("Please check if the targeted package should be in Imports", 3)
)

# Test the function
test_that("process_items_matched works correctly", {
  result <- process_items_matched(items_matched, suggested_exp_func)
  expect_equal(result, expected_output)
})

# Create a toy dataset for testing get_regular_function_body
pkg_name <- "base"
func_name <- "mean"

# Expected output
expected_output <- dplyr::tibble(
  source = "mean",
  suggested_function = paste(deparse(base::mean), collapse = "\n"),
  where = "base"
)

# Test the function
test_that("get_regular_function_body works correctly", {
  result <- get_regular_function_body(pkg_name, func_name)
  expect_equal(result, expected_output)
})

# Define a mock ggproto object
mock_ggproto <- list(
  method1 = function() { print("Method 1") },
  method2 = function() { print("Method 2") },
  non_function = "Not a function"
)

# Test the extract_ggproto_methods function
test_that("extract_ggproto_methods extracts methods correctly", {
  # Mock the ggproto object
  mock_obj <- mock_ggproto
  
  # Call the function with the mock object
  result <- extract_ggproto_methods(mock_obj)
  
  # Expected result
  expected_result <- paste(
    paste(deparse(body(mock_obj$method1)), collapse = "\n"),
    paste(deparse(body(mock_obj$method2)), collapse = "\n"),
    sep = "\n\n"
  )
  
  # Check if the result matches the expected result
  expect_equal(result, expected_result)
})



test_that("check_suggested_exp_funcs handles empty suggested_deps", {
  # Mock data
  pkg_name <- "testpkg"
  pkg_source_path <- "path/to/testpkg"
  suggested_deps <- data.frame() # Empty data frame
  
  # Mock functions
  mock_contains_r_folder <- mockery::mock(TRUE)
  mock_get_exports <- mockery::mock(data.frame(exported_function = character()))
  mock_get_function_details <- mockery::mock(data.frame())
  mock_get_suggested_exp_funcs <- mockery::mock(data.frame())
  mock_create_items_matched <- mockery::mock(data.frame())
  mock_process_items_matched <- mockery::mock(data.frame())
  
  # Replace the actual functions with mocks
  mockery::stub(check_suggested_exp_funcs, "risk.assessr::contains_r_folder", mock_contains_r_folder)
  mockery::stub(check_suggested_exp_funcs, "risk.assessr::get_exports", mock_get_exports)
  mockery::stub(check_suggested_exp_funcs, "get_function_details", mock_get_function_details)
  mockery::stub(check_suggested_exp_funcs, "risk.assessr::get_suggested_exp_funcs", mock_get_suggested_exp_funcs)
  mockery::stub(check_suggested_exp_funcs, "create_items_matched", mock_create_items_matched)
  mockery::stub(check_suggested_exp_funcs, "process_items_matched", mock_process_items_matched)
  
  # Call the function
  result <- check_suggested_exp_funcs(pkg_name, pkg_source_path, suggested_deps)
  
  # Check the result
  expect_equal(result$message, "No Imports or Suggested packages in the DESCRIPTION file")
  expect_true(is.na(result$suggested_function))
  expect_true(is.na(result$targeted_package))
})

test_that("preprocess_func_full_name works for usual S3 functions", {
  result <- preprocess_func_full_name("dplyr::filter_.tbl_df")
  expect_equal(result$package, "dplyr")
  expect_equal(result$generic, "filter_")
  expect_equal(result$class, "tbl_df")
})

test_that("preprocess_func_full_name works for specific S3 functions with :::", {
  result <- preprocess_func_full_name("filter_bullets.dplyr:::filter_incompatible_size")
  expect_equal(result$package, "dplyr")
  expect_equal(result$generic, "filter_bullets")
  expect_equal(result$class, "dplyr:::filter_incompatible_size")
})

test_that("preprocess_func_full_name works for specific S3 functions with multiple :::", {
  result <- preprocess_func_full_name("mutate_bullets.dplyr:::mutate_constant_recycle_error")
  expect_equal(result$package, "dplyr")
  expect_equal(result$generic, "mutate_bullets")
  expect_equal(result$class, "dplyr:::mutate_constant_recycle_error")
})

test_that("preprocess_func_full_name works for usual S3 functions without :::", {
  result <- preprocess_func_full_name("inner_join::data.frame")
  expect_equal(result$package, "inner_join")
  expect_equal(result$generic, "data")
  expect_equal(result$class, "frame")
})

test_that("preprocess_func_full_name works for usual S3 functions with single dot", {
  result <- preprocess_func_full_name("mutate_::tbl_df")
  expect_equal(result$package, "mutate_")
  expect_equal(result$generic, "tbl_df")
  expect_equal(result$class, "")
})

test_that("generic is adjusted correctly if it contains '::'", {
  result <- preprocess_func_full_name("dplyr::filter_bullets.dplyr:::filter_incompatible_size")
  expect_equal(result$package, "dplyr")
  expect_equal(result$generic, "filter_bullets")  # Test for adjusted generic
  expect_equal(result$class, "dplyr:::filter_incompatible_size")
})
