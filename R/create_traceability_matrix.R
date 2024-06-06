#' Create a Traceability Matrix
#'
#' Returns a table that links all exported functions and their aliases to their documentation (`man` files),
#' the R scripts containing them, and the test scripts that reference them.
#' 
#' @param pkg_name name of package
#' @param pkg_source_path path to a source package
#' @param func_covr function coverage
#' @param results_dir where matrix will be written
#' @param verbose Logical (`TRUE`/`FALSE`). If `TRUE`, show any warnings/messages per function.
#'
#' @returns a tibble
#'
#' @export
create_traceability_matrix <- function(pkg_name, 
                                       pkg_source_path, 
                                       func_covr,
                                       results_dir = NULL, verbose = FALSE){
  
  message(glue::glue("creating traceability matrix for {pkg_name}"))
  
  # Check that package is valid
  check_tm_possible(pkg_source_path)
  
  # Get data.frame of exported functions
  exports_df <- get_exports(pkg_source_path)
  
  # Locate script for each exported function
  exports_df <- map_functions_to_scripts(exports_df, pkg_source_path, verbose)
  
  # Map all Rd files to functions, then join back to exports
  exports_df <- map_functions_to_docs(exports_df, pkg_source_path, verbose)
  
  descrip <- get_func_descriptions(pkg_name)
  descript_df <- tibble::enframe(descrip) |> 
    dplyr::rename(
                  c(documentation = name,
                    description = value)
                  )
  
  exports_df <- dplyr::left_join(exports_df, 
                                 descript_df, 
                                 by = "documentation")
  
  # convert array to df
  func_coverage <- as.data.frame.table(func_covr$coverage$filecoverage)
  
  func_coverage <- func_coverage |> dplyr::rename(code_script = Var1, 
                                                  coverage_percent = Freq)
  
  # create traceability matrix
  tm <- dplyr::left_join(exports_df, func_coverage, by = "code_script") |> 
    dplyr::mutate(date_time = "") |> 
    dplyr::mutate(Signature = "") |> 
    # set up first row
    tibble::add_row(exported_function = pkg_name, 
                    code_script = "",
                    documentation = "",
                    coverage_percent = 0,
                    date_time = as.character(Sys.time()),
                    Signature = "",
                    .before = 1) |> 
    dplyr::rename(package_function = exported_function)
  
  # write results to RDS
  if(!is.null(results_dir)){
    saveRDS(
      tm,
      get_result_path(results_dir, "tm_doc.rds")
    )
  }
  
  # write data to Excel file
  wb <- openxlsx::createWorkbook()
  
  ## Add worksheets
  openxlsx::addWorksheet(wb, "trace-matrix")
  
  ## Header Styles
  hs1 <- openxlsx::createStyle(fgFill = "#800080", halign = "CENTER", textDecoration = "italic",
                               border = "Bottom")
  
  # set sheet name as parameter
  sheetName <- "trace-matrix"
  
  # function to adjust column widths
  width_adjust_func(wb, tm, sheetName)
  
  # write data to worksheet
  openxlsx::writeData(wb,
                      sheet = "trace-matrix", x = tm,
                      startCol = 1, startRow = 1, 
                      colNames = TRUE, 
                      headerStyle = hs1,
                      withFilter = FALSE
  )
  
  # set up file path
  write_file_path <- get_result_path(results_dir, "tm_doc.xlsx")
  
  # write workbook
  if(!is.null(results_dir)){
    openxlsx::saveWorkbook(wb, write_file_path, overwrite = TRUE)
  }
  
  
  message(glue::glue("traceability matrix for {pkg_name} successful"))
  
}

check_tm_possible <- function(pkg_source_path){
    r_dir <- file.path(pkg_source_path, "R")
    if(!fs::dir_exists(r_dir)){
      stop("an R directory is needed to create a traceability matrix")
    }
}

#' Get all exported functions and map them to R script where they are defined
#'
#' @param exports_df data.frame with a column, named `exported_function`,
#'   containing the names of all exported functions. Can also have other columns
#'   (which will be returned unmodified).
#' @param pkg_source_path a file path pointing to an unpacked/untarred package directory
#'
#' @return A data.frame with the columns `exported_function` and `code_script`.
#'
#' @keywords internal
map_functions_to_scripts <- function(exports_df, pkg_source_path, verbose){
  
  # Search for scripts functions are defined in
  funcs_df <- get_toplevel_assignments(pkg_source_path)
  
  if(nrow(funcs_df) == 0){
    # Triggering this means an R/ directory exists, but no assignments were found.
    msg <- paste(
      "No top level assignments were found in the R/ directory for package",
      glue::glue("`{basename(pkg_source_path)}`."),
      "Exports cannot be linked to their defining script."
    )
    warning(msg)
  }
  
  exports_df <- dplyr::left_join(exports_df, funcs_df, by = c("exported_function" = "func"))
  
  if (any(is.na(exports_df$code_script))) {
    if(isTRUE(verbose)) {
      missing_from_files <- exports_df$exported_function[is.na(exports_df$code_file)] %>%
        paste(collapse = "\n")
      message(glue::glue("The following exports were not found in R/ for {basename(pkg_source_path)}:\n{missing_from_files}\n\n"))
    }
  }
  
  return(exports_df)
}

#' list all package exports
#'
#'
#' @return data.frame, with one column `exported_function`, that can be passed
#'   to all downstream map_* helpers
#'
#' @keywords internal
get_exports <- function(pkg_source_path){
  # Get exports
  nsInfo <- pkgload::parse_ns_file(pkg_source_path)
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
    stop(glue::glue("No exports found in package {basename(pkg_source_path)}"))
  }
  
  return(tibble::tibble(exported_function = exports))
}


#' Remove specific symbols from vector of functions
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
#' This is primarily for getting all _functions_, but it also returns top-level
#' declarations, regardless of type. This is intentional, because we also want
#' to capture any global variables or anything else that could be potentially
#' exported by the package.
#'
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
    msg <- paste(
      "No sourceable R scripts were found in the R/ directory for package",
      glue::glue("`{basename(pkg_source_path)}`. Make sure this was expected.")
    )
    warning(msg)
    return(tibble::tibble(func = character(), code_script = character()))
  }
  
  pkg_functions <- purrr::map_dfr(r_files, function(r_file_i) {
    exprs <- tryCatch(parse(r_file_i), error = identity)
    if (inherits(exprs, "error")) {
      warning("Failed to parse ", r_file_i, ": ", conditionMessage(exprs))
      return(tibble::tibble(func = character(), code_script = character()))
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
      return(tibble::tibble(func = character(), code_script = character()))
    }
    return(tibble::tibble(
      func = function_names,
      code_script = rep(fs::path_rel(r_file_i, pkg_source_path), length(function_names))
    ))
  })
  # TODO: do we need to check if there are any funcs defined in multiple files?
  
  return(pkg_functions)
}

#' Map all Rd files to the functions they describe
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
    code_files_missing <- unique(docs_missing$code_file) %>% paste(collapse = ", ")
    message(glue::glue("In package `{basename(pkg_source_path)}`, the R scripts ({code_files_missing}) are missing documentation for the following exports: \n{exports_missing}"))
  }
  
  return(exports_df)
}

width_adjust_func <- function(wb, DF, sheetName) {
  # set to 2 to handle bold font
  width_adjuster <- 2
  # column widths based on values in the dataframe
  width_vec <-apply(DF, 2, function(x) max(nchar(as.character(x)) + width_adjuster, na.rm = TRUE))
  # width_vec <-apply(DF, 2, function(x) max(stringr::str_length(x)) + width_adjuster)
  
  # column widths based on the column header widths
  width_vec_header <- nchar(colnames(DF))  + width_adjuster
  # now use parallel max (like vectorized max) to capture the lengthiest value per column
  width_vec_max <- pmax(width_vec, width_vec_header)
  openxlsx::setColWidths(wb, sheet = sheetName, cols = 1:ncol(DF), widths = width_vec_max)
}

get_func_descriptions <- function(pkg_name){
  db <- tools::Rd_db(pkg_name)
  description <- lapply(db,function(x) {
    
    # tags <- tools:::RdTags(x) - replace to pass RCMD check
    tags <- lapply(x, attr, "Rd_tag")
    if("\\description" %in% tags){
      # return a crazy list of results
      #out <- x[which(tmp=="\\author")]
      # return something a little cleaner
      out <- paste(unlist(x[which(tags=="\\description")]),collapse="")
    }
    else
      out <- NULL
    invisible(out)
  })
  
  gsub("\n","",unlist(description)) # further cleanup
}

