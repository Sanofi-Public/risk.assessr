
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
  expect_equal(result$exported_function, c("pattern_func", "func1", "func2"))
  
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
  expect_true(any(grepl("No exports found in package dummy_path", messages)))
  expect_equal(nrow(result), 0)
})
