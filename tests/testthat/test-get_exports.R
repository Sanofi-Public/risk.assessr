
# Mock functions to simulate different scenarios
mock_parse_ns_file <- function(pkg_source_path) {
  list(
    exports = c("func1", "func2"),
    exportMethods = c("method1"),
    exportPatterns = c("pattern")
  )
}

mock_get_toplevel_assignments <- function(pkg_source_path) {
  data.frame(
    func = c("func1", "func2", "pattern_func"),
    stringsAsFactors = FALSE
  )
}

mock_filter_symbol_functions <- function(exports) {
  exports[!grepl("method", exports)]
}

test_that("get_exports works correctly", {
  # Mock the functions using mockery
  mockery::stub(get_exports, "pkgload::parse_ns_file", mock_parse_ns_file)
  mockery::stub(get_exports, "get_toplevel_assignments", mock_get_toplevel_assignments)
  mockery::stub(get_exports, "filter_symbol_functions", mock_filter_symbol_functions)
  
  # Test case: Normal scenario
  result <- get_exports("dummy_path")
  expect_equal(result$exported_function, c("func1", "func2", "method1"))
  
  # Test case: No exports found
  mock_parse_ns_file_empty <- function(pkg_source_path) {
    list(
      exports = character(0),
      exportMethods = character(0),
      exportPatterns = character(0)
    )
  }
  
  mockery::stub(get_exports, "pkgload::parse_ns_file", mock_parse_ns_file_empty)
  
  messages <- capture_messages(result <- get_exports("dummy_path"))
  #expect_true(any(grepl("No exports found in package dummy_path", messages)))
  expect_equal(nrow(result), 0)
})

test_that("get_exports handles empty S3methods", {
  # Mock the nsInfo object with empty S3methods
  nsInfo <- list(
    exports = c("function1"),
    exportMethods = character(0),
    S3methods = matrix(NA, ncol = 4, byrow = TRUE),
    exportPatterns = character(0)
  )
  
  # Mock the pkgload::parse_ns_file function
  mock_parse_ns_file <- mockery::mock(nsInfo)
  mockery::stub(get_exports, "pkgload::parse_ns_file", mock_parse_ns_file)
  
  # Mock the filter_symbol_functions function
  mock_filter_symbol_functions <- mockery::mock(c("function1"))
  mockery::stub(get_exports, "filter_symbol_functions", mock_filter_symbol_functions)
  
  # Call the function
  result <- get_exports("mock/path")
  
  # Expected result
  expected <- dplyr::tibble(exported_function = c("function1", "NA.NA"), 
                             function_type = c("regular", "S3 function"))
  
  # Check the result
  expect_equal(result, expected)
})

test_that("get_exports handles mixed S3methods", {
  # Mock the nsInfo object with mixed S3methods
  nsInfo <- list(
    exports = c("function1"),
    exportMethods = character(0),
    S3methods = matrix(c("generic1", "class1", NA, NA, "generic2", NA, NA, NA), ncol = 4, byrow = TRUE),
    exportPatterns = character(0)
  )
  
  # Mock the pkgload::parse_ns_file function
  mock_parse_ns_file <- mockery::mock(nsInfo)
  mockery::stub(get_exports, "pkgload::parse_ns_file", mock_parse_ns_file)
  
  # Mock the filter_symbol_functions function
  mock_filter_symbol_functions <- mockery::mock(c("function1", "generic1.class1"))
  mockery::stub(get_exports, "filter_symbol_functions", mock_filter_symbol_functions)
  
  # Call the function
  result <- get_exports("mock/path")
  
  # Expected result
  expected <- dplyr::tibble(exported_function = c("function1", "generic1.class1", "generic2.NA"), 
                             function_type = c("regular", "S3 function", "S3 function"))
  
  # Check the result
  expect_equal(result, expected)
})

test_that("get_toplevel_assignments works correctly", {
  # Mock the tools::list_files_with_type function
  mock_list_files_with_type <- function(path, type) {
    if (path == "dummy_path/R") {
      return(c("file1.R", "file2.R"))
    }
    return(character(0))
  }
  
  # Mock the parse function
  mock_parse <- function(file) {
    if (file == "file1.R") {
      return(parse(text = "func1 <- function() {}"))
    } else if (file == "file2.R") {
      return(parse(text = "func2 <- function() {}"))
    }
    stop("Unexpected file")
  }
  
  # Mock the fs::path_rel function
  mock_path_rel <- function(path, start) {
    return(basename(path))
  }
  
  pkg_name <- "dummy_path"
  
  # Use mockery to stub the functions
  mockery::stub(get_toplevel_assignments, "tools::list_files_with_type", mock_list_files_with_type)
  mockery::stub(get_toplevel_assignments, "parse", mock_parse)
  mockery::stub(get_toplevel_assignments, "fs::path_rel", mock_path_rel)
  
  # Test case: Normal scenario
  result <- get_toplevel_assignments(pkg_name)
  expect_equal(result$func, c("func1", "func2"))
  expect_equal(result$code_script, c("file1.R", "file2.R"))
  
  # Test case: No R files found
  mock_list_files_with_type_empty <- function(path, type) {
    return(character(0))
  }
  
  mockery::stub(get_toplevel_assignments, "tools::list_files_with_type", mock_list_files_with_type_empty)
  
  messages <- capture_messages(result <- get_toplevel_assignments(pkg_name))
  print(messages)
  expect_true(any(grepl(glue::glue("No sourceable R scripts were found in the R/ directory for package {pkg_name}. Make sure this was expected."), messages)))
  expect_equal(nrow(result), 0)
})

test_that("map_functions_to_scripts returns correct mapping", {
  # Mock the exports_df
  exports_df <- dplyr::tibble(exported_function = c("function1", "function2", "generic1.class1"))
  
  # Mock the funcs_df
  funcs_df <- dplyr::tibble(func = c("function1", "function2", "generic1.class1"), code_script = c("script1.R", "script2.R", "script3.R"))
  
  # Mock the get_toplevel_assignments function
  mock_get_toplevel_assignments <- mockery::mock(funcs_df)
  mockery::stub(map_functions_to_scripts, "get_toplevel_assignments", mock_get_toplevel_assignments)
  
  # Call the function
  result <- map_functions_to_scripts(exports_df, "mock/path", verbose = FALSE)
  
  # Expected result
  expected <- dplyr::tibble(
    exported_function = c("function1", "function2", "generic1.class1"),
    code_script = c("script1.R", "script2.R", "script3.R")
  )
  
  # Check the result
  expect_equal(result, expected)
})

test_that("map_functions_to_scripts handles no top level assignments found", {
  # Mock the exports_df
  exports_df <- dplyr::tibble(exported_function = c("function1", "function2", "generic1.class1"))
  
  # Mock the funcs_df with no assignments
  funcs_df <- dplyr::tibble()
  
  # Mock the get_toplevel_assignments function
  mock_get_toplevel_assignments <- mockery::mock(funcs_df)
  mockery::stub(map_functions_to_scripts, "get_toplevel_assignments", mock_get_toplevel_assignments)
  
  # Call the function
  result <- map_functions_to_scripts(exports_df, "mock/path", verbose = FALSE)
  
  # Expected result
  expected <- data.frame()
  
  # Check the result
  expect_equal(result, expected)
})

test_that("map_functions_to_scripts handles missing functions in scripts", {
  # Mock the exports_df
  exports_df <- dplyr::tibble(exported_function = c("function1", "function2", "generic1.class1"))
  
  # Mock the funcs_df with missing functions
  funcs_df <- dplyr::tibble(func = c("function1"), code_script = c("script1.R"))
  
  # Mock the get_toplevel_assignments function
  mock_get_toplevel_assignments <- mockery::mock(funcs_df)
  mockery::stub(map_functions_to_scripts, "get_toplevel_assignments", mock_get_toplevel_assignments)
  
  # Call the function
  result <- map_functions_to_scripts(exports_df, "mock/path", verbose = TRUE)
  
  # Expected result
  expected <- dplyr::tibble(
    exported_function = c("function1", "function2", "generic1.class1"),
    code_script = c("script1.R", NA, NA)
  )
  
  # Check the result
  expect_equal(result, expected)
})

test_that("map_functions_to_docs returns correct mapping", {
  # Mock the exports_df
  exports_df <- dplyr::tibble(exported_function = c("function1", "function2", "generic1.class1"))
  
  # Mock the Rd files
  rd_files <- c("man/function1.Rd", "man/function2.Rd", "man/generic1.class1.Rd")
  
  # Mock the list.files function
  mock_list_files <- mockery::mock(rd_files)
  mockery::stub(map_functions_to_docs, "list.files", mock_list_files)
  
  # Mock the readLines function
  mock_read_lines <- mockery::mock(
    c("\\name{function1}", "\\alias{function1}"),
    c("\\name{function2}", "\\alias{function2}"),
    c("\\name{generic1.class1}", "\\alias{generic1.class1}")
  )
  mockery::stub(map_functions_to_docs, "readLines", mock_read_lines)
  
  # Call the function
  result <- map_functions_to_docs(exports_df, "mock/path", verbose = FALSE)
  
  # Expected result
  expected <- dplyr::tibble(
    exported_function = c("function1", "function2", "generic1.class1"),
    documentation = c("function1.Rd", "function2.Rd", "generic1.class1.Rd")
  )
  
  # Check the result
  expect_equal(result, expected)
})

test_that("map_functions_to_docs handles no documentation found", {
  # Mock the exports_df
  exports_df <- dplyr::tibble(exported_function = c("function1", "function2", "generic1.class1"))
  
  # Mock the Rd files with no documentation
  rd_files <- character(0)
  
  # Mock the list.files function
  mock_list_files <- mockery::mock(rd_files)
  mockery::stub(map_functions_to_docs, "list.files", mock_list_files)
  
  # Call the function
  result <- map_functions_to_docs(exports_df, "mock/path", verbose = FALSE)
  
  # Expected result
  expected <- dplyr::mutate(exports_df, documentation = NA)
  
  # Check the result
  expect_equal(result, expected)
})

test_that("map_functions_to_docs handles missing functions in documentation", {
  # Mock the exports_df
  exports_df <- dplyr::tibble(exported_function = c("function1", "function2", "generic1.class1"))
  
  # Mock the Rd files with missing functions
  rd_files <- c("man/function1.Rd")
  
  # Mock the list.files function
  mock_list_files <- mockery::mock(rd_files)
  mockery::stub(map_functions_to_docs, "list.files", mock_list_files)
  
  # Mock the readLines function
  mock_read_lines <- mockery::mock(c("\\name{function1}", "\\alias{function1}"))
  mockery::stub(map_functions_to_docs, "readLines", mock_read_lines)
  
  # Call the function
  result <- map_functions_to_docs(exports_df, "mock/path", verbose = TRUE)
  
  # Expected result
  expected <- dplyr::tibble(
    exported_function = c("function1", "function2", "generic1.class1"),
    documentation = c("function1.Rd", NA, NA)
  )
  
  # Check the result
  expect_equal(result, expected)
})

test_that("filter_symbol_functions filters out symbols correctly", {
  # Mocked data
  funcs <- c("%>%", "$", "[[", "[", "+", "%", "<-", "function1", "function2")
  
  # Call the function
  result <- filter_symbol_functions(funcs)
  
  # Expected result
  expected <- c("function1", "function2")
  
  # Check the result
  expect_equal(result, expected)
})

test_that("filter_symbol_functions handles empty input", {
  # Mocked data
  funcs <- character(0)
  
  # Call the function
  result <- filter_symbol_functions(funcs)
  
  # Expected result
  expected <- character(0)
  
  # Check the result
  expect_equal(result, expected)
})

test_that("filter_symbol_functions handles input with no symbols", {
  # Mocked data
  funcs <- c("function1", "function2", "function3")
  
  # Call the function
  result <- filter_symbol_functions(funcs)
  
  # Expected result
  expected <- c("function1", "function2", "function3")
  
  # Check the result
  expect_equal(result, expected)
})

test_that("filter_symbol_functions handles input with only symbols", {
  # Mocked data
  funcs <- c("%>%", "$", "[[", "[", "+", "%", "<-")
  
  # Call the function
  result <- filter_symbol_functions(funcs)
  
  # Expected result
  expected <- character(0)
  
  # Check the result
  expect_equal(result, expected)
})