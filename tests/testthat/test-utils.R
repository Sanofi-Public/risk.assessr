test_that("test sanofi weights numeric ", {
  expect_silent(sanofi.risk.metric::check_risk_weights(sanofi_weights_numeric))
})

test_that("test sanofi weights negative numeric ", {
  expect_error(sanofi.risk.metric::check_risk_weights(sanofi_weights_numeric_prob))
})

test_that("test sanofi weights non numeric ", {
  expect_error(sanofi.risk.metric::check_risk_weights(sanofi_weights_non_numeric))
})  
