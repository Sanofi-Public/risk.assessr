#' Fetch GitHub Repository Data
#'
#' This function retrieves metadata about a GitHub repository, including creation date,
#' stars, forks, and the number of recent commits within the last 30 days.
#'
#' @param owner A character string specifying the owner of the repository (e.g., GitHub username).
#' @param repo A character string specifying the name of the repository.
#' A github Personal Access Token (PAT) will be needed for some request or to help with the rate limit.
#' 
#' Use Sys.setenv(GITHUB_TOKEN = "personal_access_token") or store your token in a .Renviron file
#' (GitHub fine grained token are not yet covered by gh)
#'
#' @return A list containing:
#'   - `created_at`: Creation date of the repository.
#'   - `stars`: Number of stars the repository 
#'   - `forks`: Number of forks of the repository.
#'   - `date`: acquisition date in the format "YYYY-MM-DD".
#'   - `recent_commits_count`: count of commits in the last 30 days (from acquisition date).
#'
#' @details
#' If the `owner` parameter is `NA` or empty, the function returns an empty response object.
#' Repository data is fetched using the GitHub API via the `gh` package.
#'
#' @examples
#' \dontrun{
#' # Fetch data for the "ggplot2" repository owned by "tidyverse"
#' result <- get_github_data("tidyverse", "ggplot2")
#' print(result)
#'}
#' @importFrom gh gh
#' @export
get_github_data <- function(owner, repo) {
  
  message(glue::glue("Checking github data"))
  
  # Initialize an empty response object
  empty_response <- list(
    created_at = NULL,
    stars = NULL,
    forks = NULL,
    date = NULL,
    recent_commits_count = NULL
  )
  
  # Check if the owner is NA or invalid
  if (is.na(owner) || owner == "") {
    message("Owner is NA or empty. Returning empty response object.\n")
    return(empty_response)
  }
  
  # Get today's date
  todays_date <- Sys.Date()
  
  # Fetch repository details
  repo_info <- tryCatch({
    gh::gh("GET /repos/{owner}/{repo}", owner = owner, repo = repo)
  }, error = function(e) {
    message("Failed to fetch repository details: ", conditionMessage(e), "\n")
    return(NULL)
  })
  
  if (is.null(repo_info)) {
    return(empty_response)
  }
  
  # Extract specific information
  created_at <- repo_info$created_at
  stars <- repo_info$stargazers_count
  forks <- repo_info$forks_count
  open_issues <- repo_info$open_issues_count
  
  # Get recent commits count (last 30 days)
  since <- as.character(todays_date - 30)
  commits <- tryCatch({
    gh::gh("GET /repos/{owner}/{repo}/commits", owner = owner, repo = repo, since = since)
  }, error = function(e) {
    message("Failed to fetch commits: ", conditionMessage(e), "\n")
    return(NULL)
  })
  
  recent_commits_count <- if (!is.null(commits)) length(commits) else 0
  
  # Format the dates
  formatted_created_at <- format(as.Date(created_at), "%Y-%m-%d")
  formatted_todays_date <- format(todays_date, "%Y-%m-%d")
  
  # Create the response object
  result <- list(
    created_at = created_at,
    stars = stars,
    forks = forks,
    date = formatted_todays_date,
    recent_commits_count = recent_commits_count
  )
  return(result)
}


#' Extract GitHub repository owner from links
#'
#' Given a vector of GitHub links and a package name, this function finds the link
#' corresponding to the package and extracts the GitHub repository owner.
#'
#' @param links A character vector of GitHub URLs.
#' @param pkg_name A string representing the name of the package.
#'
#' @return A string containing the GitHub repository owner, or NA if not found.
#' @keywords internal
get_repo_owner <- function(links, pkg_name) {
  if (!is.null(links) && all(links != "No GitHub link found")) {
    # Remove trailing slashes
    links <- sub("/+$", "", links)
    
    matching_link <- links[grepl(paste0("/", pkg_name, "$"), links)]
    
    if (length(matching_link) > 0) {
      return(sub("https://github.com/([^/]+)/.*", "\\1", matching_link[1]))
    } else {
      return(NA)
    }
  } else {
    return(NA)
  }
}