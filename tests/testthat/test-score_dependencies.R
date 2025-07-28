test_that("test score_dependencies", {
  
  dep_score <- score_dependencies(test_deps)
  
  expect_true(checkmate::check_numeric(dep_score))
  
  checkmate::expect_class(dep_score, "numeric")
  
  expect_vector(dep_score)
  
  expect_true(is.finite(dep_score))
})
