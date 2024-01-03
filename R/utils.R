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

#' Untar package and return installation directory
#'
#' @param pkg_tar path to tarball package
#' @param temp_file_name name of `tempfile`
#'
#' @export
unpack_tarball <- function(pkg_tar, temp_file_name = "temp_file_"){
  # Create temporary location for package installation
  temp_pkg_dir <- tempfile(temp_file_name)
  if (!dir.create(temp_pkg_dir)) stop("unable to create ", temp_pkg_dir)
  
  source_tar_dir <- file.path(temp_pkg_dir)
  
  # unpack tarball
  
  utils::untar(pkg_tar, exdir = source_tar_dir)
  
  # unpackaged package path
  pkg_source_path <- fs::dir_ls(source_tar_dir)
  
  # Confirm tar is unpackaged in expected directory
  checkmate::assert_string(pkg_source_path)
  checkmate::assert_directory_exists(pkg_source_path)
  
  return(pkg_source_path)
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
                                    default_weights = TRUE) {
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

