test_that("assess deps for sigmoid works correctly", {
  riskdata_results <- system.file("test-data", "riskdata_results_slim.csv", 
                                  package = "risk.assessr")
  
  update_comments <- "recalc test"
  
  recalc_test <- recalc_risk_scores(riskdata_results, update_comments)
  
  testthat::expect_true(checkmate::check_class(recalc_test, "data.frame"))
  
  testthat::expect_true(checkmate::check_data_frame(recalc_test, any.missing = TRUE))
  
  testthat::expect_identical(length(recalc_test), 29L)
  
  testthat::expect_identical(nrow(recalc_test), 5L)
})
