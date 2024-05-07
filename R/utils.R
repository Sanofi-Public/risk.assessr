#' Read Description file and parse the package name and version
#'
#' @param pkg_source_path path to package source code (untarred)
#'
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
#' @export
#'

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
#'
#' @export
#' 
get_result_path <- function(
    out_dir,
    ext = c("check.rds", "covr.rds")
){
  
  ext <- match.arg(ext)
  
  pkg_name <- basename(out_dir)
  
  file.path(out_dir, paste0(pkg_name,".",ext))
}

#' Check if a path exists and delete the file
#' if overwrite is TRUE
#' @param path a file path to check if it exists
#' @param overwrite Logical (T/F). If `TRUE`, delete the file at the specified path
#'
#' @export
#' 
check_exists_and_overwrite <- function(path, overwrite) {
  checkmate::assert_string(path)
  checkmate::assert_logical(overwrite, len = 1)
  
  if (fs::file_exists(path)) {
    if (isTRUE(overwrite)) {
      fs::file_delete(path)
    } else {
      rlang::abort(glue::glue("{path} already exists. Pass overwrite = TRUE to overwrite it."))
    }
  }
}

#' Write results to csv
#'
#' @param data - results data
#' @param riskscore_data_path directory path and file name
#' @param riskscore_data_exists logical with T/F if risk score data exists
#'
#' @export
#'
write_data_csv <- function(data, 
                           riskscore_data_path, 
                           riskscore_data_exists) {
  # convert data to dataframe
  
  data <- as.data.frame(data)
  
  # check if file exists
  if(riskscore_data_exists == TRUE) {
    # If the file exists, run the append code.
    readr::write_excel_csv(data, riskscore_data_path, append=TRUE)
    message(glue::glue("Data appended to csv"))
  } else { 
    # If it doesn't exist, save the file with the columns included.
    readr::write_excel_csv(data, riskscore_data_path, append=FALSE)
    message(glue::glue("Data written to csv"))
  }
}

#' Set the default weight of each metric to 1.
#'
#' @param data risk metric data
#'
#' @export
#' 
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
#' @export
#' 
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
#' 
standardize_risk_weights <- function(data, weights) {
  
  # check that the weights vector is numeric and non-negative
  check_risk_weights(weights)
  
  # re-weight for fields that are in the dataset
  weights <- weights[which(names(weights) %in% names(data))]
  
  # standardize weights from 0 to 1
  weights <- weights / sum(weights, na.rm = TRUE)
}

#' Assess exported functions to namespace
#'
#' @param data pkg source path
#' 
#' @export
#'
assess_exports <- function(data) {
  exports <- pkgload::parse_ns_file(data)$exports
  export_calc <- 1 - 1 / (1 + exp(-0.25 * (sqrt(length(exports)) - sqrt(25))))
}  

#' Calculate overall package risk scores
#'
#' @param data risk metric data
#' @param default_weights logical T/F for weights choice
#'
#' @return pkg_score
#' @export
#'
calc_overall_risk_score <- function(data, 
                                    default_weights = FALSE) {
  # create weights profile
  
  if (default_weights == TRUE) {
    weights <- add_default_risk_weights(data) 
    message(glue::glue("Default weights used"))
  } else {
    weights <- sanofi.risk.metric::create_weights_profile()
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
#' @export
#'
calc_risk_profile <- function(risk_data) {
  
  # get risk profile thresholds
  risk_profile_thresholds <- sanofi.risk.metric::create_risk_profile()
  
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


#' check if risk score data exists
#'
#' @return riskscore_data_list - list with path and exists logical
#' @export
#'
check_riskscore_data_internal <- function() {
  library(sanofi.risk.metric)
  
  riskscore_data_list <- list()
  
  riskscore_data_path <- here::here("inst", "extdata", "riskdata_results.csv")
  
  riskscore_data_exists <- 
    file.exists(riskscore_data_path)
  
  riskscore_data_list <- list(
    riskscore_data_path = riskscore_data_path,
    riskscore_data_exists = riskscore_data_exists 
  )
  return(riskscore_data_list)
}

#' Re-calculate package risk scores
#' 
#' @description$ {Use this function to re-calculate risk scores and risk profile}
#' @details$ {Use cases: if the weighting profile and/or risk profile thresholds
#' have changed and the risk metrics have not changed, then
#' use this function to re-calculate the risk scores and profile
#' without running the whole risk assessment process again}
#' 
#'
#' @param comments notes explaining why score recalculated
#' 
#' @export
#'
recalc_risk_scores <- function(comments) {
  
  # check if risk score data exists and set up path to risk score data
  riskscore_data_list <- 
    sanofi.risk.metric::check_riskscore_data_internal()
  
  riskscore_data_path <- riskscore_data_list$riskscore_data_path
  
  message("data path is ", riskscore_data_path)
  
  riskscore_data_exists <- riskscore_data_list$riskscore_data_exists
  
  results <- read.csv(file.path(riskscore_data_path))
  
  exclude_vector <- "X"
  results <- results |> 
    dplyr::select(-dplyr::all_of(exclude_vector)) 
  
  # convert NAs and NANs to zero
  results <- rapply( results, f=function(x) ifelse(is.nan(x),0,x), how="replace" )	  
  results <- rapply( results, f=function(x) ifelse(is.na(x),0,x), how="replace" )
  
  # calculate risk score with user defined metrics
    results$overall_risk_score <- results |>
    split(1:nrow(results)) |> 
    purrr::map(sanofi.risk.metric::calc_overall_risk_score) |> 
    unlist()
  
  
  # calculate risk profile with user defined thresholds
 results$risk_profile <- results |>
   dplyr::select(overall_risk_score) |> 
   split(1:nrow(results)) |>
   purrr::map(sanofi.risk.metric::calc_risk_profile) |> 
   unlist()
  
 results <- results |> 
    dplyr::mutate(comments, 
                  .before = has_bug_reports_url)
  
  # write data to csv
  sanofi.risk.metric::write_data_csv(results, 
                                     riskscore_data_path, 
                                     riskscore_data_exists)
  
}

