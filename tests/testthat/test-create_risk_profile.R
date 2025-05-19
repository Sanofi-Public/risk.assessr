test_that("test risk profile", {
  risk_profile <- create_risk_profile()
  checkmate::expect_class(risk_profile, "list")
  
  expect_vector(risk_profile)
  
  expect_identical(length(risk_profile), 3L)
})
