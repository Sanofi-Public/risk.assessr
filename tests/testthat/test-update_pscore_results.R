test_that("test update_pscore_results", {
  
  results <- update_pscore_results(update_risk_results, update_pscore)
  
  expect_identical(length(results), 18L)
  
  expect_error(expect_identical(results, update_risk_results))
  
  expect_true(checkmate::check_list(results, all.missing = FALSE))

  expect_true(checkmate::check_list(results, any.missing = TRUE))
})    