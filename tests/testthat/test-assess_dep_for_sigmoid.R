test_that("assess deps for sigmoid works correctly", {
  riskdata_results <- system.file("test-data", "riskdata_results_slim.csv", 
  package = "risk.assessr")
   
  sigmoid_test <- suppressWarnings(assess_dep_for_sigmoid(riskdata_results))
  
  testthat::expect_equal(length(sigmoid_test), 3L)
  
  testthat::expect_true(checkmate::check_class(sigmoid_test, "list"))
  
  testthat::expect_identical(length(sigmoid_test$results), 6L)
  
  testthat::expect_true(checkmate::check_class(sigmoid_test$results, "data.frame"))
  
  testthat::expect_true(checkmate::check_data_frame(sigmoid_test$results, any.missing = FALSE))
  
  testthat::expect_true(checkmate::test_numeric(sigmoid_test$results$imp_count))
  
  testthat::expect_true(checkmate::test_numeric(sigmoid_test$results$link_count))
  
  testthat::expect_true(checkmate::test_numeric(sigmoid_test$results$sug_count))
  
  testthat::expect_identical(length(sigmoid_test$imp_link_count_mean), 3L)
  
  testthat::expect_true(checkmate::check_class(sigmoid_test$imp_link_count_mean, "data.frame"))
  
  testthat::expect_true(checkmate::check_data_frame(sigmoid_test$imp_link_count_mean, any.missing = FALSE))
  
  testthat::expect_true(checkmate::test_numeric(sigmoid_test$imp_link_count_mean$imp_count))
  
  testthat::expect_true(checkmate::test_numeric(sigmoid_test$imp_link_count_mean$link_count))
  
  testthat::expect_true(checkmate::test_numeric(sigmoid_test$imp_link_count_mean$mean_total))
  
  testthat::expect_identical(length(sigmoid_test$all_count_mean), 4L)
  
  testthat::expect_true(checkmate::check_class(sigmoid_test$all_count_mean, "data.frame"))
  
  testthat::expect_true(checkmate::check_data_frame(sigmoid_test$all_count_mean, any.missing = FALSE))
  
  testthat::expect_true(checkmate::test_numeric(sigmoid_test$all_count_mean$imp_count))
  
  testthat::expect_true(checkmate::test_numeric(sigmoid_test$all_count_mean$link_count))

  testthat::expect_true(checkmate::test_numeric(sigmoid_test$all_count_mean$sug_count))
    
  testthat::expect_true(checkmate::test_numeric(sigmoid_test$all_count_mean$mean_total))
})