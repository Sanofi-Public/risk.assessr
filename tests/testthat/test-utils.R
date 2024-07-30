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


test_that("test risk profile with High overall risk score", {
  high_level <- 
    sanofi.risk.metric::calc_risk_profile(high_overall_risk_score)
  expect_equal(high_level, "High")
})

test_that("test risk profile with Medium overall risk score", {
  medium_level <- 
    sanofi.risk.metric::calc_risk_profile(medium_overall_risk_score)
  expect_equal(medium_level, "Medium")
}) 

test_that("test risk profile with Low overall risk score", {
  low_level <- 
    sanofi.risk.metric::calc_risk_profile(low_overall_risk_score)
  expect_equal(low_level, "Low")
})


test_that("checking for riskscore data location", {
  # if (checkmate::check_os("linux") == TRUE) {
  #   
  #   current_package <- paste0(Sys.getenv("HOME"),  
  #                             "/github-helper-repos/sanofi.risk.metric")
  #   out_dir <- paste0(current_package, "/inst/results")
  #   
  # } else if (checkmate::check_os("windows")  == TRUE) {  
  #   # set up package for writing data
  #   home_dir <- Sys.getenv()['HOME']
  #   
  #   current_package <- paste0(home_dir, "/bp-art-sanofi.risk.metric")
  #   
  #   otp <- paste0(current_package, "/inst/results")
  #   
  #   out_dir <- file.path(otp) 
  #   
  # }
  
  # out_dir <- paste0(current_package, "/inst/results")
  
  # check if risk score data exists and set up path to risk score data
  results_dir = "no audit trail" 
  
  riskscore_data_list <- 
    sanofi.risk.metric::check_riskscore_data_location(results_dir)
  
  expect_identical(length(riskscore_data_list), 4L)
  
  expect_true(checkmate::check_list(riskscore_data_list, 
                                    all.missing = FALSE)
  )
 
})  