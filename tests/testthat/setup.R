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

# create overall risk scores to test risk profiles
high_overall_risk_score <- .57
medium_overall_risk_score <- .33
low_overall_risk_score <- .24
