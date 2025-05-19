# Mock implementation of gh
mock_gh <- function(endpoint, ...) {
  if (grepl("/repos/.+/commits", endpoint)) {
    # Mock response for commits endpoint
    return(replicate(10, list(commit = list(message = "Mock commit")), simplify = FALSE))
  } else if (grepl("/repos/.+/.+", endpoint)) {
    # Mock response for repository details
    return(list(
      created_at = "2015-06-17T09:29:49Z",
      stargazers_count = 5674,
      forks_count = 2040,
      open_issues_count = 42
    ))
  }
  stop("Unknown endpoint")
}

mock_gh_failure <- function(endpoint, ...) {
  stop("Mocked API call failure")
}

# Test cases
test_that("Valid repository returns correct data", {
  local_mocked_bindings(gh = mock_gh, .package = "gh")
  
  result <- get_github_data("tidyverse", "ggplot2")
  
  # Test the structure and contents of the result
  expect_type(result, "list")
  expect_named(result, c("created_at", "stars", "forks", "date", "recent_commits_count"))
  expect_equal(result$created_at, "2015-06-17T09:29:49Z")
  expect_equal(result$stars, 5674)
  expect_equal(result$forks, 2040)
  expect_equal(result$recent_commits_count, 10)  # Mocked 10 commits
})

test_that("Invalid owner returns empty response", {
  local_mocked_bindings(gh = mock_gh, .package = "gh")
  
  result <- get_github_data("", "ggplot2")
  
  # Test for empty response
  expect_equal(result$created_at, NULL)
  expect_equal(result$stars, NULL)
  expect_equal(result$forks, NULL)
  expect_equal(result$date, NULL)
  expect_equal(result$recent_commits_count, NULL)
})

test_that("Non-existent repository returns empty response on API failure", {
  local_mocked_bindings(gh = mock_gh_failure, .package = "gh")
  
  result <- get_github_data("tidyverse", "non_existent_repo")
  
  # Test for empty response
  expect_equal(result$created_at, NULL)
  expect_equal(result$stars, NULL)
  expect_equal(result$forks, NULL)
  expect_equal(result$date, NULL)
  expect_equal(result$recent_commits_count, NULL)
})

test_that("Commits endpoint failure returns empty recent commits count", {
  mock_partial_gh <- function(endpoint, ...) {
    if (grepl("/repos/.+/commits", endpoint)) {
      stop("Mocked commits API failure")
    } else if (grepl("/repos/.+/.+", endpoint)) {
      return(list(
        created_at = "2015-06-17T09:29:49Z",
        stargazers_count = 5674,
        forks_count = 2040,
        open_issues_count = 42
      ))
    }
    stop("Unknown endpoint")
  }
  
  local_mocked_bindings(gh = mock_partial_gh, .package = "gh")
  
  result <- get_github_data("tidyverse", "ggplot2")
  
  # Test the structure and contents of the result
  expect_type(result, "list")
  expect_named(result, c("created_at", "stars", "forks", "date", "recent_commits_count"))
  expect_equal(result$created_at, "2015-06-17T09:29:49Z")
  expect_equal(result$stars, 5674)
  expect_equal(result$forks, 2040)
  expect_equal(result$recent_commits_count, 0)  # Commits endpoint failed
})

# Define the test
test_that("get_github_data handles unsuccessful API calls", {
  
  # Mock the gh::gh function to simulate an error
  mock_gh <- mockery::mock(
    stop("Simulated API failure")
  )
  
  # Replace the gh::gh function with the mock in the test
  local_mocked_bindings(gh = mock_gh, .package = "gh")
  
  # Call the function with test input
  owner <- "test_owner"
  repo <- "test_repo"
  result <- get_github_data(owner, repo)
  
  # Expected result when the API fails
  expected_result <- list(
    created_at = NULL,
    stars = NULL,
    forks = NULL,
    date = NULL,
    recent_commits_count = NULL
  )
  
  expect_equal(result, expected_result)
})

