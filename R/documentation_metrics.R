#' Assess Rd files for example or examples
#'
#' @param pkg_name - name of the package 
#' @param pkg_source_path - source path for install local
#'
#' @return has_examples - variable with score
#' @export
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
#' 
#' @export
#'
assess_exports <- function(data) {
  
  exports <- pkgload::parse_ns_file(data)$exports
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
#' @export
#'
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

#' assess_description_file_elements
#'
#' @param pkg_name - name of the package 
#' @param pkg_source_path - pkg_source_path - source path for install local
#'
#' @return - list - list with scores for description file elements
#' @export
#'
assess_description_file_elements <- function(pkg_name, pkg_source_path) {
  
  desc_elements <- risk.assessr::get_pkg_desc(pkg_source_path, 
                                                    fields = c(
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
  
  if (is.null(desc_elements$Maintainer) | (is.na(desc_elements$Maintainer))) {
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
    patterns <- "github\\.com|bitbucket\\.org|gitlab\\.com"
    matches <- grep(patterns, desc_elements$URL, value = TRUE)
    if (length(matches) == 0) {
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
#' @export
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
#' @export
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
#' @export
#'
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
#' @export
#'
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
#'  
#' @export
#'
doc_riskmetric <- function(pkg_name, pkg_ver, pkg_source_path) {
  
  
  export_help <- 
    risk.assessr::assess_export_help(pkg_name, 
                                           pkg_source_path)
  
  desc_elements <- 
    risk.assessr::assess_description_file_elements(pkg_name, 
                                                         pkg_source_path)
  
  if (fs::dir_exists(fs::path(pkg_source_path, "R"))) {
    size_codebase <- 
      risk.assessr::assess_size_codebase(pkg_source_path)
  } else {
    size_codebase <- 0
    message(glue::glue("{pkg_name} has no R folder to assess codebase size"))
  }
  has_vignettes <- 
    risk.assessr::assess_vignettes(pkg_name, 
                                           pkg_source_path)
  
  has_examples <- 
    risk.assessr::assess_examples(pkg_name, 
                                         pkg_source_path)
  
  has_news <- 
    risk.assessr::assess_news(pkg_name, 
                                        pkg_source_path)
  
  news_current <- 
    risk.assessr::assess_news_current(pkg_name,
                                            pkg_ver,
                                            pkg_source_path)
  
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