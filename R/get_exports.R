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
#'
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
        missing_from_files <- exports_df$exported_function[is.na(exports_df$code_script)] %>%
          paste(collapse = "\n")
        message(glue::glue("The following exports were not found in R/ for {basename(pkg_source_path)}:\n{missing_from_files}\n\n"))
      }
    }
  }
  return(exports_df)
}

#' Extract package name from package source path
#'
#' @param pkg_source_path a file path pointing to an unpacked/untarred package directory
#'
#' @return  package_name
#'
#' @keywords internal
extract_package_name <- function(pkg_source_path) {
  # Split the path by "::"
  parts <- strsplit(pkg_source_path, "::")[[1]]
  
  # Extract the part before "::"
  package_part <- parts[1]
  
  # Remove everything before the package name and the version
  package_name <- sub(".*[/\\\\]", "", package_part)
  package_name <- sub("-[0-9.]+$", "", package_name)
  
  return(package_name)
}

#' list all package exports
#'
#' adapted from mpn.scorecard
#'
#' @param pkg_source_path a file path pointing to an unpacked/untarred package directory
#'
#' @return data.frame, with one column `exported_function`, that can be passed
#'   to all downstream map_* helpers
#'
#' @export
get_exports <- function(pkg_source_path) {
  # Get exports

  nsInfo <- parseNamespaceFile(basename(pkg_source_path), dirname(pkg_source_path), mustExist = FALSE)
  exports <- unname(unlist(nsInfo[c("exports", "exportMethods")]))
  function_types <- rep(NA, length(exports))
  
  # Check S3methods and get values from [,1] and [,2]
  if (!rlang::is_empty(nsInfo$S3methods)) {
    # check for NA values in all rows before pasting value
    s3_methods <- apply(nsInfo$S3methods, 1, function(row) {
      if (all(is.na(row[1:2]))) {
        NA_character_
      } else {
        paste(row[1], row[2], sep = ".")
      }
    })
    
    exports <- c(exports, s3_methods)
    function_types <- c(function_types, rep("S3 function", length(s3_methods)))
  }
  
  # Create initial result tibble
  result <- dplyr::tibble(exported_function = exports, 
                          function_type = function_types)
  
  # Check if other exported function_types
  for (i in seq_along(result$exported_function)) {
    if (is.na(result$function_type[i])) {
      
      func_name <- result$exported_function[i]
      package_name <- extract_package_name(pkg_source_path)
      func_full_name <- paste0(package_name, "::", func_name)
      value <- tryCatch(eval(parse(text = func_full_name)), error = function(e) NULL)
      if (is.numeric(value)) {
        result$function_type[i] <- "numeric"
      } else if (class(value)[1] %in% c("rlang_fake_data_pronoun")) {
        # check if this is an rlang re-export
        result$function_type[i] <- "rlang tidy eval"
      } else if (check_ggproto(value)) {
        result$function_type[i] <- "ggproto"
      } else if (methods::isGeneric(func_name)) {
        result$function_type[i] <- "S4 function"  
      } else {
        result$function_type[i] <- "regular"
      } 
    }  
  }
  
  # Remove duplicates from exports
  result <- result %>%
    dplyr::distinct(exported_function, .keep_all = TRUE)
  
  return(result)
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
        # process S3 and S4 functions
        return(length(op) == 1 && op %in% c("<-", "=", "setGeneric", "setMethod"))
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

#' Map all Rd files to the functions they describe
#'
#' adapted from mpn.scorecard
#'
#' @return Returns the data.frame passed to `exports_df`, with a `documentation`
#'   column appended. This column will contain the path to the `.Rd` files in
#'   `man/` that document the associated exported functions.
#'
#' @keywords internal
map_functions_to_docs <- function(exports_df, pkg_source_path, verbose) {
  
  rd_files <- list.files(file.path(pkg_source_path, "man"), full.names = TRUE)
  rd_files <- rd_files[grep("\\.Rd$", rd_files)]
  if (length(rd_files) == 0) {
    if(isTRUE(verbose)){
      message(glue::glue("No documentation was found in `man/` for package `{basename(pkg_source_path)}`"))
    }
    return(dplyr::mutate(exports_df, "documentation" = NA))
  }
  
  docs_df <- purrr::map_dfr(rd_files, function(rd_file.i) {
    rd_lines <- readLines(rd_file.i) %>% suppressWarnings()
    
    # Get Rd file and aliases for exported functions
    function_names_lines <- rd_lines[grep("(^\\\\alias)|(^\\\\name)", rd_lines)]
    function_names <- unique(gsub("\\}", "", gsub("((\\\\alias)|(\\\\name))\\{", "", function_names_lines)))
    
    man_name <- paste0(basename(rd_file.i))
    
    data.frame(
      pkg_function = function_names,
      documentation = rep(man_name, length(function_names))
    )
  })
  
  # if any functions are aliased in more than 1 Rd file, collapse those Rd files to a single row
  # TODO: is this necessary? is it even possible to have this scenario without R CMD CHECK failing?
  docs_df <- docs_df %>%
    dplyr::group_by(.data$pkg_function) %>%
    dplyr::summarize(documentation = paste(unique(.data$documentation), collapse = ", ")) %>%
    dplyr::ungroup()
  
  # join back to filter to only exported functions
  exports_df <- dplyr::left_join(exports_df, docs_df, by = c("exported_function" = "pkg_function"))
  
  # message if any exported functions aren't documented
  if (any(is.na(exports_df$documentation)) && isTRUE(verbose)) {
    docs_missing <- exports_df %>% dplyr::filter(is.na(.data$documentation))
    exports_missing <- unique(docs_missing$exported_function) %>% paste(collapse = "\n")
    code_files_missing <- unique(docs_missing$documentation) %>% paste(collapse = ", ")
    message(glue::glue("In package `{basename(pkg_source_path)}`, the R scripts ({code_files_missing}) are missing documentation for the following exports: \n{exports_missing}"))
  }
  
  return(exports_df)
}