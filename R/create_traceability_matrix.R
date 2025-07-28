#' Create a Traceability Matrix
#'
#' Returns a table that links all exported functions and their aliases to their documentation (`man` files),
#' the R scripts containing them, and the test scripts that reference them.
#' 
#' @param pkg_name name of package
#' @param pkg_source_path path to a source package
#' @param func_covr function coverage
#' @param verbose Logical (`TRUE`/`FALSE`). If `TRUE`, show any warnings/messages per function.
#'
#' @returns a tibble with traceability matrix
#' @keywords internal
create_traceability_matrix <- function(pkg_name, 
                                       pkg_source_path, 
                                       func_covr,
                                       verbose = FALSE){
  
  message(glue::glue("creating traceability matrix for {pkg_name}"))
  
  # Check that package has an R folder
  tm_possible <- contains_r_folder(pkg_source_path) 
  # 
  if (tm_possible == FALSE) {
    tm <- create_empty_tm(pkg_name)
    message(glue::glue("no R folder to create traceability matrix for {pkg_name}"))
  } else {  
    
    # Get data.frame of exported functions
    exports_df <- get_exports(pkg_source_path)
    
    # Locate script for each exported function
    exports_df <- map_functions_to_scripts(exports_df, pkg_source_path, verbose)
    
    # Remove duplicates from exports
    exports_df <- exports_df %>%
      dplyr::distinct(exported_function, .keep_all = TRUE)
    
    # Map all Rd files to functions, then join back to exports
    exports_df <- map_functions_to_docs(exports_df, pkg_source_path, verbose)
    
    descrip <- get_func_descriptions(pkg_name)
    
    # create df
    descript_df <- data.frame(
      exported_function = names(descrip),
      description = unlist(descrip, use.names = FALSE)
    )
    
    exports_df <- dplyr::left_join(exports_df, 
                                   descript_df, 
                                   by = "exported_function")
    
    # Filter out rows with specific keywords in descriptions
    exports_df <- exports_df %>%
      dplyr::filter(!grepl("defunct|deprecated|deprec|superseded|imported|re-exported|reexports", 
                           code_script, ignore.case = TRUE))  %>%
      dplyr::filter(!grepl("defunct|deprecated|deprec|superseded|imported|re-exported|reexports", 
                           description, ignore.case = TRUE)) %>%
      dplyr::filter(!grepl("defunct|deprecated|deprec|superseded|imported|re-exported|reexports", 
                           documentation, ignore.case = TRUE)) %>%
      dplyr::filter(!grepl("%>%", exported_function, ignore.case = TRUE)) %>%
      # filter out these functions from the methods package 
      # as they have no documentation
      dplyr::filter(!grepl("^\\.__C__|^\\.__T__", exported_function))
    
        # convert array to df
    func_coverage <- as.data.frame.table(func_covr$coverage$filecoverage)
    
    # check for column existence
    column_exists <- function(df, column_name) {
      return(column_name %in% names(df))
    }
    cl_exists <- column_exists(func_coverage, "Var1")
    
    if (cl_exists == TRUE) {  
    
      func_coverage <- func_coverage |> dplyr::rename(code_script = Var1, 
                                                      coverage_percent = Freq)
      
      # create traceability matrix
      tm <- dplyr::left_join(exports_df, 
                             func_coverage, 
                             by = "code_script") 
      
      message(glue::glue("traceability matrix for {pkg_name} successful"))
    } else {
      tm <- create_empty_tm(pkg_name)
      message(glue::glue("traceability matrix for {pkg_name} unsuccessful"))
    }
  }
  return(tm)
}

#' Get all exported functions and map them to R script where they are defined
#'
#' adapted from mpn.scorecard
#'
#' @param exports_df data.frame with a column, named `exported_function`,
#'   containing the names of all exported functions. Can also have other columns
#'   (which will be returned unmodified).
#' @param pkg_source_path a file path pointing to an unpacked/untarred package directory
#' @param verbose check for extra information
#'
#' @return A data.frame with the columns `exported_function` and `code_script`.
#' @keywords internal
map_functions_to_scripts <- function(exports_df, pkg_source_path, verbose){
  
  # Search for scripts functions are defined in
  funcs_df <- get_toplevel_assignments(pkg_source_path)
  
  if(nrow(funcs_df) == 0){
    # Triggering this means an R/ directory exists, but no assignments were found.
    exports_df <- data.frame()
    message(glue::glue("No top level assignments found in R folder for {basename(pkg_source_path)}"))
    # msg <- paste(
    #   "No top level assignments were found in the R/ directory for package",
    #   glue::glue("`{basename(pkg_source_path)}`."),
    #   "Exports cannot be linked to their defining script."
    # )
    # warning(msg)
  } else {
  
    exports_df <- dplyr::left_join(exports_df, funcs_df, by = c("exported_function" = "func"))
    
    if (any(is.na(exports_df$code_script))) {
      if(isTRUE(verbose)) {
        missing_from_files <- exports_df$exported_function[is.na(exports_df$code_file)] %>%
          paste(collapse = "\n")
        message(glue::glue("The following exports were not found in R/ for {basename(pkg_source_path)}:\n{missing_from_files}\n\n"))
      }
    }
  }
  return(exports_df)
}

#' list all package exports
#'
#' adapted from mpn.scorecard
#'
#' @param pkg_source_path a file path pointing to an unpacked/untarred package directory
#'
#' @return data.frame, with one column `exported_function`, that can be passed
#'   to all downstream map_* helpers
#' @keywords internal
get_exports <- function(pkg_source_path){
  # Get exports
  
  nsInfo <- parseNamespaceFile(basename(pkg_source_path), dirname(pkg_source_path), mustExist = FALSE)
  exports <- unname(unlist(nsInfo[c("exports","exportMethods")]))
  
  # Look for export patterns
  if(!rlang::is_empty(nsInfo$exportPatterns)){
    all_functions <- get_toplevel_assignments(pkg_source_path)$func
    for (p in nsInfo$exportPatterns) {
      exports <- c(all_functions[grep(pattern = p, all_functions)], exports)
    }
  }
  
  # Remove specific symbols from exports
  exports <- unique(exports)
  exports <- filter_symbol_functions(exports)
  
  if(rlang::is_empty(exports)){
    message(glue::glue("No exports found in package {basename(pkg_source_path)}"))
  }
  
  return(dplyr::tibble(exported_function = exports))
}


#' Remove specific symbols from vector of functions
#'
#' adapted from mpn.scorecard
#' 
#' @param funcs vector of functions to filter
#'
#' @keywords internal
filter_symbol_functions <- function(funcs){
  ignore_patterns <- c("\\%>\\%", "\\$", "\\[\\[", "\\[", "\\+", "\\%", "<-")
  pattern <- paste0("(", paste(ignore_patterns, collapse = "|"), ")")
  funcs_return <- grep(pattern, funcs, value = TRUE, invert = TRUE)
  return(funcs_return)
}

#' list all top-level objects defined in the package code
#'
#' adapted from mpn.scorecard
#' 
#' This is primarily for getting all _functions_, but it also returns top-level
#' declarations, regardless of type. This is intentional, because we also want
#' to capture any global variables or anything else that could be potentially
#' exported by the package.
#'
#' @param pkg_source_path a file path pointing to an unpacked/untarred package directory
#'
#' @return A data.frame with the columns `function` and `code_script` with a row for
#'   every top-level object defined in the package.
#'
#' @keywords internal
get_toplevel_assignments <- function(pkg_source_path){
  
  r_files <- tools::list_files_with_type(file.path(pkg_source_path, "R"), "code")
  
  # Triggering this means an R/ directory exists, but no R/Q/S files were found.
  if(rlang::is_empty(r_files)){
    # This shouldn't be triggered, and either indicates a bug in `get_toplevel_assignments`,
    # or an unexpected package setup that we may want to support.
    message(glue::glue("No sourceable R scripts were found in the R/ directory for package {basename(pkg_source_path)}. Make sure this was expected."))
    return(dplyr::tibble(func = character(), code_script = character()))
  }
  
  pkg_functions <- purrr::map_dfr(r_files, function(r_file_i) {
    
    exprs <- tryCatch(parse(r_file_i), error = identity)
    if (inherits(exprs, "error")) {
      warning("Failed to parse ", r_file_i, ": ", conditionMessage(exprs))
      return(dplyr::tibble(func = character(), code_script = character()))
    }
    
    calls <- purrr::keep(as.list(exprs), function(e) {
      if (is.call(e)) {
        op <- as.character(e[[1]])
        return(length(op) == 1 && op %in% c("<-", "=", "setGeneric"))
      }
      return(FALSE)
    })
    lhs <- purrr::map(calls, function(e) {
      name <- as.character(e[[2]])
      if (length(name) == 1) {
        return(name)
      }
    })
    
    function_names <- unlist(lhs) %||% character()
    if (length(function_names) == 0 ) {
      return(dplyr::tibble(func = character(), code_script = character()))
    }
    return(dplyr::tibble(
      func = function_names,
      code_script = rep(fs::path_rel(r_file_i, pkg_source_path), length(function_names))
    ))
  })
  # TODO: do we need to check if there are any funcs defined in multiple files?
  
  return(pkg_functions)
}





