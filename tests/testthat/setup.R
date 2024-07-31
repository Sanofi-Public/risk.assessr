# library
library(withr)

# test weights

sanofi_weights_numeric <- c(
  has_bug_reports_url = .2
) 

sanofi_weights_numeric_prob <- c(
  has_bug_reports_url = -.2
)

sanofi_weights_non_numeric <- c(
  has_bug_reports_url = ".2"
)  

# risk metrics for package 1
risk_results_1 <- list(
  pkg_name = "synapser",
  pkg_version = "0.2.1",
  pkg_source_path = "/tmp/RtmpNpDlUz/temp_file_1fe56774aacc/synapser",
  has_bug_reports_url = 1, 
  has_examples = 1,
  has_maintainer = 1,
  size_codebase = 0.06702413,
  has_news = 0,
  has_source_control = 0,
  has_vignettes = 1,
  has_website = 1,
  news_current = 0,
  export_help = 1,
  export_calc = 0.586281,
  check = .7,
  covr = .1084,
  dep_score = .9706878,
  revdep_score = .1260338
)

# create test data for testing update_pscore_results
update_risk_results <- list(
  pkg_name = "synapser",
  pkg_version = "0.2.1",
  pkg_source_path = "/tmp/RtmpNpDlUz/temp_file_1fe56774aacc/synapser",
  has_bug_reports_url = "", 
  has_examples = "",
  has_maintainer = "",
  size_codebase = "",
  has_news = "",
  has_source_control = "",
  has_vignettes = "",
  has_website = "",
  news_current = "",
  export_help = "",
  export_calc = "",
  check = "",
  covr = "",
  dep_score = "",
  revdep_score = ""
)

# create test data for testing update_pscore_results
update_pscore <- list(
  export_help = 1,
  has_bug_reports_url = NA,
  size_codebase = .532,
  has_maintainer = 1,
  has_examples = 1,
  has_news = 1,
  has_source_control = 1,
  has_vignettes = 1,
  has_website = 1,
  has_license = NA,
  news_current = 1
)

#create data for testing create_empty_results
sys <- list(
  sysname = "Linux",
  version = "#1 SMP Tue Aug 18 14:50:17 EDT 2020",
  release = "3.10.0-1160.el7.x86_64",
  machine = "x86_64"
)

info <- list(
  sys = sys
)

test_metadata <- list(
  datetime = "2024-06-20 15:47:46",
  executor = "test",
  info = info
)

test_pkg_name <- "there"
test_pkg_ver <- "1.0.1"
test_pkg_source_path <- "/tmp/Rtmp0syfE3/temp_file_4644567f965d/there-1.0.1"
test_comments <- "test run"

# create test data to test score dependencies

package <- c(
  "rprojroot (>= 2.0.2)", "conflicted",
  "covr", "fs", "knitr", "palmerpenguins",      
  "plyr", "readr", "rlang",               
  "rmarkdown", "testthat", "uuid",                
  "withr"       
)

type <- c(
  "Imports",  "Suggests", "Suggests",
  "Suggests", "Suggests", "Suggests",
  "Suggests", "Suggests", "Suggests",
  "Suggests", "Suggests", "Suggests",
  "Suggests"
)

test_deps <- data.frame(package, type)

# create overall risk scores to test risk profiles
high_overall_risk_score <- .57
medium_overall_risk_score <- .33
low_overall_risk_score <- .24

r = getOption("repos")
r["CRAN"] = "http://cran.us.r-project.org"
options(repos = r)

#create results list for testing
results <- list(
  check = "",
  covr = ""
)
