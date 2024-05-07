test_that("test sanofi weights numeric ", {
  expect_silent(sanofi.risk.metric::check_risk_weights(sanofi_weights_numeric))
})

test_that("test sanofi weights negative numeric ", {
  expect_error(sanofi.risk.metric::check_risk_weights(sanofi_weights_numeric_prob))
})

test_that("test sanofi weights non numeric ", {
  expect_error(sanofi.risk.metric::check_risk_weights(sanofi_weights_non_numeric))
}) 

test_that("test default metrics ", {
  overall_risk_score_1 <- 
    sanofi.risk.metric::calc_overall_risk_score(risk_results_1, 
                                                default_weights = TRUE)
  
  testthat::expect_equal(overall_risk_score_1, 
                         0.5245318,
                         tolerance = 0.00001)
}) 

test_that("test user defined metrics ", {
  overall_risk_score_2 <- 
    sanofi.risk.metric::calc_overall_risk_score(risk_results_1, 
                                                default_weights = FALSE)
  
  testthat::expect_equal(overall_risk_score_2,
                         0.3508283, 
                         tolerance = 0.00001)
}) 
