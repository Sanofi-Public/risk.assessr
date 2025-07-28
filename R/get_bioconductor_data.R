#' Fetch Bioconductor Release Announcements
#' 
#' This function retrieves the Bioconductor release announcements page and returns
#' its HTML content for further processing.
#' 
#' @return An XML document from bioconductor version page.
#' 
#' @importFrom curl curl_fetch_memory
#' @importFrom xml2 read_html
#' 
#' @examples
#' \dontrun{
#' html_content <- fetch_bioconductor_releases()
#' }
#' @export
fetch_bioconductor_releases <- function() {
  url <- "https://bioconductor.org/about/release-announcements/"
  
  # Perform GET request
  response <- curl::curl_fetch_memory(url)
  
  # If status code is not 200, return FALSE
  if (response$status_code != 200) {
    return(FALSE)
  }
  
  html_content <- xml2::read_html(rawToChar(response$content))
  return(html_content)
}

#' Parse Bioconductor Release Announcements
#' 
#' This function extracts Bioconductor release details such as version number,
#' release date, number of software packages, and required R version from the 
#' release announcements HTML page.
#' 
#' @param html_content The parsed HTML document from `fetch_bioconductor_releases`.
#' 
#' @return A list of lists containing Bioconductor release details: release version, date,
#'         number of software packages, and corresponding R version.
#' 
#' @importFrom xml2 xml_find_first xml_find_all xml_text
#' @importFrom stringr str_trim
#' 
#' @examples
#' \dontrun{
#' html_content <- fetch_bioconductor_releases()
#' release_data <- parse_bioconductor_releases(html_content)
#' 
#' }
#' @export
parse_bioconductor_releases <- function(html_content) {
  data <- list()
  
  table <- xml2::xml_find_first(html_content, "//table")
  rows <- xml2::xml_find_all(table, ".//tr")[-1]  # Skip the header row
  
  for (row in rows) {
    cols <- xml2::xml_find_all(row, ".//td")
    
    if (length(cols) == 4) {
      release <- xml2::xml_text(cols[1])
      date <- xml2::xml_text(cols[2])
      software_packages <- xml2::xml_text(cols[3])
      r_version <- xml2::xml_text(cols[4])
      
      data <- append(data, list(list(
        release = stringr::str_trim(release),
        date = stringr::str_trim(date),
        software_packages = stringr::str_trim(software_packages),
        r_version = stringr::str_trim(r_version)
      )))
    }
  }
  return(data)
}

#' Parse HTML Content for Package Versions
#' 
#' This function extracts version information from an HTML page listing
#' available versions of a Bioconductor package.
#' 
#' @param html_content A character string containing the HTML content.
#' @param package_name A character string specifying the name of the package.
#' 
#' @return A list of lists containing package details such as package name, version, link,
#'         date, and size. Returns an empty list if no versions are found.
#' 
#' @importFrom xml2 read_html xml_find_all xml_find_first xml_text xml_attr
#' @importFrom stringr str_trim
#' 
#' @examples
#' \dontrun{
#' parse_html_version(html_content, "GenomicRanges")
#' }
#' @export
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

#' Extract Package Version from File Path
#' 
#' This function extracts the version number from a package source file name
#' based on the package name and expected file pattern.
#' 
#' @param path A character string specifying the file path or URL.
#' @param package_name A character string specifying the name of the package.
#' 
#' @return A character string representing the extracted version number, or `NULL` if no match is found.
#' 
#' @examples
#' \dontrun{
#' link <- "https://bioconductor.org/packages/3.14/bioc/src/contrib/GenomicRanges_1.42.0.tar.gz"
#' extract_version(link, "GenomicRanges")
#' }
#' @export 
extract_version <- function(path, package_name) {
  pattern <- paste0(package_name, "_([0-9\\.]+)\\.tar\\.gz$")
  match <- regexpr(pattern, path, perl = TRUE)
  
  if (match == -1) {
    return(NULL) # No match found
  }
  
  version <- regmatches(path, regexec(pattern, path))[[1]][2]
  return(version)
}

#' Fetch Bioconductor Package Information
#' 
#' This function retrieves information about a specific Bioconductor package
#' for a given Bioconductor version. It fetches the package details, such as
#' version, source package URL, and archived versions if available.
#' 
#' @param bioconductor_version A character string specifying the Bioconductor version (e.g., "3.14").
#' @param package_name A character string specifying the name of the package.
#' 
#' @return A list containing package details, including the latest version, package URL,
#'         source package link, and any archived versions if available.
#'         Returns `FALSE` if the package does not exist or cannot be retrieved.
#' 
#' @importFrom curl curl_fetch_memory
#' @importFrom xml2 read_html xml_find_all xml_find_first xml_text xml_attr
#' 
#' @examples
#' \dontrun{
#' fetch_bioconductor_package_info("3.14", "GenomicRanges")
#' 
#' }
#' @export
fetch_bioconductor_package_info <- function(bioconductor_version, package_name) {
  
  repo_list <- list()
  url_page <- paste0("https://bioconductor.org/packages/", bioconductor_version, "/bioc/html/", package_name, ".html")
  
  # Perform GET request with proper error handling
  response <- tryCatch({
    curl::curl_fetch_memory(url_page)  # Remove handle argument
  }, error = function(e) {
    message(paste("Error fetching:", url_page, "->", e$message))
    return(NULL)
  })
  
  # If package does not exist, return FALSE
  if (is.null(response) || response$status_code != 200) {
    return(FALSE)
  }
  
  # Ensure content is not empty before parsing HTML
  if (is.null(response$content) || length(response$content) == 0) {
    stop("Response is NULL or empty for URL: ", url_page)
  }
  
  html_content <- tryCatch({
    read_html(rawToChar(response$content))
  }, error = function(e) {
    message("Failed to parse HTML content for: ", package_name)
    return(NULL)
  })
  
  if (is.null(html_content)) return(FALSE)  
  
  data_dict <- list()
  rows <- xml_find_all(html_content, "//tr")
  keys_to_keep <- c("version", "url", "source_package")
  
  for (row in rows) {
    cells <- xml_find_all(row, "td")
    if (length(cells) == 2) {
      key <- tolower(gsub(" ", "_", xml_text(cells[1])))
      
      if (key %in% keys_to_keep) {
        data_dict[[key]] <- trimws(xml_text(cells[2]))
      }
    }
  }
  
  # Ensure we have a proper version
  if (!"version" %in% names(data_dict)) {
    return(FALSE)
  }
  
  # Get latest version for the Bioconductor version
  data_dict$bioconductor_version <- bioconductor_version
  data_dict$url_package <- data_dict$url
  data_dict$archived <- FALSE
  
  # Extract source package from links on the page
  page <- tryCatch({
    read_html(url_page)
  }, error = function(e) {
    message("Failed to fetch page: ", url_page)
    return(NULL)
  })
  
  if (!is.null(page)) {
    links <- xml_find_all(page, "//a")
    hrefs <- xml_attr(links, "href")
    tar_gz_links <- hrefs[grepl("\\.tar\\.gz$", hrefs)]
    
    package_version <- extract_version(tar_gz_links, package_name)
    if (!is.null(package_version)) {
      source_package_main <- paste0("https://bioconductor.org/packages/", bioconductor_version, "/bioc/src/contrib/", package_name, "_", package_version, ".tar.gz")
      data_dict$source_package <- source_package_main
    } else {
      data_dict$source_package <- NA  # Ensure there's always a value
    }
  }
  
  # Get archived versions
  url_archive <- paste0("https://bioconductor.org/packages/", bioconductor_version, "/bioc/src/contrib/Archive/", package_name, "/")
  
  archive_page <- tryCatch({
    read_html(url_archive)
  }, error = function(e) {
    return(NULL)
  })
  
  repo_list <- append(repo_list, list(data_dict))
  
  if (!is.null(archive_page)) {
    links <- xml_find_all(archive_page, "//a")
    hrefs <- xml_attr(links, "href")
    archive_tar_gz_links <- hrefs[grepl("\\.tar\\.gz$", hrefs)]
    full_archive_links <- rev(paste0(url_archive, archive_tar_gz_links))
    
    for (link in full_archive_links) {
      version <- extract_version(link, package_name)
      repo <- list(
        version = version, 
        url = data_dict$url_package, 
        source_package = link, 
        archived = TRUE, 
        bioconductor_version = bioconductor_version
      )
      repo_list <- append(repo_list, list(repo))
    }
  }
  
  return(repo_list)
}

#' Retrieve Bioconductor Package URL
#' 
#' This function fetches the source package URL for a given Bioconductor package.
#' If no version is specified, it retrieves the latest available version.
#' Currently, this function is not able to fetch archived package version for a bioconductor version
#' 
#' @param package_name A character string specifying the name of the Bioconductor package.
#' @param package_version (Optional) A character string specifying the package version. Defaults to `NULL`, which retrieves the latest version.
#' @param release_data A list containing Bioconductor release information.
#' 
#' @return A list containing the following elements:
#'  \item{url}{The URL of the source package (if available).}
#'  \item{version}{The specified or latest available package version.}
#'  \item{last_version}{The last available version of the package.}
#'  \item{all_versions}{A vector of all discovered versions of the package.}
#'  \item{bioconductor_version_package}{The Bioconductor version associated with the package.}
#'  \item{archived}{A logical value indicating whether the package is archived.}
#' 
#' 
#' @examples
#' \dontrun{
#' release_data <- list(
#'   list(release = "3.12"),
#'   list(release = "3.13"),
#'   list(release = "3.14")
#' )
#' 
#' get_bioconductor_package_url("GenomicRanges", release_data = release_data)
#' 
#' 
#' 
#'}
#' @export
get_bioconductor_package_url <- function(package_name, package_version=NULL, release_data) {
  
  all_versions <- c()
  source_code <- NULL
  bioconductor_version_package <- NULL
  archived <- NULL
  last_version <- NULL
  
  for (version_info in release_data) {
    bioconductor_version <- version_info$release
    
    message(paste("Checking Bioconductor version:", bioconductor_version))
    
    # Get Bioconductor package info
    package_info <- tryCatch({
      fetch_bioconductor_package_info(bioconductor_version, package_name)
    }, error = function(e) {
      message(paste("Skipping Bioconductor version", bioconductor_version, "due to error:", e$message))
      return(NULL)
    }
    )
    
    if (is.null(package_info) || !is.list(package_info)) next 
    
    # Ensure package_info is treated as a list of packages
    if (!is.null(package_info$version)) {
      package_info <- list(package_info) 
    }
    
    for (pkg in package_info) {
      if (!is.list(pkg) || is.null(pkg$version)) next 
      
      pkg_version <- pkg$version
      message(paste("Checking package version:", pkg_version))
      
      if (!is.null(pkg_version) && !is.na(pkg_version)) {
        
        # Store last available version
        if (is.null(last_version)) {
          last_version <- pkg_version 
        }    
        
        all_versions <- unique(c(all_versions, pkg_version))
        
        if (is.null(package_version) || length(package_version) == 0 || is.na(package_version)) {
          package_version <- last_version
        }
        
        # Ensure both versions are neither NULL nor NA before comparison
        if (!is.null(pkg_version) && !is.null(package_version) && 
            !is.na(pkg_version) && !is.na(package_version) && pkg_version == package_version) {
          bioconductor_version_package <- pkg$bioconductor_version
          source_code <- pkg$source_package
          archived <- pkg$archived
        } 
      }
    }
  }
  
  if (is.null(source_code)) {
    warning("Package URL not found. Possible reasons: invalid package name, unavailable version, or incorrect Bioconductor version.")
  }
  
  return(list(
    url = source_code,
    version = package_version,
    last_version = last_version,
    all_versions = all_versions,
    bioconductor_version_package = bioconductor_version_package,
    archived = archived
  ))
}