#' Get Internal Package URL
#'
#' This function retrieves the URL of an internal package on your internal Mirror, its latest version, 
#' and a list of all available versions.
#'
#' @param package_name A character string specifying the name of the package.
#' @param version An optional character string specifying the version of the package.
#' Defaults to `NULL`, in which case the latest version will be used.
#' @param base_url a character string of internal package manager link 
#' @param internal_path a character string of internal package mirror link
#' 
#' @return A list containing:
#'   - `url`: A character string of the package URL (or `NULL` if not found).
#'   - `last_version`: A character string of the latest version of the package.
#'   - `all_versions`: A character vector of all available package versions.
#'
#' @examples
#' \dontrun{
#'
#' # Retrieve a specific version URL of a package
#' result <- get_internal_package_url("internalpackage", version = "1.0.1")
#' print(result) 
#'}
#' @importFrom curl curl_fetch_memory
#' @importFrom jsonlite fromJSON
#' @export
get_internal_package_url <- function(package_name, version = NULL,
                                     base_url = "http://cran.us.r-project.org",
                                     internal_path = "/src/contrib/") {
  
  internal_base <- paste0(base_url, "/__api__/repos/6/packages/")
  package_url <- paste0(internal_base, package_name)
  
  # Perform the GET request
  response <- tryCatch({
    curl::curl_fetch_memory(package_url)
  }, error = function(e) {
    return(NULL)
  })
  
  # Check if the response is valid
  if (is.null(response) || response$status_code == 404) {
    return(list(url = NULL, last_version = NULL, all_versions = list()))
  }
  
  # Parse response as JSON
  data <- tryCatch({
    json_content <- rawToChar(response$content)
    fromJSON(json_content)  
  }, error = function(e) {
    message("Failed to parse JSON response:", conditionMessage(e), "\n")
    return(NULL)
  })
  
  if (is.null(data)) {
    return(list(url = NULL, last_version = NULL, all_versions = list()))
  }
  
  last_version <- data$version
  all_versions <- if (!is.null(last_version)) list(last_version) else list()
  url <- NULL
  
  # Extract archived versions if available
  if (!is.null(data$archived)) {
    if (is.data.frame(data$archived)) {
      archived_versions <- data$archived$version
    } else if (is.list(data$archived)) {
      archived_versions <- sapply(data$archived, function(av) av$version)
    } else {
      archived_versions <- NULL
    }
    all_versions <- c(all_versions, archived_versions)
  }
  
  if (is.null(version) && !is.null(last_version)) {
    version <- last_version
  }
  
  if (!is.null(last_version) && !is.null(version)) {
    if (last_version %in% all_versions && last_version == version) {
      url <- paste0(base_url, internal_path,
                    package_name, "_", last_version, ".tar.gz")  
    } else if (!is.null(version) && version %in% all_versions) {
      url <- paste0(base_url, internal_path, "Archive/",
                    package_name, "/", package_name, "_", version, ".tar.gz")
    } else {
      url <- NULL
    }
  }
  
  return(list(url = url, last_version = last_version, all_versions = unlist(all_versions)))
}



#' Check if a Package Exists on CRAN
#'
#' This function checks if a given package is available on CRAN. 
#'
#' @param package_name A character string specifying the name of the package to check.
#'
#' @return A logical value: `TRUE` if the package exists on CRAN, `FALSE` otherwise.
#'
#' @examples
#' \dontrun{
#' # Check if the package "ggplot2" exists on CRAN
#' check_cran_package("ggplot2")
#' }
#' @importFrom curl curl_fetch_memory
#' @export
check_cran_package <- function(package_name) {
  base_url <- "https://cran.r-project.org/web/packages/"
  package_url <- paste0(base_url, package_name, "/index.html")
  
  # Perform GET request
  response <- curl::curl_fetch_memory(package_url)
  
  # If package does not exist, return FALSE
  if (response$status_code != 200) {
    return(FALSE)
  }
  
  content <- rawToChar(response$content)
  html_doc <- xml2::read_html(content)
  clean_content <- xml2::xml_text(html_doc)
  clean_content <- tolower(clean_content)
  
  clean_content <- gsub("[[:punct:]]", "", clean_content)
  clean_content <- gsub("\\s+", " ", clean_content)
  
  escaped_package_name <- gsub("\\.", "\\\\.", package_name)
  escaped_package_name <- gsub("[[:punct:]]", "", escaped_package_name)  
  
  removed_pattern <- paste0("package ", escaped_package_name, " was removed from the cran repository")
  
  # Check if the package has been removed
  if (grepl(removed_pattern, clean_content, ignore.case = TRUE, perl = TRUE)) {
    return(FALSE)
  }
  return(TRUE)
}




#' Parse Package Information from CRAN Archive
#'
#' This function retrieves the package archive information from the CRAN Archive.
#'
#' @param name A character string specifying the name of the package to fetch information for.
#'
#' @return A character string containing the raw HTML content of the package archive page, or `NULL`
#' if the request fails or the package is not found.
#'
#' @examples
#' \dontrun{
#' # Fetch package archive information for "dplyr"
#' result <- parse_package_info("dplyr")
#' 
#' print(result)
#'
#'}
#' @importFrom curl curl_fetch_memory
#' @export
parse_package_info <- function(name) {
  url <- paste0("https://cran.r-project.org/src/contrib/Archive/", name, "/")
  
  # Perform GET request
  response <- curl::curl_fetch_memory(url)
  
  if (response$status_code == 200) {
    return(rawToChar(response$content))
  } else {
    return(NULL)
  }
}

#' Parse HTML Version Information for a Package
#'
#' This function extracts version information from the HTML content of a CRAN archive page.
#'
#' @param html_content A character string containing the HTML content of a CRAN package archive page.
#' @param package_name A character string specifying the name of the package to extract version information for.
#'
#' @return A list of lists, where each sublist contains:
#'   - `package_name`: package name.
#'   - `package_version`: package version.
#'   - `link`: link to the package tarball.
#'   - `date`: The date associated with the package version.
#'   - `size`: The size of the package tarball.
#'
#' @importFrom xml2 read_html xml_find_all xml_find_first xml_text xml_attr
#' @keywords internal
parse_html_version <- function(html_content, package_name) {
  
  data <- list()
  
  if (!is.null(html_content)) {
    # Parse the HTML content
    doc <- xml2::read_html(html_content)
    rows <- xml2::xml_find_all(doc, "//tr")
    
    for (row in rows) {
      cols <- xml2::xml_find_all(row, "td")
      if (length(cols) >= 4) {  # Ensure it's not a divider row
        link_tag <- xml2::xml_find_first(cols[2], "a")
        
        if (!is.na(xml2::xml_text(link_tag))) {
          href <- xml2::xml_attr(link_tag, "href")
          text <- xml2::xml_text(link_tag)
          date <- xml2::xml_text(cols[3])
          size <- xml2::xml_text(cols[4])
          version <- ""
          
          if (grepl(paste0("^", package_name, "(?:_|$)"), text)) {
            version <- gsub(paste0("^", package_name, "(?:_|$)|\\.tar\\.gz$"), "", text)
          } else {
            version <- ""  
          }
          
          if (version == "Parent Directory" | version == "") {
            next
          }
          
          data <- append(data, list(
            list(
              package_name = package_name,
              package_version = version,
              link = href,
              date = date,
              size = size
            )
          ))
        }
      }
    }
  }
  
  return(data)
}


#' Get Package Versions
#'
#' This function retrieves all available versions including last version from parse_html_version function'
#' @param table A list of parsed package data, where each element contains package details including package_version.
#' @param package_name A character string specifying the name of the package to fetch versions for.
#'
#' @return A list containing:
#'   - `all_versions`: A character vector of all unique package versions.
#'   - `last_version`: A character string of the latest version fetched from the RStudio Package Manager, or `NULL` if not available.
#'
#' @examples
#' \dontrun{
#' # Define the input table
#' table <- list(
#'   list(
#'     package_name = "here",
#'     package_version = "0.1",
#'     link = "here_0.1.tar.gz",
#'     date = "2017-05-28 08:13",
#'     size = "3.5K"
#'   ),
#'   list(
#'     package_name = "here",
#'     package_version = "1.0.0",
#'     link = "here_1.0.0.tar.gz",
#'     date = "2020-11-15 18:10",
#'     size = "32K"
#'   )
#' )
#'
#' # Use the get_versions function
#' result <- get_versions(table, "here")
#'
#' # Example output
#' print(result)
#' }
#' @importFrom curl curl_fetch_memory
#' @importFrom jsonlite fromJSON
#' @export
get_versions <- function(table, package_name) {
  
  # Extract all versions from the table
  all_versions <- lapply(table, function(item) {
    if (!is.null(item$package_version)) item$package_version else NULL
  })
  
  # Convert all_versions to a character vector
  all_versions <- unlist(all_versions, use.names = FALSE)
  
  # Fetch the latest version from RStudio Package Manager
  url_latest_version <- paste0("https://packagemanager.posit.co/__api__/repos/1/packages/", package_name)
  response <- curl::curl_fetch_memory(url_latest_version)
  
  if (response$status_code == 200) {
    data <- fromJSON(rawToChar(response$content))
    last_version <- data$version
    
    if (!is.null(last_version)) {
      all_versions <- unique(c(all_versions, last_version))
    }
  } else {
    last_version <- NULL
  }
  
  # If table is NULL, return only the last version
  if (is.null(table)) {
    return(list(
      all_versions = if (!is.null(last_version)) last_version else NULL,
      last_version = last_version
    ))
  }
  
  # Return all versions and the last version
  return(list(
    all_versions = all_versions,
    last_version = last_version
  ))
}



#' Check and Fetch CRAN Package
#'
#' This function checks if a package exists on CRAN and retrieves the corresponding package URL and version details.
#' If a specific version is not provided, the latest version is used.
#'
#' @param package_name A character string specifying the name of the package to check and fetch.
#' @param package_version An optional character string specifying the version of the package to fetch. Defaults to `NULL`.
#'
#' @return A list containing:
#'   - `package_url`: URL to download the package tarball.
#'   - `last_version`: Latest version available
#'   - `version`: The requested version of the package (or `NULL` if not specified).
#'   - `all_versions`: A character vector of all available package versions
#'   - `error`: If the package or version is not found, an error message is included.
#'
#' @examples
#' \dontrun{
#' # Check and fetch a specific version of "ggplot2"
#' result <- check_and_fetch_cran_package("ggplot2", package_version = "3.3.5")
#' print(result)
#'}
#' @importFrom curl curl_fetch_memory
#' @importFrom jsonlite fromJSON
#' @export
check_and_fetch_cran_package <- function(package_name, package_version = NULL) {
  
  # Check if the package exists on CRAN
  if (!check_cran_package(package_name)) {
    return(list(
      package_url = NULL,
      last_version = NULL,
      version = NULL,
      all_versions = NULL
    ))
  }
  
  # Fetch CRAN package URL and versions
  html <- parse_package_info(package_name)
  
  if (!is.null(html)) {
    table <- parse_html_version(html, package_name)
    versions <- get_versions(table, package_name)  
  } else {
    table <- NULL
    versions <- get_versions(table, package_name)  
  }
  
  # Get the CRAN package URL
  url <- get_cran_package_url(package_name, package_version, versions$last_version, versions$all_versions)
  
  # If version not found in CRAN
  if (is.null(url) && !(package_version %in% versions$all_versions)) {
    return(list(
      error = paste("Version", package_version, "for", package_name, "not found"),
      version_available = paste(versions$all_versions, collapse = ", ")
    ))
  }
  
  # Return package URL and version details
  return(list(
    package_url = url,
    last_version = versions$last_version,
    version = package_version,
    all_versions = versions$all_versions
  ))
}

#' Get CRAN Package URL
#'
#' This function constructs the CRAN package URL for a specified package and version.
#'
#' @param package_name A character string specifying the name of the package.
#' @param version An optional character string specifying the version of the package.
#' @param last_version A character string specifying the latest available version of the package.
#' @param all_versions A character vector of all available versions of the package.
#'
#' @return A character string containing the URL to download the package tarball, or `NULL`
#' if the version is not found in the list of available versions.
#'
#' @examples
#' \donttest{
#' url_result <- get_cran_package_url("dplyr", NULL, "1.0.10", c("1.0.0", "1.0.10"))
#' }
#' @export
get_cran_package_url <- function(package_name, version, last_version, all_versions) {
  # Set version to the latest version if not provided
  if (is.null(version)) {
    version <- last_version
  }
  
  # Check if the version exists in the list of all_versions
  if (version %in% all_versions) {
    # If the version is the latest version
    if (version == last_version) {
      return(paste0("https://cran.r-project.org/src/contrib/", package_name, "_", version, ".tar.gz"))
    }
    
    # If the version is not the latest, construct the archive URL
    return(paste0("https://cran.r-project.org/src/contrib/Archive/", package_name, "/", package_name, "_", version, ".tar.gz"))
  }
  
  # Return NULL if no valid URL is found
  return("No valid URL found")
}



#' Extract and Validate Package Hosting Information
#' 
#' This function retrieves hosting links for an R package from various sources such as GitHub, CRAN, internal repositories, or Bioconductor.
#' 
#' @param pkg_name Character. The name of the package.
#' @param pkg_version Character. The version of the package.
#' @param pkg_source_path Character. The file path to the package source directory containing the DESCRIPTION file.
#' 
#' @return A list containing the following elements:
#' 
#' - `github_links`: GitHub links related to the package.
#' - `cran_links`: CRAN links
#' - `internal_links`: internal repository links.
#' - `bioconductor_links`: Bioconductor links 
#' 
#' If links are found, return empty or NULL.
#' 
#' @details
#' The function extracts hosting links by:
#' 1. Parsing the `DESCRIPTION` file for GitHub and BugReports URLs.
#' 2. Checking if the package is valid on CRAN and others host repository
#' 
#' If no links are found in the `DESCRIPTION` file, returns `NULL`
#' 
#' @keywords internal
get_host_package <- function(pkg_name, pkg_version, pkg_source_path) {
  
  message(glue::glue("Checking host package"))
  
  # Path to the DESCRIPTION file
  pkg_desc_path <- file.path(pkg_source_path, "DESCRIPTION")
  
  # Load the DESCRIPTION file
  d <- description$new(file = pkg_desc_path)
  description_text <- d$str()
  
  # Extract URLs from $get_urls() and $get_list("BugReports")
  urls <- d$get_urls()
  
  if (d$has_fields("BugReports")) {
    bug_reports <- d$get_list("BugReports")
  } else {
    bug_reports <- NULL  # Set to NULL or empty vector if the field is missing
  }  
  
  all_links <- c(urls, bug_reports)
  github_pattern <- "https://github.com/([^/]+)/([^/]+).*"
  matching_links <- grep(github_pattern, all_links, value = TRUE)
  owner_names <- sub(github_pattern, "\\1", matching_links)
  package_names_github <- sub(github_pattern, "\\2", matching_links)
  
  valid <- which(owner_names != "" & package_names_github != "")
  
  if (length(valid) > 0) {
    github_links <- unique(paste0("https://github.com/", owner_names[valid], "/", package_names_github[valid]))
  } else {
    github_links <- "No GitHub link found"
  }
  
  is_package_valid <- check_cran_package(pkg_name)
  
  if (is_package_valid) {
    # Fetch the archive content
    archive_html <- parse_package_info(pkg_name)
    parsed_versions <- parse_html_version(archive_html, pkg_name)
    result_cran <- check_and_fetch_cran_package(pkg_name, pkg_version)  
    # get CRAN links
    cran_links <- get_cran_package_url(pkg_name, pkg_version, result_cran$last_version, result_cran$all_versions)
    
  } else {
    cran_links <- "No CRAN link found"
    
  }
  
  # get internal package link
  result_internal <- get_internal_package_url(pkg_name, pkg_version)
  internal_links <- result_internal$url
  
  bioconductor_links <-  "No Bioconductor link found"
  
  # Define the Bioconductor pattern
  bioconductor_pattern <- paste0("https://(git\\.)?bioconductor\\.org/packages/", pkg_name, "/?(?=[\\s,]|$)")
  
  # Find the first match in the text for Bioconductor
  bioconductor_match <- regexpr(bioconductor_pattern, description_text, perl = TRUE)
  
  if (bioconductor_match != -1) {
    bioconductor_links <- regmatches(description_text, bioconductor_match)
  }
  
  result <- list(
    github_links = github_links,
    cran_links = cran_links,
    internal_links = internal_links,
    bioconductor_links = bioconductor_links
  )
  
  return(result)
}

