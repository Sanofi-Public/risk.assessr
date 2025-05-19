test_that("test weights profile", {
  weights <- create_weights_profile()
  checkmate::expect_class(weights, "numeric")
  
  expect_vector(weights)
  
  pluck_names <-
   weights |> 
   attributes() |>
   purrr::pluck("names")
  
  expect_identical(length(pluck_names), 16L)
})
