test_that("get_pkg_creator_info works correctly", {
  # Mock the desc_get_author function
  mock_desc_get_author <- mockery::mock(
    list(), # Case 1: No creator
    list("John Doe"), # Case 2: One creator
    list(NULL) # Case 3: NULL creator
  )
  
  # Replace the desc_get_author function with the mock
  mockery::stub(get_pkg_creator_info, 
                "desc::desc_get_author", 
                mock_desc_get_author)
  
  # Case 1: No creator
  expect_message(result <- 
                   get_pkg_creator_info("testpkg", "path/to/pkg"), 
                 "Checking for creator in testpkg")
  expect_true(result)
  
  # Case 2: One creator
  expect_message(result <- 
                   get_pkg_creator_info("testpkg", 
                                        "path/to/pkg"), 
                 "Checking for creator in testpkg")
  expect_false(result)
  
  # Case 3: NULL creator
  expect_message(result <- 
                   get_pkg_creator_info("testpkg", 
                                        "path/to/pkg"), 
                 "Checking for creator in testpkg")
  expect_true(result)
})
