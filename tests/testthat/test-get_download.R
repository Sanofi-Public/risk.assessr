test_that("extract_aria_label works correctly", {
  expect_equal(extract_aria_label('<svg aria-label="CRAN downloads 123K"></svg>'), "CRAN downloads 123K")
  expect_null(extract_aria_label('<svg></svg>'))
})

test_that("convert_abbreviation_to_number works correctly", {
  expect_equal(convert_abbreviation_to_number("123K"), 123000)
  expect_equal(convert_abbreviation_to_number("1.5M"), 1500000)
  expect_equal(convert_abbreviation_to_number("500k"), 500000)
  expect_equal(convert_abbreviation_to_number("500K"), 500000)
  expect_equal(convert_abbreviation_to_number("500"), 500)
  expect_equal(convert_abbreviation_to_number("0K"), 0)
})

test_that("Package with download", {
  
  mock_extract_aria_label <- function(...) {
    "CRAN downloads 155.5M"
  }
  
  # Mock the function call within get_package_download
  with_mocked_bindings(
    `extract_aria_label` = mock_extract_aria_label,
    {
      result <- get_package_download("ggplot2")
      expect_equal(result, 155500000)
    }
  )
})

test_that("Package without download)", {
  
  mock_extract_aria_label <- function(...) {
    ""
  }
  
  # Mock the function call within get_package_download
  with_mocked_bindings(
    `extract_aria_label` = mock_extract_aria_label,
    {
      result <- get_package_download("ggplot2")
      expect_equal(result, 0)
    }
  )
})




