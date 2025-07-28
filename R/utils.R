#' Read Description file and parse the package name and version
#'
#' @param pkg_source_path path to package source code (untarred)
#' @param fields - select specified elements from description
#'
#' @return list with package description
#' @keywords internal
get_pkg_desc <- function(pkg_source_path, fields = NULL){
  
  pkg_desc_path <- file.path(pkg_source_path, "DESCRIPTION")
  
  desc_file <- read.dcf(pkg_desc_path, fields = fields)[1L,]
  pkg_desc <- as.list(desc_file)
  
  return(pkg_desc)
}

#' Get risk metadata
#'
#' @param executor - user who executes the riskmetrics process 
#' 
#' adapted from mrgvalprep::get_sys_info() and mpn.scorecard
#' @importFrom rlang %||%
#' 
#' @return list with metadata
#' @keywords internal
get_risk_metadata <- function(executor = NULL) {
  checkmate::assert_string(executor, null.ok = TRUE)
  
  metadata <- list(
    datetime = as.character(Sys.time()),
    executor = executor %||% Sys.getenv("USER"),
    info = list()
  )
  
  metadata[["info"]][["sys"]] <- as.list(Sys.info())[c("sysname", "version", "release", "machine")]
  
  return(metadata)
}

#' Assign output file path for various outputs during scorecard rendering
#'
#' @param out_dir output directory for saving results
#' @param ext file name and extension
#'
#' @details
#' The basename of `out_dir` should be the package name and version pasted together
#' @keywords internal
get_result_path <- function(
    out_dir,
    ext = c("check.rds", "covr.rds", "tm_doc.rds", "tm_doc.xlsx")
){
  
  ext <- match.arg(ext)
  
  pkg_name <- basename(out_dir)
  
  file.path(out_dir, paste0(pkg_name,".",ext))
}

#' Set the default weight of each metric to 1.
#'
#' @param data risk metric data
#'
#' @keywords internal
add_default_risk_weights <- function(data) {
  
  # ignore columns that are not of class 'pkg_score'
  ignore_cols <- c("package", "version", "pkg_ref", "pkg_score")
  metrics <- names(data)[!(names(data) %in% ignore_cols)]
  
  # assign a weight of 1 to each metric
  weights <- rep(1, length(metrics))
  names(weights) <- metrics
  
  weights
}

#' Check that the provided weights are numeric and non-negative.
#' 
#' @param weights vector with weight values
#'
#' @keywords internal
check_risk_weights <- function(weights) {
  if (!is.numeric(weights))
    stop("The weights must be a numeric vector.")
  
  if (!all(weights >= 0))
    stop("The weights must contain non-negative values only.")
}

#' Check weights values and standardize them.
#'
#' @param data risk metric data
#' @param weights vector with weight values
#'
#' @keywords internal
standardize_risk_weights <- function(data, weights) {
  
  # check that the weights vector is numeric and non-negative
  check_risk_weights(weights)
  
  # re-weight for fields that are in the dataset
  weights <- weights[which(names(weights) %in% names(data))]
  
  # standardize weights from 0 to 1
  weights <- weights / sum(weights, na.rm = TRUE)
}

#' Calculate overall package risk scores
#'
#' @param data risk metric data
#' @param default_weights logical T/F for weights choice
#'
#' @return pkg_score
#' @examples
#' \donttest{
#' data <- list(
#'   pkg_name = "synapser",
#'   pkg_version = "0.2.1",
#'   pkg_source_path = "/tmp/RtmpNpDlUz/temp_file_1fe56774aacc/synapser",
#'   has_bug_reports_url = 1, 
#'   has_examples = 1,
#'   has_maintainer = 1,
#'   size_codebase = 0.06702413,
#'   has_news = 0,
#'   has_source_control = 0,
#'   has_vignettes = 1,
#'   has_website = 1,
#'   news_current = 0,
#'   export_help = 1,
#'   export_calc = 0.586281,
#'   check = .7,
#'   covr = .1084,
#'   dep_score = .9706878,
#'   revdep_score = .1260338
#'   )
#'   overall_risk_score <- 
#'     calc_overall_risk_score(data, 
#'                             default_weights = TRUE)
#' }
#' @export
calc_overall_risk_score <- function(data, 
                                    default_weights = FALSE) {
  # create weights profile
  
  if (default_weights == TRUE) {
    weights <- add_default_risk_weights(data) 
    message(glue::glue("Default weights used"))
  } else {
    weights <- risk.assessr::create_weights_profile()
    message(glue::glue("User defined weights used"))
  }  
  
  # perform checks and standardize weights
  weights <- standardize_risk_weights(data, weights)
  pkg_score <- suppressWarnings(1 - sum(as.numeric(data[names(weights)]) * weights, 
                                        na.rm = TRUE))
  return(pkg_score)
}

#' Calculate package risk profile
#'
#' @param risk_data overall risk score
#'
#' @return risk_profile
#' @examples
#' \dontrun{
#' # Toy dataset
#' toy_data <- data.frame(score = c(0.1, 0.2, 0.3, 0.4, 0.8, 1.2))
#'
#' calc_risk_profile(toy_data)
#' }
#' 
#' @export
calc_risk_profile <- function(risk_data) {
  
  # get risk profile thresholds
  risk_profile_thresholds <- create_risk_profile()
  
  risk_data <- as.data.frame(risk_data)
  # set up risk profile thresholds
  high_risk_threshold <- risk_profile_thresholds$high_risk_threshold
  medium_risk_threshold <- risk_profile_thresholds$medium_risk_threshold
  low_risk_threshold <- risk_profile_thresholds$low_risk_threshold
  
  # perform risk profile 
  risk_data <- risk_data |> 
    dplyr::mutate(risk_profile = dplyr::case_when(risk_data <= low_risk_threshold ~ "Low",
                                                  risk_data <= medium_risk_threshold ~ "Medium",
                                                  risk_data <= high_risk_threshold ~ "High",
                                                  TRUE ~ " ")) 
  
  # pull risk profile
  risk_profile <- risk_data |> dplyr::pull(risk_profile)
  
  message(glue::glue("Risk profile calculated"))  
  
  return(risk_profile)
}

#' Re-calculate package risk scores
#' 
#' @description {Use this function to re-calculate risk scores and risk profile}
#' @details {Use cases: if the weighting profile and/or risk profile thresholds
#' have changed and the risk metrics have not changed, then
#' use this function to re-calculate the risk scores and profile
#' without running the whole risk assessment process again}
#' 
#' @param riskdata_results - path to riskdata_results toy dataset
#' @param update_comments notes explaining why score recalculated
#' 
#' @return A dataframe containing both the original and newly calculated risk scores, 
#'         profiles, and comments. 
#' 
#' @keywords internal
recalc_risk_scores <- function(riskdata_results, update_comments) {
  
  
  # read in the results
  results <- read.csv(file.path(riskdata_results))
  
  # save existing data 
  results_old <- results 
  
  # filter existing data from initial run
  results <- results |> 
    dplyr::filter(grepl("\\Initial", comments, ignore.case = FALSE))
  
  # convert NAs and NANs to zero
  results <- rapply( results, f=function(x) ifelse(is.nan(x),0,x), how="replace" )	  
  results <- rapply( results, f=function(x) ifelse(is.na(x),0,x), how="replace" )
  
  # calculate risk score with user defined metrics
  results$overall_risk_score <- results |>
    split(1:nrow(results)) |> 
    purrr::map(risk.assessr::calc_overall_risk_score) |> 
    unlist()
  
  
  # calculate risk profile with user defined thresholds
 results$risk_profile <- results |>
   dplyr::select(overall_risk_score) |> 
   split(1:nrow(results)) |>
   purrr::map(risk.assessr::calc_risk_profile) |> 
   unlist()
 
 # add comments
 results <- results |> 
    dplyr::mutate(comments = update_comments)

 # append new data to old data  
 results <- rbind(results_old, results)
 
}

#' get package name for display
#'
#' @param input_string - string containing package name
#'
#' @return pkg_disp - package name for display
#'
#' @examples
#' \donttest{
#' pkg_source_path <- "/home/user/R/test.package.0001_0.1.0.tar.gz"
#' pkg_disp_1 <- get_pkg_name(pkg_source_path)
#' print(pkg_disp_1)
#' 
#' pkg <- "TxDb.Dmelanogaster.UCSC.dm3.ensGene_3.2.2.tar.gz"
#' pkg_disp_2 <- get_pkg_name(pkg)
#' print(pkg_disp_2)
#' }
#' 
#' @export
get_pkg_name <- function(input_string) {
  
  # check if input string is a file path or filename   
  test_string <-  stringr::str_match(input_string, "/")  
  
  if (any(is.na(test_string)) == FALSE) {
    # extract package name from the last part of the file path
    input_string <- stringr::str_split_i(input_string, "/", -1)  
    
  }
  
  # extract package name
  pkg_disp <- stringr::str_extract(input_string, "[^-|_]+")
  
  return(pkg_disp)
}

