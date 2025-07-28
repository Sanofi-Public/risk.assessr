test_that("Empty HTML content", {
  empty_html <- NULL
  result <- parse_html_version(empty_html, "dummy_package")
  expect_equal(result, list())
})

test_that("HTML content without versions", {
  html_with_no_version <- '<table>
   <tr><td valign="top"></td><td><a href="https://example.com/package.tar.gz">package.tar.gz</a></td><td align="right">2023-01-01 12:00</td><td align="right">1.0M</td></tr>
  </table>'
  
  result <- parse_html_version(html_with_no_version, "package")
  expect_equal(result, list())
})

test_that("Valid HTML with one version", {
  valid_html <- '<table>
    <tr><td valign="top"></td><td><a href="https://example.com/package_1.0.tar.gz">package_1.0.tar.gz</a></td><td align="right">2023-01-01 12:00</td><td align="right">1.0M</td></tr>
  </table>'
  
  result <- parse_html_version(valid_html, "package")
  
  expected <- list(
    list(
      package_name = "package",
      package_version = "1.0",
      link = "https://example.com/package_1.0.tar.gz",
      date = "2023-01-01 12:00",
      size = "1.0M"
    )
  )
  expect_equal(result, expected)
})

test_that("Valid HTML with multiple versions", {
  valid_html <- '<table>
    <tr><td valign="top"></td><td><a href="https://example.com/package_1.0.tar.gz">package_1.0.tar.gz</a></td><td align="right">2023-01-01 12:00</td><td align="right">1.0M</td></tr>
    <tr><td valign="top"></td><td><a href="https://example.com/package_2.0.tar.gz">package_2.0.tar.gz</a></td><td align="right">2023-02-01 12:00</td><td align="right">1.5M</td></tr>
  </table>'
  
  result <- parse_html_version(valid_html, "package")
  expected <- list(
    list(
      package_name = "package",
      package_version = "1.0",
      link = "https://example.com/package_1.0.tar.gz",
      date = "2023-01-01 12:00",
      size = "1.0M"
    ),
    list(
      package_name = "package",
      package_version = "2.0",
      link = "https://example.com/package_2.0.tar.gz",
      date = "2023-02-01 12:00",
      size = "1.5M"
    )
  )
  expect_equal(result, expected)
})

test_that("HTML with missing version in table", {
  html_missing_version <- '<table>
    <tr><td valign="top"></td><td><a href="https://example.com/package.tar.gz"></a></td><td align="right">2023-01-01 12:00</td><td align="right">1.0M</td></tr>
  </table>'
  
  result <- parse_html_version(html_missing_version, "package")
  expect_equal(result, list())
})

test_that("HTML with corrupted table structure", {
  html_corrupted <- '<table>
    <tr><td valign="top"></td><td></td><td align="right">2023-01-01 12:00</td></tr>
  </table>'
  
  result <- parse_html_version(html_corrupted, "package")
  expect_equal(result, list())
})


# Test cases: parse_package_info

test_that("parse_package_info works correctly with mock response", {
  # Create a mock response object
  mock_response <- list(
    status_code = 200,
    content = charToRaw("<html>Mock Content</html>")
  )
  
  # Mock curl::curl_fetch_memory
  mock_fetch <- mockery::mock(mock_response)
  
  # Use with_mocked_bindings and explicitly bind curl::curl_fetch_memory
  with_mocked_bindings(
    `curl_fetch_memory` = mock_fetch,
    {
      result <- parse_package_info("mockpackage")
      
      # Check that the function returns the mocked content
      expect_type(result, "character")
      expect_match(result, "Mock Content")
    },
    .package = "curl"
  )
})

test_that("parse_package_info handles non-successful response", {
  # Create a mock response object for a 404 status
  mock_response <- list(
    status_code = 404,
    content = charToRaw("")
  )
  
  # Mock curl::curl_fetch_memory
  mock_fetch <- mockery::mock(mock_response)
  
  # Use with_mocked_bindings and explicitly bind curl::curl_fetch_memory
  with_mocked_bindings(
    `curl_fetch_memory` = mock_fetch,
    {
      result <- parse_package_info("nonexistentpackage")
      
      # Check that the function returns NULL for non-successful response
      expect_null(result)
    },
    .package = "curl"
  )
})


# check_cran_package


test_that("check_cran_package returns TRUE for a valid package", {
  # Create a mock response object for a valid package
  mock_response <- list(
    status_code = 200,
    content = charToRaw("<html><body>Package ‘mockpackage’ is available.</body></html>")
  )
  
  # Mock curl::curl_fetch_memory
  mock_fetch <- mockery::mock(mock_response)
  
  # Use with_mocked_bindings
  with_mocked_bindings(
    `curl_fetch_memory` = mock_fetch,
    {
      result <- check_cran_package("mockpackage")
      
      # Check that the function returns TRUE for a valid package
      expect_true(result)
    },
    .package = "curl"
  )
})

test_that("check_cran_package returns FALSE for a removed package", {
  # Create a mock response object for a removed package
  mock_response <- list(
    status_code = 200,
    content = charToRaw("<html><body>Package ‘mockpackage’ was removed from the CRAN repository.</body></html>")
  )
  
  # Mock curl::curl_fetch_memory
  mock_fetch <- mockery::mock(mock_response)
  
  # Use local_mocked_bindings instead of with_mocked_bindings (newer approach)
  local_mocked_bindings(curl_fetch_memory = mock_fetch, .package = "curl")
  
  # Call function
  result <- check_cran_package("mockpackage")
  
  # Expect FALSE because the package was removed
  expect_false(result)
})


test_that("check_cran_package returns FALSE for a package containing a point ", {
  # Create a mock response object for a removed package
  mock_response <- list(
    status_code = 200,
    content = charToRaw("<!DOCTYPE html>\n<html>\n<head>\n<title>CRAN: Package assertive.base</title>\n<link rel=\"canonical\" href=\"https://CRAN.R-project.org/package=assertive.base\"/>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"../../CRAN_web.css\"/>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=yes\"/>\n</head>\n<body>\n<div class=\"container\">\n<p>Package &lsquo;assertive.base&rsquo; was removed from the CRAN repository.</p>\n<p>\nFormerly available versions can be obtained from the\n<a href=\"https://CRAN.R-project.org/src/contrib/Archive/assertive.base\"><span class=\"CRAN\">archive</span></a>.\n</p>\n<p>\nArchived on 2024-04-12 as issues were not corrected despite reminders.\n</p>\n<p>A summary of the most recent check results can be obtained from the <a href=\"https://cran-archive.R-project.org/web/checks/2024/2024-04-12_check_results_assertive.base.html\"><span class=\"CRAN\">check results archive</span></a>.</p>\n<p>Please use the canonical form\n<a href=\"https://CRAN.R-project.org/package=assertive.base\"><span class=\"CRAN\"><samp>https://CRAN.R-project.org/package=assertive.base</samp></span></a>\nto link to this page.</p>\n</div>\n</body>\n</html>\n")
  )
  
  # Mock curl::curl_fetch_memory
  mock_fetch <- mockery::mock(mock_response)
  local_mocked_bindings(curl_fetch_memory = mock_fetch, .package = "curl")
  result <- check_cran_package("assertive.base")
  
  # Expect FALSE because the package was removed
  expect_false(result)
})


test_that("check_cran_package returns FALSE for a non-existent package", {
  # Create a mock response object for a 404 status
  mock_response <- list(
    status_code = 404,
    content = charToRaw("")
  )
  
  # Mock curl::curl_fetch_memory
  mock_fetch <- mockery::mock(mock_response)
  
  # Use with_mocked_bindings
  with_mocked_bindings(
    `curl_fetch_memory` = mock_fetch,
    {
      result <- check_cran_package("nonexistentpackage")
      
      # Check that the function returns FALSE for a non-existent package
      expect_false(result)
    },
    .package = "curl"
  )
})


# get_cran_package_url

test_that("get_cran_package_url returns URL for the latest version when version is NULL", {
  result <- get_cran_package_url("mockpackage", NULL, "1.1.0", c("1.0.0", "1.1.0"))
  expect_equal(result, "https://cran.r-project.org/src/contrib/mockpackage_1.1.0.tar.gz")
})

test_that("get_cran_package_url returns URL for the latest version when explicitly provided", {
  result <- get_cran_package_url("mockpackage", "1.1.0", "1.1.0", c("1.0.0", "1.1.0"))
  expect_equal(result, "https://cran.r-project.org/src/contrib/mockpackage_1.1.0.tar.gz")
})

test_that("get_cran_package_url returns URL for a specific older version", {
  result <- get_cran_package_url("mockpackage", "1.0.0", "1.1.0", c("1.0.0", "1.1.0"))
  expect_equal(result, "https://cran.r-project.org/src/contrib/Archive/mockpackage/mockpackage_1.0.0.tar.gz")
})

test_that("get_cran_package_url returns NULL for a version that doesn't exist", {
  result <- get_cran_package_url("mockpackage", "2.0.0", "1.1.0", c("1.0.0", "1.1.0"))
  expect_equal(result, "No valid URL found")
})


# Test cases: get_versions

test_that("get_versions empty table", {
  # Mock input table
  mock_table <- NULL
  
  # Mock package name
  package_name <- "mockpackage"
  
  # Mock curl_fetch_memory
  mock_response <- list(
    status_code = 200,
    content = charToRaw('{"version": "1.2.0"}') 
  )
  mock_curl_fetch <- mockery::mock(mock_response)
  
  # Use with_mocked_bindings to mock curl_fetch_memory
  with_mocked_bindings(
    curl_fetch_memory = mock_curl_fetch,
    {
      # Call the function with mocked table and package name
      result <- get_versions(mock_table, package_name)
      # Validate the result
      expect_equal(result$all_versions, c("1.2.0"))
      expect_equal(result$last_version, "1.2.0")
      
    },
    .package = "curl" 
  )
})

test_that("get_versions extracts and combines versions correctly", {
  # Mock input table
  mock_table <- list(
    list(package_version = "1.0.0"),
    list(package_version = "1.1.0")
  )
  
  # Mock package name
  package_name <- "mockpackage"
  
  # Mock curl_fetch_memory
  mock_response <- list(
    status_code = 200,
    content = charToRaw('{"version": "1.2.0"}') 
  )
  mock_curl_fetch <- mockery::mock(mock_response)
  
  # Use with_mocked_bindings to mock curl_fetch_memory
  with_mocked_bindings(
    curl_fetch_memory = mock_curl_fetch,
    {
      # Call the function with mocked table and package name
      result <- get_versions(mock_table, package_name)
      # Validate the result
      expect_equal(result$all_versions, c("1.0.0", "1.1.0", "1.2.0"))
      expect_equal(result$last_version, "1.2.0")
      
    },
    .package = "curl" 
  )
})



test_that("get_versions handles invalid API response", {
  # Mock input table
  mock_table <- list(
    list(package_version = "1.0.0"),
    list(package_version = "1.1.0")
  )
  
  # Mock package name
  package_name <- "mockpackage"
  
  # Mock curl_fetch_memory
  mock_response <- list(
    status_code = 500,  # Simulate a failed API request
    content = charToRaw("")
  )
  mock_curl_fetch <- mockery::mock(mock_response)
  
  # Use with_mocked_bindings to mock curl_fetch_memory
  with_mocked_bindings(
    curl_fetch_memory = mock_curl_fetch,
    {
      # Call the function with mocked table and package name
      result <- get_versions(mock_table, package_name)
      # Validate the result
      expect_equal(result$all_versions, c("1.0.0", "1.1.0"))  # Only table versions
      expect_null(result$last_version)  # API did not return a version
    },
    .package = "curl"
  )
})


test_that("get_versions removes duplicate versions", {
  # Mock input table
  mock_table <- list(
    list(package_version = "1.0.0"),
    list(package_version = "1.0.0"),  # Duplicate
    list(package_version = "1.1.0")
  )
  
  # Mock package name
  package_name <- "mockpackage"
  
  # Mock curl_fetch_memory
  mock_response <- list(
    status_code = 200,
    content = charToRaw('{"version": "1.1.0"}')  # Simulate a duplicate version from the API
  )
  mock_curl_fetch <- mockery::mock(mock_response)
  
  # Use with_mocked_bindings to mock curl_fetch_memory
  with_mocked_bindings(
    curl_fetch_memory = mock_curl_fetch,
    {
      # Call the function with mocked table and package name
      result <- get_versions(mock_table, package_name)
      # Validate the result
      expect_equal(result$all_versions, c("1.0.0", "1.1.0"))  # Unique versions only
      expect_equal(result$last_version, "1.1.0")  # Latest version
    },
    .package = "curl"
  )
})

test_that("get_versions handles missing API version", {
  # Mock input table
  mock_table <- list(
    list(package_version = "1.0.0"),
    list(package_version = "1.1.0")
  )
  
  # Mock package name
  package_name <- "mockpackage"
  
  # Mock curl_fetch_memory
  mock_response <- list(
    status_code = 200,
    content = charToRaw('{}')  # API response has no version
  )
  mock_curl_fetch <- mockery::mock(mock_response)
  
  # Use with_mocked_bindings to mock curl_fetch_memory
  with_mocked_bindings(
    curl_fetch_memory = mock_curl_fetch,
    {
      # Call the function with mocked table and package name
      result <- get_versions(mock_table, package_name)
      # Validate the result
      expect_equal(result$all_versions, c("1.0.0", "1.1.0"))  
      expect_null(result$last_version)  
    },
    .package = "curl"
  )
})


# Test cases: check_and_fetch_cran_package

test_that("check_and_fetch_cran_package fetches the correct URL for the latest version", {
  # Mock check_cran_package to return TRUE
  mock_check_cran_package <- mockery::mock(TRUE)
  
  # Mock parse_package_info to return dummy HTML
  mock_parse_package_info <- mockery::mock("<html>Mock HTML Content</html>")
  
  # Mock parse_html_version to return dummy table
  mock_parse_html_version <- mockery::mock(list(
    list(package_version = "1.0.0"),
    list(package_version = "1.1.0")
  ))
  
  # Mock get_versions to return versions
  mock_get_versions <- mockery::mock(list(
    all_versions = c("1.0.0", "1.1.0", "1.2.0"),
    last_version = "1.2.0"
  ))
  
  # Mock get_cran_package_url to return the latest version URL
  mock_get_cran_package_url <- mockery::mock("https://cran.r-project.org/src/contrib/mockpackage_1.1.0.tar.gz")
  
  # Use with_mocked_bindings to mock all dependencies
  with_mocked_bindings(
    check_cran_package = mock_check_cran_package,
    parse_package_info = mock_parse_package_info,
    parse_html_version = mock_parse_html_version,
    get_versions = mock_get_versions,
    get_cran_package_url = mock_get_cran_package_url,
    {
      # Call the function
      result <- check_and_fetch_cran_package("mockpackage")
      
      # Validate the result
      expect_equal(result$package_url, "https://cran.r-project.org/src/contrib/mockpackage_1.1.0.tar.gz")
      expect_equal(result$last_version, "1.2.0")
      expect_null(result$version)  
      expect_equal(result$all_versions, c("1.0.0", "1.1.0", "1.2.0"))
    }
  )
})


test_that("check_and_fetch_cran_package handles specific version correctly", {
  # Mock check_cran_package to return TRUE
  mock_check_cran_package <- mockery::mock(TRUE)
  
  # Mock parse_package_info to return dummy HTML
  mock_parse_package_info <- mockery::mock("<html>Mock HTML Content</html>")
  
  # Mock parse_html_version to return dummy table
  mock_parse_html_version <- mockery::mock(list(
    list(package_version = "1.0.0"),
    list(package_version = "1.1.0")
  ))
  
  # Mock get_versions to return versions
  mock_get_versions <- mockery::mock(list(
    all_versions = c("1.0.0", "1.1.0"),
    last_version = "1.1.0"
  ))
  
  # Mock get_cran_package_url to return the URL for a specific version
  mock_get_cran_package_url <- mockery::mock("https://cran.r-project.org/src/contrib/Archive/mockpackage/mockpackage_1.0.0.tar.gz")
  
  # Use with_mocked_bindings to mock all dependencies
  with_mocked_bindings(
    check_cran_package = mock_check_cran_package,
    parse_package_info = mock_parse_package_info,
    parse_html_version = mock_parse_html_version,
    get_versions = mock_get_versions,
    get_cran_package_url = mock_get_cran_package_url,
    {
      # Call the function with a specific version
      result <- check_and_fetch_cran_package("mockpackage", "1.0.0")
      
      # Validate the result
      expect_equal(result$package_url, "https://cran.r-project.org/src/contrib/Archive/mockpackage/mockpackage_1.0.0.tar.gz")
      expect_equal(result$version, "1.0.0")
      expect_equal(result$last_version, "1.1.0")
      expect_equal(result$all_versions, c("1.0.0", "1.1.0"))
    }
  )
})

test_that("check_and_fetch_cran_package handles missing version", {
  # Mock check_cran_package to return TRUE
  mock_check_cran_package <- mockery::mock(TRUE)
  
  # Mock parse_package_info to return dummy HTML
  mock_parse_package_info <- mockery::mock("<html>Mock HTML Content</html>")
  
  # Mock parse_html_version to return dummy table
  mock_parse_html_version <- mockery::mock(list(
    list(package_version = "1.0.0"),
    list(package_version = "1.1.0")
  ))
  
  # Mock get_versions to return versions
  mock_get_versions <- mockery::mock(list(
    all_versions = c("1.0.0", "1.1.0"),
    last_version = "1.1.0"
  ))
  
  # Mock get_cran_package_url to return NULL (version not found)
  mock_get_cran_package_url <- mockery::mock(NULL)
  
  # Use with_mocked_bindings to mock all dependencies
  with_mocked_bindings(
    check_cran_package = mock_check_cran_package,
    parse_package_info = mock_parse_package_info,
    parse_html_version = mock_parse_html_version,
    get_versions = mock_get_versions,
    get_cran_package_url = mock_get_cran_package_url,
    {
      # Call the function with a non-existent version
      result <- check_and_fetch_cran_package("mockpackage", "2.0.0")
      
      # Validate the result
      expect_equal(result$error, "Version 2.0.0 for mockpackage not found")
      expect_match(result$version_available, "1.0.0, 1.1.0")
      
    }
  )
})

test_that("check_and_fetch_cran_package with version table null", {
  # Mock check_cran_package to return TRUE
  mock_check_cran_package <- mockery::mock(TRUE)
  
  # Mock parse_package_info to return dummy HTML
  mock_parse_package_info <- mockery::mock(NULL)
  
  # Mock parse_html_version to return dummy table
  mock_parse_html_version <- mockery::mock(NULL)
  
  # Mock get_versions to return versions
  mock_get_versions <- mockery::mock(list(
    all_versions = c("1.2.0"),
    last_version = "1.2.0"
  ))
  
  # Mock get_cran_package_url to return the latest version URL
  mock_get_cran_package_url <- mockery::mock("https://cran.r-project.org/src/contrib/mockpackage_1.2.0.tar.gz")
  
  # Use with_mocked_bindings to mock all dependencies
  with_mocked_bindings(
    check_cran_package = mock_check_cran_package,
    parse_package_info = mock_parse_package_info,
    parse_html_version = mock_parse_html_version,
    get_versions = mock_get_versions,
    get_cran_package_url = mock_get_cran_package_url,
    {
      # Call the function
      result <- check_and_fetch_cran_package("mockpackage")
      
      # Validate the result
      expect_equal(result$package_url, "https://cran.r-project.org/src/contrib/mockpackage_1.2.0.tar.gz")
      expect_equal(result$last_version, "1.2.0")
      expect_null(result$version)  
      expect_equal(result$all_versions, c("1.2.0"))
    }
  )
})


# get_internal_package_url

test_that("check_and_fetch_cran_package with version table null", {
  # Mock check_cran_package to return TRUE
  mock_check_cran_package <- mockery::mock(TRUE)
  
  # Mock parse_package_info to return dummy HTML
  mock_parse_package_info <- mockery::mock(NULL)
  
  # Mock parse_html_version to return dummy table
  mock_parse_html_version <- mockery::mock(NULL)
  
  # Mock get_versions to return versions
  mock_get_versions <- mockery::mock(list(
    all_versions = c("1.2.0"),
    last_version = "1.2.0"
  ))
  
  # Mock get_cran_package_url to return the latest version URL
  mock_get_cran_package_url <- mockery::mock("https://cran.r-project.org/src/contrib/mockpackage_1.2.0.tar.gz")
  
  # Use with_mocked_bindings to mock all dependencies
  with_mocked_bindings(
    check_cran_package = mock_check_cran_package,
    parse_package_info = mock_parse_package_info,
    parse_html_version = mock_parse_html_version,
    get_versions = mock_get_versions,
    get_cran_package_url = mock_get_cran_package_url,
    {
      # Call the function
      result <- check_and_fetch_cran_package("mockpackage")
      
      # Validate the result
      expect_equal(result$package_url, "https://cran.r-project.org/src/contrib/mockpackage_1.2.0.tar.gz")
      expect_equal(result$last_version, "1.2.0")
      expect_null(result$version)  
      expect_equal(result$all_versions, c("1.2.0"))
    }
  )
})

test_that("get_internal_package_url works correctly", {
  # Corrected mock response including status_code
  mock_response <- list(
    content = charToRaw(enc2utf8('{
      "version": "1.2.0",
      "archived": [{"version": "1.0.0"}, {"version": "1.1.0"}]
    }')),
    status_code = 200 
  )
  
  # Create mock for curl_fetch_memory
  mock_curl_fetch_memory <- mockery::mock(mock_response)
  
  # Mock curl_fetch_memory in the "curl" package
  local_mocked_bindings(curl_fetch_memory = mock_curl_fetch_memory, .package = "curl")
  
  # Call the function
  result <- get_internal_package_url("mockpackage")
  
  # Validate the result
  expect_equal(result$url, "http://cran.us.r-project.org/src/contrib/mockpackage_1.2.0.tar.gz")
  expect_equal(result$last_version, "1.2.0")
  expect_equal(result$all_versions, c("1.2.0", "1.0.0", "1.1.0"))
})


test_that("get_internal_package_url works correctly", {
  # Corrected mock response including status_code
  mock_response <- list(
    content = charToRaw(enc2utf8('{
      "version": "1.2.0",
      "archived": [{"version": "1.0.0"}, {"version": "1.1.0"}]
    }')),
    status_code = 200  
  )
  
  mock_curl_fetch_memory <- mockery::mock(mock_response)
  local_mocked_bindings(curl_fetch_memory = mock_curl_fetch_memory, .package = "curl")
  
  result <- get_internal_package_url("mockpackage")
  
  # Validate the result
  expect_equal(result$url, "http://cran.us.r-project.org/src/contrib/mockpackage_1.2.0.tar.gz")
  expect_equal(result$last_version, "1.2.0")
  expect_equal(result$all_versions, c("1.2.0", "1.0.0", "1.1.0"))
})

test_that("get_internal_package_url works correctly for archived version", {
  mock_response <- list(
    content = charToRaw(enc2utf8('{
      "version": "1.2.0",
      "archived": [{"version": "1.0.0"}, {"version": "1.1.0"}]
    }')),
    status_code = 200
  )
  
  mock_curl_fetch_memory <- mockery::mock(mock_response)
  local_mocked_bindings(curl_fetch_memory = mock_curl_fetch_memory, .package = "curl")
  
  result <- get_internal_package_url("mockpackage", "1.0.0")
  
  # Validate the result
  expect_equal(result$url, "http://cran.us.r-project.org/src/contrib/Archive/mockpackage/mockpackage_1.0.0.tar.gz")
  expect_equal(result$last_version, "1.2.0")
  expect_equal(result$all_versions, c("1.2.0", "1.0.0", "1.1.0"))
})

test_that("get_internal_package_url works correctly when no last version exists", {
  mock_response <- list(
    content = charToRaw(enc2utf8('{
      "archived": [{"version": "1.0.0"}, {"version": "1.1.0"}]
    }')),
    status_code = 200
  )
  
  mock_curl_fetch_memory <- mockery::mock(mock_response)
  local_mocked_bindings(curl_fetch_memory = mock_curl_fetch_memory, .package = "curl")
  
  result <- get_internal_package_url("mockpackage", "1.0.0")
  
  # Validate the result
  expect_null(result$url)
  expect_null(result$last_version)
  expect_equal(result$all_versions, c("1.0.0", "1.1.0"))
})

test_that("get_internal_package_url works correctly when no archived versions exist", {
  mock_response <- list(
    content = charToRaw(enc2utf8('{
      "version": "1.2.0"
    }')),
    status_code = 200
  )
  
  mock_curl_fetch_memory <- mockery::mock(mock_response)
  local_mocked_bindings(curl_fetch_memory = mock_curl_fetch_memory, .package = "curl")
  
  result <- get_internal_package_url("mockpackage", "1.2.0")
  
  # Validate the result
  expect_equal(result$url, "http://cran.us.r-project.org/src/contrib/mockpackage_1.2.0.tar.gz")
  expect_equal(result$last_version, "1.2.0")
  expect_equal(result$all_versions, c("1.2.0"))
})

test_that("empty response is handled correctly", {
  mock_response <- list(
    content = raw(0),
    status_code = 200
  )
  
  mock_curl_fetch_memory <- mockery::mock(mock_response)
  local_mocked_bindings(curl_fetch_memory = mock_curl_fetch_memory, .package = "curl")
  
  result <- get_internal_package_url("mockpackage")
  
  # Validate the result
  expect_null(result$url)
  expect_null(result$last_version)
  expect_equal(result$all_versions, list())
})

test_that("invalid JSON response is handled correctly", {
  mock_response <- list(
    content = charToRaw("Invalid JSON"),
    status_code = 200
  )
  
  mock_curl_fetch_memory <- mockery::mock(mock_response)
  local_mocked_bindings(curl_fetch_memory = mock_curl_fetch_memory, .package = "curl")
  
  result <- get_internal_package_url("mockpackage")
  
  # Validate the result
  expect_null(result$url)
  expect_null(result$last_version)
  expect_equal(result$all_versions, list())
})

test_that("API returns 404 (package not found)", {
  mock_response <- list(
    content = charToRaw("Not Found"),
    status_code = 404 
  )
  
  mock_curl_fetch_memory <- mockery::mock(mock_response)
  local_mocked_bindings(curl_fetch_memory = mock_curl_fetch_memory, .package = "curl")
  
  result <- get_internal_package_url("nonexistentpackage")
  
  # Validate the result
  expect_null(result$url)
  expect_null(result$last_version)
  expect_equal(result$all_versions, list())
})



# get_host_package


test_that("get_host_package returns correct links for valid inputs", {
  # Mock description$new
  mock_description <- mockery::mock(list(
    str = function() "Mocked DESCRIPTION content",
    get_urls = function() c("https://github.com/owner1/mockpackage"),
    has_fields = function(field) field == "BugReports",
    get_list = function(field) {
      if (field == "BugReports") "https://github.com/owner1/mockpackage/issues"
    }
  ))
  
  # Stub description$new
  mockery::stub(get_host_package, "description$new", mock_description)
  
  # Mock other dependencies
  mock_check_cran_package <- mockery::mock(TRUE)
  mock_parse_package_info <- mockery::mock("<html>Mock Archive Content</html>")
  mock_parse_html_version <- mockery::mock(list(
    list(package_version = "1.0.0"),
    list(package_version = "1.1.0")
  ))
  mock_check_and_fetch_cran_package <- mockery::mock(list(
    last_version = "1.1.0",
    all_versions = c("1.0.0", "1.1.0")
  ))
  mock_get_cran_package_url <- mockery::mock("https://cran.r-project.org/src/contrib/mockpackage_1.1.0.tar.gz")
  mock_get_internal_package_url <- mockery::mock(list(
    url = "https://rstudio-pm.prod.example.com/mockpackage_1.1.0.tar.gz",
    last_version = "1.1.0",
    all_versions = c("1.0.0", "1.1.0")
  ))
  
  # Use local_mocked_bindings for other dependencies
  with_mocked_bindings(
    check_cran_package = mock_check_cran_package,
    parse_package_info = mock_parse_package_info,
    parse_html_version = mock_parse_html_version,
    check_and_fetch_cran_package = mock_check_and_fetch_cran_package,
    get_cran_package_url = mock_get_cran_package_url,
    get_internal_package_url = mock_get_internal_package_url,
    {
      # Call the function with mocked dependencies
      result <- get_host_package("mockpackage", "1.1.0", "/path/to/source")
      
      # Validate the result
      expect_equal(result$github_links, "https://github.com/owner1/mockpackage")
      expect_equal(result$cran_links, "https://cran.r-project.org/src/contrib/mockpackage_1.1.0.tar.gz")
      expect_equal(result$internal_links, "https://rstudio-pm.prod.example.com/mockpackage_1.1.0.tar.gz")
      expect_equal(result$bioconductor_links, "No Bioconductor link found")
    }
  )
})

test_that("get_host_package with github name and CRAN name different", {
  # Mock description$new
  mock_description <- mockery::mock(list(
    str = function() "Mocked DESCRIPTION content",
    get_urls = function() c("https://github.com/ow-ner1/mockpackage_no_cran"),
    has_fields = function(field) field == "BugReports",
    get_list = function(field) {
      if (field == "BugReports") "https://github.com/ow-ner1/mockpackage_no_cran/issues"
    }
  ))
  
  # Stub description$new
  mockery::stub(get_host_package, "description$new", mock_description)
  
  # Mock other dependencies
  mock_check_cran_package <- mockery::mock(TRUE)
  mock_parse_package_info <- mockery::mock("<html>Mock Archive Content</html>")
  mock_parse_html_version <- mockery::mock(list(
    list(package_version = "1.0.0"),
    list(package_version = "1.1.0")
  ))
  mock_check_and_fetch_cran_package <- mockery::mock(list(
    last_version = "1.1.0",
    all_versions = c("1.0.0", "1.1.0")
  ))
  mock_get_cran_package_url <- mockery::mock("https://cran.r-project.org/src/contrib/mockpackage_1.1.0.tar.gz")
  mock_get_internal_package_url <- mockery::mock(list(
    url = "https://rstudio-pm.prod.example.com/mockpackage_1.1.0.tar.gz",
    last_version = "1.1.0",
    all_versions = c("1.0.0", "1.1.0")
  ))
  
  # Use local_mocked_bindings for other dependencies
  with_mocked_bindings(
    check_cran_package = mock_check_cran_package,
    parse_package_info = mock_parse_package_info,
    parse_html_version = mock_parse_html_version,
    check_and_fetch_cran_package = mock_check_and_fetch_cran_package,
    get_cran_package_url = mock_get_cran_package_url,
    get_internal_package_url = mock_get_internal_package_url,
    {
      # Call the function with mocked dependencies
      result <- get_host_package("mockpackage", "1.1.0", "/path/to/source")
      
      # Validate the result
      expect_equal(result$github_links, "https://github.com/ow-ner1/mockpackage_no_cran")
      expect_equal(result$cran_links, "https://cran.r-project.org/src/contrib/mockpackage_1.1.0.tar.gz")
      expect_equal(result$internal_links, "https://rstudio-pm.prod.example.com/mockpackage_1.1.0.tar.gz")
      expect_equal(result$bioconductor_links, "No Bioconductor link found")
    }
  )
})

test_that("get_host_package with no github link, no bug report", {
  # Mock description$new
  mock_description <- mockery::mock(list(
    str = function() "Mocked DESCRIPTION content",
    get_urls = function() c(""),
    has_fields = function(field) field == "BugReports",
    get_list = function(field) {
      if (field == "BugReports") ""
    }
  ))
  
  # Stub description$new
  mockery::stub(get_host_package, "description$new", mock_description)
  
  # Mock other dependencies
  mock_check_cran_package <- mockery::mock(TRUE)
  mock_parse_package_info <- mockery::mock("<html>Mock Archive Content</html>")
  mock_parse_html_version <- mockery::mock(list(
    list(package_version = "1.0.0"),
    list(package_version = "1.1.0")
  ))
  mock_check_and_fetch_cran_package <- mockery::mock(list(
    last_version = "1.1.0",
    all_versions = c("1.0.0", "1.1.0")
  ))
  mock_get_cran_package_url <- mockery::mock("https://cran.r-project.org/src/contrib/mockpackage_1.1.0.tar.gz")
  mock_get_internal_package_url <- mockery::mock(list(
    url = "https://rstudio-pm.prod.example.com/mockpackage_1.1.0.tar.gz",
    last_version = "1.1.0",
    all_versions = c("1.0.0", "1.1.0")
  ))
  
  # Use local_mocked_bindings for other dependencies
  with_mocked_bindings(
    check_cran_package = mock_check_cran_package,
    parse_package_info = mock_parse_package_info,
    parse_html_version = mock_parse_html_version,
    check_and_fetch_cran_package = mock_check_and_fetch_cran_package,
    get_cran_package_url = mock_get_cran_package_url,
    get_internal_package_url = mock_get_internal_package_url,
    {
      # Call the function with mocked dependencies
      result <- get_host_package("mockpackage", "1.1.0", "/path/to/source")
      
      # Validate the result
      expect_equal(result$github_links, "No GitHub link found")
      expect_equal(result$cran_links, "https://cran.r-project.org/src/contrib/mockpackage_1.1.0.tar.gz")
      expect_equal(result$internal_links, "https://rstudio-pm.prod.example.com/mockpackage_1.1.0.tar.gz")
      expect_equal(result$bioconductor_links, "No Bioconductor link found")
    }
  )
})

test_that("get_host_package with github name, but not bug report", {
  # Mock description$new
  mock_description <- mockery::mock(list(
    str = function() "Mocked DESCRIPTION content",
    get_urls = function() c(""),
    has_fields = function(field) field == "BugReports",
    get_list = function(field) {
      if (field == "BugReports") "https://github.com/ow-ner1/mockpackage_no_cran/issues"
    }
  ))
  
  # Stub description$new
  mockery::stub(get_host_package, "description$new", mock_description)
  
  # Mock other dependencies
  mock_check_cran_package <- mockery::mock(TRUE)
  mock_parse_package_info <- mockery::mock("<html>Mock Archive Content</html>")
  mock_parse_html_version <- mockery::mock(list(
    list(package_version = "1.0.0"),
    list(package_version = "1.1.0")
  ))
  mock_check_and_fetch_cran_package <- mockery::mock(list(
    last_version = "1.1.0",
    all_versions = c("1.0.0", "1.1.0")
  ))
  mock_get_cran_package_url <- mockery::mock("https://cran.r-project.org/src/contrib/mockpackage_1.1.0.tar.gz")
  mock_get_internal_package_url <- mockery::mock(list(
    url = "https://rstudio-pm.prod.example.com/mockpackage_1.1.0.tar.gz",
    last_version = "1.1.0",
    all_versions = c("1.0.0", "1.1.0")
  ))
  
  # Use local_mocked_bindings for other dependencies
  with_mocked_bindings(
    check_cran_package = mock_check_cran_package,
    parse_package_info = mock_parse_package_info,
    parse_html_version = mock_parse_html_version,
    check_and_fetch_cran_package = mock_check_and_fetch_cran_package,
    get_cran_package_url = mock_get_cran_package_url,
    get_internal_package_url = mock_get_internal_package_url,
    {
      # Call the function with mocked dependencies
      result <- get_host_package("mockpackage", "1.1.0", "/path/to/source")
      
      # Validate the result
      expect_equal(result$github_links, "https://github.com/ow-ner1/mockpackage_no_cran")
      expect_equal(result$cran_links, "https://cran.r-project.org/src/contrib/mockpackage_1.1.0.tar.gz")
      expect_equal(result$internal_links, "https://rstudio-pm.prod.example.com/mockpackage_1.1.0.tar.gz")
      expect_equal(result$bioconductor_links, "No Bioconductor link found")
    }
  )
})

test_that("get_host_package with no github name, but bug report", {
  # Mock description$new
  mock_description <- mockery::mock(list(
    str = function() "Mocked DESCRIPTION content",
    get_urls = function() c("https://github.com/ow-ner1/mockpackage_no_cran"),
    has_fields = function(field) field == "BugReports",
    get_list = function(field) {
      if (field == "BugReports") ""
    }
  ))
  
  # Stub description$new
  mockery::stub(get_host_package, "description$new", mock_description)
  
  # Mock other dependencies
  mock_check_cran_package <- mockery::mock(TRUE)
  mock_parse_package_info <- mockery::mock("<html>Mock Archive Content</html>")
  mock_parse_html_version <- mockery::mock(list(
    list(package_version = "1.0.0"),
    list(package_version = "1.1.0")
  ))
  mock_check_and_fetch_cran_package <- mockery::mock(list(
    last_version = "1.1.0",
    all_versions = c("1.0.0", "1.1.0")
  ))
  mock_get_cran_package_url <- mockery::mock("https://cran.r-project.org/src/contrib/mockpackage_1.1.0.tar.gz")
  mock_get_internal_package_url <- mockery::mock(list(
    url = "https://rstudio-pm.prod.example.com/mockpackage_1.1.0.tar.gz",
    last_version = "1.1.0",
    all_versions = c("1.0.0", "1.1.0")
  ))
  
  # Use local_mocked_bindings for other dependencies
  with_mocked_bindings(
    check_cran_package = mock_check_cran_package,
    parse_package_info = mock_parse_package_info,
    parse_html_version = mock_parse_html_version,
    check_and_fetch_cran_package = mock_check_and_fetch_cran_package,
    get_cran_package_url = mock_get_cran_package_url,
    get_internal_package_url = mock_get_internal_package_url,
    {
      # Call the function with mocked dependencies
      result <- get_host_package("mockpackage", "1.1.0", "/path/to/source")
      
      # Validate the result
      expect_equal(result$github_links, "https://github.com/ow-ner1/mockpackage_no_cran")
      expect_equal(result$cran_links, "https://cran.r-project.org/src/contrib/mockpackage_1.1.0.tar.gz")
      expect_equal(result$internal_links, "https://rstudio-pm.prod.example.com/mockpackage_1.1.0.tar.gz")
      expect_equal(result$bioconductor_links, "No Bioconductor link found")
    }
  )
})