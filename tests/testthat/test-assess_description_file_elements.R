test_that("test assess_description_file_elements for all elements present", {
# check source control
  test_source_control_elements <- function() {
  # Define toy data for testing
    toy_data <- list(
      no_source_control = list(
        pkg_name = "pkg_no_source_control",
        desc_elements = list(URL = "http://example.com"),
        expected_message = "pkg_no_source_control does not have a source control",
        expected_has_source_control = 0
      ),
      has_github = list(
        pkg_name = "pkg_has_github",
        desc_elements = list(URL = "https://github.com/user/repo"),
        expected_message = "pkg_has_github has a source control",
        expected_has_source_control = 1
      ),
      has_ac_uk = list(
        pkg_name = "pkg_has_ac_uk",
        desc_elements = list(URL = "http://www.stats.ox.ac.uk/pub/MASS4/"),
        expected_message = "pkg_has_ac_uk has a source control",
        expected_has_source_control = 1
      ),
      has_bitbucket = list(
        pkg_name = "pkg_has_bitbucket",
        desc_elements = list(URL = "https://bitbucket.org/user/repo"),
        expected_message = "pkg_has_bitbucket has a source control",
        expected_has_source_control = 1
      ),
      has_gitlab = list(
        pkg_name = "pkg_has_gitlab",
        desc_elements = list(URL = "https://gitlab.com/user/repo"),
        expected_message = "pkg_has_gitlab has a source control",
        expected_has_source_control = 1
      ),
      has_cambridge_repo = list(
        pkg_name = "pkg_has_cambridge_repo",
        desc_elements = list(URL = "https://www.repository.cam.ac.uk/items/da5b9b21-ef5f-4ac8-80e4-553d99014aaf/full"),
        expected_message = "pkg_has_cambridge_repo has a source control",
        expected_has_source_control = 1
      ),
      has_wehi = list(
        pkg_name = "pkg_has_wehi",
        desc_elements = list(URL = "http://bioinf.wehi.edu.au/limma"),
        expected_message = "pkg_has_wehi has a source control",
        expected_has_source_control = 1
      ),
      has_bioconductor = list(
        pkg_name = "pkg_has_bioconductor",
        desc_elements = list(URL = "https://bioconductor.org/packages/IRanges"),
        expected_message = "pkg_has_bioconductor has a source control",
        expected_has_source_control = 1
      )
    )
    
    # Define the patterns
    patterns <- "github\\.com|bitbucket\\.org|gitlab\\.com|\\.ac\\.uk|\\.edu\\.au|bioconductor\\.org"
  
  # Test each scenario
    for (test_case in toy_data) {
      pkg_name <- test_case$pkg_name
      desc_elements <- test_case$desc_elements
      expected_message <- test_case$expected_message
      expected_has_source_control <- test_case$expected_has_source_control
      
      expect_message({
        if (is.null(desc_elements$URL) | (is.na(desc_elements$URL))) {
          message(glue::glue("{pkg_name} does not have a source control"))
          has_source_control <- 0
        } else {
          source_matches <- grep(patterns, desc_elements$URL, value = TRUE)
          if (length(source_matches) == 0) {
            message(glue::glue("{pkg_name} does not have a source control"))
            has_source_control <- 0
          } else {
            message(glue::glue("{pkg_name} has a source control"))
            has_source_control <- 1
          }
        }
      }, expected_message)
      
      expect_equal(has_source_control, expected_has_source_control)
    }
  }  

  test_source_control_elements()  
})

test_that("test assess_description_file_elements for all elements present", {
  
  library(risk.assessr)
  # set CRAN repo 
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data", "stringr-1.5.1.tar.gz",
                    package = "risk.assessr")
  
  # set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  pkg_desc <- get_pkg_desc(pkg_source_path, fields = c("Package", "Version"))
  pkg_name <- pkg_desc$Package
  pkg_ver <- pkg_desc$Version
  pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
  
  testthat::expect_message(
    desc_elements_test <- assess_description_file_elements(pkg_name, pkg_source_path),
    glue::glue("{pkg_name} has bug reports URL"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- assess_description_file_elements(pkg_name, pkg_source_path),
    glue::glue("{pkg_name} has a source control"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- assess_description_file_elements(pkg_name, pkg_source_path),
    glue::glue("{pkg_name} has a license"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- assess_description_file_elements(pkg_name, pkg_source_path),
    glue::glue("{pkg_name} has a maintainer"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- assess_description_file_elements(pkg_name, pkg_source_path),
    glue::glue("{pkg_name} has a website"),
    fixed = TRUE
  )
  desc_elements_test <- assess_description_file_elements(pkg_name, pkg_source_path)
  expect_identical(length(desc_elements_test), 5L)
  expect_true(checkmate::check_list(desc_elements_test, all.missing = FALSE))
  expect_true(checkmate::check_list(desc_elements_test, any.missing = TRUE))
})

test_that("test assess_description_file_elements for all elements present", {
  
  library(risk.assessr)
  # set CRAN repo 
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data", "test.package.0007_0.1.0.tar.gz",
                    package = "risk.assessr")
  
  # set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  pkg_desc <- get_pkg_desc(pkg_source_path, fields = c("Package", "Version"))
  pkg_name <- pkg_desc$Package
  pkg_ver <- pkg_desc$Version
  pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
  
  testthat::expect_message(
    desc_elements_test <- assess_description_file_elements(pkg_name, pkg_source_path),
    glue::glue("{pkg_name} does not have bug reports URL"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- assess_description_file_elements(pkg_name, pkg_source_path),
    glue::glue("{pkg_name} does not have a source control"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- assess_description_file_elements(pkg_name, pkg_source_path),
    glue::glue("{pkg_name} does not have a license"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- assess_description_file_elements(pkg_name, pkg_source_path),
    glue::glue("{pkg_name} has a maintainer"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- assess_description_file_elements(pkg_name, pkg_source_path),
    glue::glue("{pkg_name} does not have a website"),
    fixed = TRUE
  )
  
  desc_elements_test <- assess_description_file_elements(pkg_name, pkg_source_path)
  expect_identical(length(desc_elements_test), 5L)
  expect_true(checkmate::check_list(desc_elements_test, all.missing = FALSE))
  expect_true(checkmate::check_list(desc_elements_test, any.missing = TRUE))
})

# Define the function to be tested
check_pkg_creator <- function(pkg_name, pkg_source_path, desc_elements) {
  check_pkg_creator <- get_pkg_creator_info(pkg_name, pkg_source_path)
  
  if (!check_pkg_creator) {
    message(glue::glue("{pkg_name} has a maintainer"))
    has_maintainer <- 1
  } else if (is.null(desc_elements$Maintainer) || 
             (is.na(desc_elements$Maintainer))) {
    message(glue::glue("{pkg_name} does not have a maintainer"))
    has_maintainer <- 0
  } else {
    message(glue::glue("{pkg_name} has a maintainer"))
    has_maintainer <- 1
  }
  return(has_maintainer)
}

# Mock get_pkg_creator_info function
mock_get_pkg_creator_info <- function(pkg_name, pkg_source_path) {
  return(FALSE)  # Simulate that the package has a creator
}

test_that("check_pkg_creator handles maintainers correctly", {
  pkg_name <- "testpkg"
  pkg_source_path <- "path/to/package"
  
  # Stub the get_pkg_creator_info function
  mockery::stub(check_pkg_creator, "get_pkg_creator_info", mock_get_pkg_creator_info)
  
  # Test case where there is a maintainer
  desc_elements <- list(Maintainer = "John Doe")
  has_maintainer <- check_pkg_creator(pkg_name, pkg_source_path, desc_elements)
  expect_equal(has_maintainer, 1)
  
  # Test case where there is no maintainer
  desc_elements <- list(Maintainer = NULL)
  has_maintainer <- check_pkg_creator(pkg_name, pkg_source_path, desc_elements)
  expect_equal(has_maintainer, 1)
  
  # Test case where maintainer is NA
  desc_elements <- list(Maintainer = NA)
  has_maintainer <- check_pkg_creator(pkg_name, pkg_source_path, desc_elements)
  expect_equal(has_maintainer, 1)
  
  # Test case where get_pkg_creator_info returns TRUE (no creator)
  mock_get_pkg_creator_info <- function(pkg_name, pkg_source_path) {
    return(TRUE)  # Simulate that the package does not have a creator
  }
  mockery::stub(check_pkg_creator, "get_pkg_creator_info", mock_get_pkg_creator_info)
  
  # Test case where there is a maintainer
  desc_elements <- list(Maintainer = "John Doe")
  has_maintainer <- check_pkg_creator(pkg_name, pkg_source_path, desc_elements)
  expect_equal(has_maintainer, 1)
})


# Mock get_pkg_creator_info function
mock_get_pkg_creator_info <- function(pkg_name, pkg_source_path) {
  return(TRUE)  # Simulate that the package does not have a creator
}

# Test function using mockery
test_that("check_pkg_creator handles missing maintainers correctly", {
  pkg_name <- "testpkg"
  pkg_source_path <- "path/to/package"
  
  # Stub the get_pkg_creator_info function
  mockery::stub(check_pkg_creator, "get_pkg_creator_info", mock_get_pkg_creator_info)
  
  # Test case where Maintainer is NULL
  desc_elements <- list(Maintainer = NULL)
  has_maintainer <- check_pkg_creator(pkg_name, pkg_source_path, desc_elements)
  expect_equal(has_maintainer, 0)
  
  # Test case where Maintainer is NA
  desc_elements <- list(Maintainer = NA)
  has_maintainer <- check_pkg_creator(pkg_name, pkg_source_path, desc_elements)
  expect_equal(has_maintainer, 0)
})



# Authors

test_that("get_pkg_author retrieves all authors correctly", {
  # Create a temporary directory to simulate the package folder
  temp_dir <- tempdir()
  pkg_source_path <- file.path(temp_dir, "limma")
  desc_path <- file.path(pkg_source_path, "DESCRIPTION")
  dir.create(pkg_source_path, recursive = TRUE, showWarnings = FALSE)
  
  # Provided DESCRIPTION text
  description_text <- "Package: here
Title: A Simpler Way to Find Your Files
Version: 1.0.1
Date: 2020-12-13
Authors@R: 
    c(person(given = 'Kirill',
             family = 'M\u00fcller',
             role = c('aut', 'cre'),
             email = 'krlmlr+r@mailbox.org',
             comment = c(ORCID = '0000-0002-1416-3412')),
      person(given = 'Jennifer',
             family = 'Bryan',
             role = 'ctb',
             email = 'jenny@rstudio.com',
             comment = c(ORCID = '0000-0002-6983-2759')))
Description: Constructs paths to your project's files.
    Declare the relative path of a file within your project with 'i_am()'.
    Use the 'here()' function as a drop-in replacement for 'file.path()',
    it will always locate the files relative to your project root.
License: MIT + file LICENSE
URL: https://here.r-lib.org/, https://github.com/r-lib/here
BugReports: https://github.com/r-lib/here/issues
Imports: rprojroot (>= 2.0.2)
Suggests: conflicted, covr, fs, knitr, palmerpenguins, plyr, readr,
        rlang, rmarkdown, testthat, uuid, withr
VignetteBuilder: knitr
Encoding: UTF-8
LazyData: true
RoxygenNote: 7.1.1.9000
Config/testthat/edition: 3
NeedsCompilation: no
Packaged: 2020-12-13 06:59:33 UTC; kirill
Author: Kirill Müller [aut, cre] (<https://orcid.org/0000-0002-1416-3412>),
  Jennifer Bryan [ctb] (<https://orcid.org/0000-0002-6983-2759>)
Maintainer: Kirill Müller <krlmlr+r@mailbox.org>
Repository: CRAN
Date/Publication: 2020-12-13 07:30:02 UTC
"
  
  # Write the DESCRIPTION text to a file
  writeLines(description_text, desc_path)
  
  # Run the function with the mocked package path
  result <- get_pkg_author("limma", pkg_source_path)
  
  # Assertions
  expect_type(result, "list")
  expect_true(!is.null(result$maintainer))
  expect_true(!is.null(result$authors))
  expect_equal(result$maintainer[[1]]$given, "Kirill")
  expect_equal(result$maintainer[[1]]$family, "Müller")
  
  # Clean up the temporary directory
  unlink(pkg_source_path, recursive = TRUE)
})





test_that("get_pkg_author retrieves all authors correctly without @Author", {
  # Create a temporary directory to simulate the package folder
  temp_dir <- tempdir()
  pkg_source_path <- file.path(temp_dir, "limma")
  desc_path <- file.path(pkg_source_path, "DESCRIPTION")
  dir.create(pkg_source_path, recursive = TRUE, showWarnings = FALSE)
  
  # Provided DESCRIPTION text
  description_text <- "Package: limma
Version: 2.10.7
Date: 2007/09/24
Title: Linear Models for Microarray Data
Author: Gordon Smyth with contributions from Matthew Ritchie, Jeremy Silver, James Wettenhall, Natalie Thorne, Mette Langaas, Egil Ferkingstad, Marcus Davy, Francois Pepin and Dongseok Choi.
Maintainer: Gordon Smyth <smyth@wehi.edu.au>
Depends: R (<= 2.5.1), methods
Suggests: affy, marray, MASS, splines, sma, statmod (>= 1.2.2), vsn
LazyLoad: yes
Description:  Data analysis, linear models and differential expression for microarray data.
License: LGPL
URL: http://bioinf.wehi.edu.au/limma
biocViews: Microarray, OneChannel, TwoChannel, DataImport, QualityControl, Preprocessing, Statistics, DifferentialExpression, MultipleComparisons, TimeCourse
Packaged: Mon Sep 24 13:01:39 2007; smyth
"
  
  # Write the DESCRIPTION text to a file
  writeLines(description_text, desc_path)
  
  # Run the function with the mocked package path
  result <- get_pkg_author("limma", pkg_source_path)
  
  # Assertions
  expect_type(result, "list")
  expect_true(!is.null(result$maintainer))
  expect_true(!is.null(result$authors))
  expect_equal(result$maintainer[[1]]$given, "Gordon")
  expect_equal(result$maintainer[[1]]$family, "Smyth")
  
  # Clean up the temporary directory
  unlink(pkg_source_path, recursive = TRUE)
})










