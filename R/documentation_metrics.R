#' Assess Rd files for example or examples
#'
#' @param pkg_name - name of the package 
#' @param pkg_source_path - source path for install local
#'
#' @return has_examples - variable with score
#' @keywords internal
assess_examples <- function(pkg_name, pkg_source_path) {
  
  # get all information on Rd objects
  db <- tools::Rd_db(dir = pkg_source_path)
  
  # omit whole package rd
  db <- db[!names(db) %in% c(paste0(pkg_name, "-package.Rd"), paste0(pkg_name,".Rd"))]
  
  extract_section <- function(rd, section) {
    lines <- unlist(strsplit(as.character(rd), "\n"))
    start <- grep(paste0("^\\\\", section), lines)
    if (length(start) == 0) return(NULL)
    end <- grep("^\\\\", lines[-(1:start)], fixed = TRUE)
    end <- if (length(end) == 0) length(lines) else start + end[1] - 2
    paste(lines[(start + 1):end], collapse = "\n")
  }
  # check Rd objects for example examples usage
  examples <- lapply(db, extract_section, section = "examples")
  example <- lapply(db, extract_section, section = "example")
  
  # filter out NULL values
  examples <- Filter(Negate(is.null), examples)
  example <- Filter(Negate(is.null), example)
  
  if (length(examples) > 0 | length(example) > 0) {
    message(glue::glue("{pkg_name} has examples"))
    has_examples <- 1
  } else {
    message(glue::glue("{pkg_name} has no examples"))
    has_examples <- 0
  }
 return(has_examples)
}


#' Assess exported functions to namespace
#'
#' @param data pkg source path
#' @keywords internal
assess_exports <- function(data) {
  
  exports <- parseNamespaceFile(basename(data), dirname(data), mustExist = FALSE)$exports
  
  if (length(exports) > 0) {
    export_calc <- 1 - 1 / (1 + exp(-0.25 * (sqrt(length(exports)) - sqrt(25))))
  } else {
    export_calc <- 0
  }
}  

#' assess_export_help
#'
#' @param pkg_name - name of the package 
#' @param pkg_source_path - pkg_source_path - source path for install local
#'
#' @return - export_help - variable with score
#' @keywords internal
assess_export_help <- function(pkg_name, pkg_source_path) {
  
  exported_functions <- getNamespaceExports(pkg_name)
  if (length(exported_functions) > 0) {
    db <- tools::Rd_db(pkg_name, pkg_source_path)
    missing_docs <- setdiff(exported_functions, gsub("\\.Rd$", "", names(db)))
    if (length(missing_docs) == 0) {
      message(glue::glue("All exported functions have corresponding help files in {pkg_name}"))
      export_help <- 1
    } else {
      message(glue::glue("Some exported functions are missing help files in {pkg_name}"))
      # message(glue::glue("The following exported functions are missing help files in {pkg_name}"))
      # print(missing_docs) comment out - reactivate if needed
      export_help <- 0
    }
  } else {
    message(glue::glue("No exported functions in {pkg_name}"))
    export_help <- 0
  }
  return(export_help)
}

#' check for package creator
#'
#' @param pkg_name - package name
#' @param pkg_source_path - path to package
#'
#' @return - logical - package creator exists - `FALSE` 
#' @keywords internal
get_pkg_creator_info <- function(pkg_name, pkg_source_path) {
  
  message(glue::glue("Checking for creator in {pkg_name}"))
  
  # create path to DESCRIPTION file
  pkg_desc_path <- file.path(pkg_source_path, "DESCRIPTION")
  
  # check for package creator
  pkg_creator <- desc::desc_get_author(role = "cre", 
                                       file = pkg_desc_path)
  
  # Check if all elements are empty
  check_pkg_creator <- all(sapply(pkg_creator, function(x) length(x) == 0))
  
  return(check_pkg_creator)
}

#' assess_description_file_elements
#'
#' @param pkg_name - name of the package 
#' @param pkg_source_path - pkg_source_path - source path for install local
#'
#' @return - list - list with scores for description file elements
#' @keywords internal
assess_description_file_elements <- function(pkg_name, pkg_source_path) {
  
  desc_elements <- get_pkg_desc(pkg_source_path, fields = c(
                                                            "Package", 
                                                            "BugReports",
                                                            "License",
                                                            "Maintainer",
                                                            "URL"
                                                            ))
  
  if (is.null(desc_elements$BugReports) | (is.na(desc_elements$BugReports))) {
    message(glue::glue("{pkg_name} does not have bug reports URL"))
    has_bug_reports_url <- 0
  } else {
    message(glue::glue("{pkg_name} has bug reports URL"))
    has_bug_reports_url <- 1
  }
  
  if (is.null(desc_elements$License) | (is.na(desc_elements$License))) {
    message(glue::glue("{pkg_name} does not have a license"))
    license <- 0
  } else {
    message(glue::glue("{pkg_name} has a license"))
    license <- 1
  }
  
  check_pkg_creator <- get_pkg_creator_info(pkg_name, pkg_source_path)
  
  if (!check_pkg_creator) {
    message(glue::glue("{pkg_name} has a maintainer"))
    has_maintainer <- 1
  } else if (is.null(desc_elements$Maintainer) || 
      (is.na(desc_elements$Maintainer)))  {
    message(glue::glue("{pkg_name} does not have a maintainer"))
    has_maintainer <- 0
  } else {
    message(glue::glue("{pkg_name} has a maintainer"))
    has_maintainer <- 1
  }
  
  if (is.null(desc_elements$URL) | (is.na(desc_elements$URL))) {
    message(glue::glue("{pkg_name} does not have a website"))
    has_website <- 0
  } else {
    message(glue::glue("{pkg_name} has a website"))
    has_website <- 1
  }
  
  if (is.null(desc_elements$URL) | (is.na(desc_elements$URL))) {
    message(glue::glue("{pkg_name} does not have a source control"))
    has_source_control <- 0
  } else {
    patterns <- "github\\.com|bitbucket\\.org|gitlab\\.com|\\.ac\\.uk|\\.edu\\.au|bioconductor\\.org"
    url_matches <- grep(patterns, desc_elements$URL, value = TRUE)
    if (length(url_matches) == 0) {
      message(glue::glue("{pkg_name} does not have a source control"))
      has_source_control <- 0
    } else {
      message(glue::glue("{pkg_name} has a source control"))
      has_source_control <- 1
    }
  }
  
  desc_elements_scores <- list(
    has_bug_reports_url = has_bug_reports_url,
    license = license,
    has_maintainer = has_maintainer,
    has_website = has_website,
    has_source_control = has_source_control
  )
  
  return(desc_elements_scores)
}

#' Assess Rd files for news
#'
#' @param pkg_name - name of the package 
#' @param pkg_source_path - source path for install local
#'
#' @return has_news - variable with score
#' @keywords internal
assess_news <- function(pkg_name, pkg_source_path) {
  
  news <- list.files(pkg_source_path, 
                     pattern = "^NEWS\\.", 
                     full.names = TRUE)
  
  if (length(news) > 0) {
    message(glue::glue("{pkg_name} has news"))
    has_news <- 1
  } else {
    message(glue::glue("{pkg_name} has no news"))
    has_news <- 0
  }
  return(has_news)
}

#' Assess Rd files for news
#'
#' @param pkg_name - name of the package
#' @param pkg_ver - package version 
#' @param pkg_source_path - source path for install local
#'
#' @return news_current - variable with score
#' @keywords internal
assess_news_current <- function(pkg_name, pkg_ver, pkg_source_path) {
  
  # get NEWS.md filepath
  news_path <- file.path(pkg_source_path, "NEWS.md")
  
  # check news for latest package version
  if (file.exists(news_path)) {
    news_content <- readLines(news_path)
    version_pattern <- paste0("^# ",
                              pkg_name,
                              " ",
                              pkg_ver)
    version_lines <- grep(version_pattern, 
                          news_content, 
                          value = TRUE)
  } else {
    message(glue::glue("{pkg_name} has no news path"))
    version_lines <- character(0)
  }
  
  if (length(version_lines) == 0) {
    message(glue::glue("{pkg_name} has no current news"))
    news_current <- 0
  } else {
    message(glue::glue("{pkg_name} has current news"))
    news_current <- 1
  }
  return(news_current)
}


#' assess codebase size
#'
#' @description Scores packages based on its codebase size, 
#' as determined by number of lines of code.
#'
#' @param pkg_source_path - source path for install local 
#'
#' @return - size_codebase - numeric value between \code{0} (for small codebase) and \code{1} (for large codebase)
#' @keywords internal
assess_size_codebase <- function(pkg_source_path) {
  
    # create character vector of function files
    files <- list.files(path = file.path(pkg_source_path, "R"), full.names = T)
    
    # define the function for counting code base
    count_lines <- function(x){
      # read the lines of code into a character vector
      code_base <- readLines(x)
      
      # count all the lines
      n_tot <- length(code_base)
      
      # count lines for roxygen headers starting with #
      n_head <- length(grep("^#+", code_base))
      
      # count the comment lines with leading spaces
      n_comment <- length(grep("^\\s+#+", code_base))
      
      # count the line breaks or only white space lines
      n_break <- length(grep("^\\s*$", code_base))
      
      # compute the line of code base
      n_tot - (n_head + n_comment + n_break)
    }
    
    # count number of lines for all functions
    nloc <- sapply(files, count_lines)
    
    # sum the number of lines
    nloc_total <- sum(nloc)
  
    # calculate size of the code base
    size_codebase <- 1 - (1.5 / (nloc_total / 1e2 + 1.5))
    
    return(size_codebase)
}

#' Assess vignettes
#'
#' @param pkg_name - name of the package 
#' @param pkg_source_path - source path for install local 
#' 
#' @return - has_vignettes - variable with score
#' @keywords internal
assess_vignettes <- function(pkg_name, pkg_source_path) {
  
  folder <- c(source = "/vignettes", bundle = "/inst/doc", binary = "/doc")
  files <- unlist(lapply(paste0(pkg_source_path, folder), list.files, full.names = TRUE))
  
  file_path = unique(tools::file_path_sans_ext(files))
  filename = basename(file_path)
  names(file_path) <- filename
  
  if (length(filename) == 0) {
    message(glue::glue("{pkg_name} has no vignettes"))
    has_vignettes <- 0
  } else {
    message(glue::glue("{pkg_name} has vignettes"))
    has_vignettes <- 1
  }
  
  return(has_vignettes)
}

#' Run all relevant documentation riskmetric checks
#'
#' @param pkg_name name of the package
#' @param pkg_ver version of the package
#' @param pkg_source_path path to package source code (untarred)
#'
#' @returns raw riskmetric outputs
#'@keywords internal
doc_riskmetric <- function(pkg_name, pkg_ver, pkg_source_path) {
  
  
  export_help <- assess_export_help(pkg_name, pkg_source_path)
  desc_elements <- assess_description_file_elements(pkg_name, pkg_source_path)
  
  if (fs::dir_exists(fs::path(pkg_source_path, "R"))) {
    size_codebase <- assess_size_codebase(pkg_source_path)
  } else {
    size_codebase <- 0
    message(glue::glue("{pkg_name} has no R folder to assess codebase size"))
  }
  has_vignettes <- assess_vignettes(pkg_name, pkg_source_path)
  has_examples <- assess_examples(pkg_name, pkg_source_path)
  has_news <- assess_news(pkg_name, pkg_source_path)
  news_current <- assess_news_current(pkg_name, pkg_ver, pkg_source_path)
  
  doc_scores <- list(
    export_help = export_help,
    has_bug_reports_url = desc_elements$has_bug_reports_url,
    has_source_control = desc_elements$has_source_control,
    license = desc_elements$license,
    has_maintainer = desc_elements$has_maintainer,
    has_website = desc_elements$has_website,
    size_codebase = size_codebase,
    has_vignettes = has_vignettes,
    has_examples = has_examples,
    has_news = has_news,
    news_current = news_current
  )
  
  return(doc_scores)
}


#' Assess Authors
#'
#' @param pkg_name - name of the package 
#' @param pkg_source_path - source path for install local 
#' 
#' @return - Authors related variable
#' @importFrom desc description desc_coerce_authors_at_r
#' @keywords internal
get_pkg_author <- function(pkg_name, pkg_source_path) {
  message(glue::glue("Checking for author in {pkg_name}"))
  
  # Path to the DESCRIPTION file
  pkg_desc_path <- file.path(pkg_source_path, "DESCRIPTION")
  
  # Load the DESCRIPTION file
  d <- description$new(file = pkg_desc_path)
  
  # Check if Authors@R exists, and if not, convert from Author and Maintainer
  if (!d$has_fields("Authors@R")) {
    if (d$has_fields("Author") || d$has_fields("Maintainer")) {
      desc_coerce_authors_at_r(file = pkg_desc_path)
    }
  }
  
    # check for package creator
    pkg_creator <- desc::desc_get_author(role = "cre",
                                         file = pkg_desc_path)
    
    if (length(pkg_creator) == 0) pkg_creator <-  "No package maintainer found"

    # check for package funder
    pkg_fnd <- desc::desc_get_author(role = "fnd",
                                     file = pkg_desc_path)
    if (length(pkg_fnd) == 0) pkg_fnd <- "No package foundation found"

    # check for package authors
    pkg_author <- desc::desc_get_authors(file = pkg_desc_path)
    if (length(pkg_author) == 0) pkg_author <- "No package author found"

    # Combine all elements into a list for return
    result <- list(
      maintainer = pkg_creator,
      funder = pkg_fnd,
      authors = pkg_author
    )

    return(result)
}

#' Assess License
#'
#' @param pkg_name - name of the package 
#' @param pkg_source_path - source path for install local 
#' 
#' @return - Authors related variable
#' @importFrom desc description 
#' @keywords internal
get_pkg_license <- function(pkg_name, pkg_source_path) {
  message(glue::glue("Checking for License in {pkg_name}"))
  
  # Path to the DESCRIPTION file
  pkg_desc_path <- file.path(pkg_source_path, "DESCRIPTION")
  # Load the DESCRIPTION file
  d <- description$new(file = pkg_desc_path)
  
  if (d$has_fields("License")) {
    License <- d$get_list("License")
  } else {
    License <- "No package license found"
  }  

  return(License)
}







