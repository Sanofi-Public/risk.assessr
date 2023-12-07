#' Run R CMD CHECK
#'
#' @param pkg_source_path directory path to R project
#' @param out_dir directory for saving results
#' @param rcmdcheck_args list of arguments to pass to `rcmdcheck::rcmdcheck`
#'
#' @details
#' rcmdcheck takes either a tarball or an installation directory.
#'
#' The basename of `pkg_source_path` should be the package name and version pasted together
#'
#' The returned score is calculated via a weighted sum of notes (0.10), warnings (0.25), and errors (1.0). It has a maximum score of 1 (indicating no errors, notes or warnings)
#' and a minimum score of 0 (equal to 1 error, 4 warnings, or 10 notes). This scoring methodology is taken directly from [riskmetric::metric_score.pkg_metric_r_cmd_check()].
#'
#' @export
#' 
add_rcmdcheck <- function(pkg_source_path, out_dir, rcmdcheck_args) {
  
  # We never want the rcmdcheck to fail
  rcmdcheck_args$error_on <- "never"
  
  # run rcmdcheck
  pkg_name <- basename(pkg_source_path)
  
  message(glue::glue("running rcmdcheck for {pkg_name}"))
  
  res_check <- do.call(rcmdcheck::rcmdcheck, rcmdcheck_args)
  
  # write results to RDS
  saveRDS(
    res_check,
    get_result_path(out_dir, "check.rds")
  )
  
  message(glue::glue("writing rcmdcheck results for {pkg_name}"))
  
  # Note that res_check$status is the opposite of what we want (1 means failure, 0 means passing)
  
  # Scoring is the weighted sum of notes (0.1), errors (1) and warnings (0.25) (scoring method taken from `riskmetric`)
  sum_vars <- c(notes = length(res_check$notes), warnings = length(res_check$warnings), errors = length(res_check$errors))
  score_weightings <- c(notes = 0.1, warnings = 0.25, errors = 1)
  check_score <- 1 - min(c(sum(score_weightings*sum_vars), 1))
  
  if(check_score == 1){
    message(glue::glue("rcmdcheck for {pkg_name} passed"))
  }else if(check_score < 1 && check_score > 0){
    message(glue::glue("rcmdcheck for {pkg_name} passed with warnings and/or notes"))
  }else if(check_score == 0){
    check_path <- get_result_path(out_dir, "check.rds")
    message(glue::glue("rcmdcheck for {pkg_name} failed. Read in the rcmdcheck output to see what went wrong: {check_path}"))
  }
  
  return(check_score)
}




#' Run covr and potentially save results to disk
#'
#' @param pkg_source_path package installation directory
#' @param out_dir directory for saving results
#' @param timeout Timeout to pass to [callr::r_safe()] when running covr.
#'
#' @details
#' The basename of `out_dir` should be the package name and version pasted together
#'
#' @export
#' 
add_coverage <- function(pkg_source_path, out_dir, timeout = Inf) {
  
  pkg_name <- basename(pkg_source_path)
  
  message(glue::glue("running code coverage for {pkg_name}"))
  
  # run covr
  res_cov <- tryCatch({
    coverage_list <- run_covr(pkg_source_path, timeout)
    
    # If no testable functions are found in the package, `filecoverage` and `totalcoverage`
    # will yield logical(0) and NaN respectively. Coerce to usable format
    if(is.na(coverage_list$totalcoverage)){
      if(rlang::is_empty(coverage_list$filecoverage) && is.logical(coverage_list$filecoverage)){
        coverage_list$totalcoverage <- 0
        notes <- "no testable functions found"
      }else{
        rlang::abort("Total coverage returned NaN. This likely means the package had non-standard characteristics. Contact the developer to add support")
      }
    }else{
      notes <- NA
    }
    
    list(name = pkg_name, coverage = coverage_list, errors = NA, notes = notes)
  },
  error = function(cond){
    coverage_list <- list(filecoverage = NA, totalcoverage = NA_integer_)
    list(
      name = pkg_name, coverage = coverage_list,
      errors = wrap_callr_error(cond),
      notes = NA
    )
  })
  
  message(glue::glue("code coverage for {pkg_name} successful"))
  
  message(glue::glue("writing code coverage results for {pkg_name}"))
  # write results to RDS
  saveRDS(
    res_cov,
    sanofi.risk.metric::get_result_path(out_dir, "covr.rds")
  )
  
  # return total coverage as fraction
  total_cov <- as.numeric(res_cov$coverage$totalcoverage/100)
  
  if(is.na(total_cov)){
    message(glue::glue("R coverage for {pkg_name} failed. Read in the covr output to see what went wrong: "))
  }
  
  if(!is.na(res_cov$notes)){
    message(glue::glue("R coverage for {pkg_name} had notes: {res_cov$notes}"))
  }
  
  return(total_cov)
}

#' Run covr in subprocess with timeout
#'
#' @noRd
run_covr <- function(path, timeout) {
  callr::r_safe(
    function(p) {
      covr::coverage_to_list(covr::package_coverage(p, type = "tests"))
    },
    args = list(path),
    libpath = .libPaths(),
    repos = NULL,
    package = FALSE,
    user_profile = FALSE,
    error = "error",
    timeout = timeout
  )
}

wrap_callr_error <- function(e) {
  class(e) <- c("scorecard_covr_error", class(e))
  return(e)
}

#' @export
conditionMessage.scorecard_covr_error <- function(c) {
  # Prevent rlib_error_3_0 method from adding ansi escape sequences, which would
  # trigger a LateX failure on render.
  withr::local_options(list("crayon.enabled" = FALSE))
  NextMethod()
}