test_that("test create_empty_results", {

  results <- sanofi.risk.metric::create_empty_results(test_pkg_name,
                                                      test_pkg_ver,
                                                      test_pkg_source_path,
                                                      test_comments,
                                                      test_metadata)

  expect_identical(length(results), 27L)
  
  expect_true(checkmate::check_list(results, all.missing = FALSE))
  
  expect_true(checkmate::check_list(results, any.missing = TRUE))
})
