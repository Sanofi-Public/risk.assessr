#' Run R CMD CHECK
#'
#' @param pkg_source_path directory path to R project
#' @param rcmdcheck_args list of arguments to pass to `rcmdcheck::rcmdcheck`
#'
#' @details
#' rcmdcheck takes either a tarball or an installation directory.
#'
#' The basename of `pkg_source_path` should be the package name and version pasted together
#'
#' The returned score is calculated via a weighted sum of notes (0.10), warnings (0.25), and errors (1.0). It has a maximum score of 1 (indicating no errors, notes or warnings)
#' and a minimum score of 0 (equal to 1 error, 4 warnings, or 10 notes). This scoring methodology is taken directly from [riskmetric::metric_score.pkg_metric_r_cmd_check()].
#' @keywords internal
run_rcmdcheck <- function(pkg_source_path, rcmdcheck_args) {
  
  # We never want the rcmdcheck to fail
  rcmdcheck_args$error_on <- "never"
  
  # run rcmdcheck
  pkg_name <- basename(pkg_source_path)
  
  message(glue::glue("running rcmdcheck for {pkg_name}"))
  
  # Use tryCatch to handle potential errors during rcmdcheck
  res_check <- tryCatch({
    do.call(rcmdcheck::rcmdcheck, rcmdcheck_args)
  }, error = function(e) {
    message(glue::glue("rcmdcheck for {pkg_name} failed to run: {e$message}"))
    return(list(notes = character(0), warnings = character(0), errors = e$message))
  })
  
  # Initialize check_score to 0 in case res_check is NULL or calculation fails
  check_score <- 0
  
  # If res_check is not NULL, attempt to calculate the check score
  if (!is.null(res_check)) {
    
    sum_vars <- c(notes = length(res_check$notes), warnings = length(res_check$warnings), errors = length(res_check$errors))
    score_weightings <- c(notes = 0.1, warnings = 0.25, errors = 1)
    check_score <- 1 - min(c(sum(score_weightings * sum_vars), 1))
  }
  
  if(check_score == 1){
    message(glue::glue("rcmdcheck for {pkg_name} passed"))
  }else if(check_score < 1 && check_score > 0){
    message(glue::glue("rcmdcheck for {pkg_name} passed with warnings and/or notes"))
  }else if(check_score == 0){
    message(glue::glue("rcmdcheck for {pkg_name} failed. Read in the rcmdcheck output to see what went wrong: "))
  }
  
  check_list <- list(
    res_check = res_check,
    check_score = check_score
  )
  
  return(check_list)
}



#' Run covr and potentially save results to disk
#'
#' @param pkg_source_path package installation directory
#' @param timeout Timeout to pass to [callr::r_safe()] when running covr.
#'
#'
#' @return list with total coverage and function coverage
#' @keywords internal
run_coverage <- function(pkg_source_path, timeout = Inf) {
  
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
        message(glue::glue("Total coverage returned NaN. This likely means the package had non-standard characteristics."))
        notes <- NA
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
      errors = cond,
      notes = NA
    )
  })
  
  if(is.na(res_cov$coverage$totalcoverage)) {
    message(glue::glue("code coverage for {pkg_name} unsuccessful"))
  } else {
    message(glue::glue("code coverage for {pkg_name} successful"))
  }  
  
  # return total coverage as fraction
  total_cov <- as.numeric(res_cov$coverage$totalcoverage/100)
  
  if(is.na(total_cov)){
    message(glue::glue("R coverage for {pkg_name} failed. Read in the covr output to see what went wrong: "))
  }
  
  if(!is.na(res_cov$notes)){
    message(glue::glue("R coverage for {pkg_name} had notes: {res_cov$notes}"))
  }
  
  covr_list <- list(
    total_cov = total_cov,
    res_cov = res_cov
  )
  return(covr_list)
}

#' Run covr in subprocess with timeout
#'
#' @param path - path to source file
#' @param timeout - length of timeout - set to Inf
#' @keywords internal
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


