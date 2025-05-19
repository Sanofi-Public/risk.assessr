test_that("test weights numeric ", {
  expect_silent(check_risk_weights(weights_numeric))
})

test_that("test weights negative numeric ", {
  expect_error(check_risk_weights(weights_numeric_prob))
})

test_that("test weights non numeric ", {
  expect_error(check_risk_weights(weights_non_numeric))
}) 

test_that("test default metrics ", {
  overall_risk_score_1 <- 
    risk.assessr::calc_overall_risk_score(risk_results_1, 
                                                default_weights = TRUE)
  
  testthat::expect_equal(overall_risk_score_1, 
                         0.5245318,
                         tolerance = 0.00001)
}) 

test_that("test user defined metrics ", {
  overall_risk_score_2 <- 
    risk.assessr::calc_overall_risk_score(risk_results_1, 
                                                default_weights = FALSE)
  
  testthat::expect_equal(overall_risk_score_2,
                         0.3508283, 
                         tolerance = 0.00001)
}) 


test_that("test risk profile with High overall risk score", {
  high_level <- 
    risk.assessr::calc_risk_profile(high_overall_risk_score)
  expect_equal(high_level, "High")
})

test_that("test risk profile with Medium overall risk score", {
  medium_level <- 
    risk.assessr::calc_risk_profile(medium_overall_risk_score)
  expect_equal(medium_level, "Medium")
}) 

test_that("test risk profile with Low overall risk score", {
  low_level <- 
    risk.assessr::calc_risk_profile(low_overall_risk_score)
  expect_equal(low_level, "Low")
})


