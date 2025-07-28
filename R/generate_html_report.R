#' Generate RCMD Check Metrics Section
#'
#' @description Generates the RCMD Check Metrics HTML table for the HTML report.
#'
#' @param assessment_results - input data
#'
#' @keywords internal
generate_rcmd_check_section <- function(assessment_results) {
  
  rcmd_check_message <- "RCMD Check score"
  
  rcmd_check_score <- assessment_results$check_list$check_score
  
  # Check if errors, warnings, and notes are character(0) and replace with the message
  errors <- assessment_results$check_list$res_check$errors
  if (length(errors) == 0) {
    errors <- "No errors"
  }
  
  warnings <- assessment_results$check_list$res_check$warnings
  if (length(warnings) == 0) {
    warnings <- "No warnings"
  }
  
  notes <- assessment_results$check_list$res_check$notes
  if (length(notes) == 0) {
    notes <- "No notes"
  }
  
  # Create a data frame for R CMD Check results
  rcmd_check_df <- data.frame(
    Message = rcmd_check_message,
    Score = rcmd_check_score,
    Errors = errors,
    Warnings = warnings,
    Notes = notes
  )
  
  return(rcmd_check_df)
}

#' Generate Risk Summary
#'
#' @description Generates the Risk Summary table for the HTML report.
#'
#' @param assessment_results - input data
#'
#' @keywords internal
generate_risk_summary <- function(assessment_results) {
  
  assessment_results$results$overall_risk_score <- 
    round(assessment_results$results$overall_risk_score, 2)
  
  risk_summary_table <- data.frame(
    Metric = c('Package', 'Version', 'Overall Risk Score', 'Risk Profile'),
    Value = c(
      assessment_results$results$pkg_name,
      assessment_results$results$pkg_version,
      assessment_results$results$overall_risk_score,
      assessment_results$results$risk_profile
    )
  )
  
  return(risk_summary_table)
}

#' Generate Risk Details
#'
#' @description Generates the Risk Details table for the HTML report.
#'
#' @param assessment_results - input data
#'
#' @keywords internal
generate_risk_details <- function(assessment_results) {
  
  # Helper function to replace NULL with "N/A"
  handle_null <- function(x) {
    if (is.null(x)) {
      return("N/A")
    } else {
      return(x)
    }
  }
  
  # Ensure covr is numeric before rounding
  assessment_results$results$covr <- 
    as.numeric(assessment_results$results$covr)
  assessment_results$results$covr <- 
    round(assessment_results$results$covr, 2)
  
  risk_details_table <- data.frame(
    Metric = c(
      'R CMD Check Score', 'Test Coverage Score', 'Date Time', 'Executor', 
      'OS Name', 'OS Release', 'OS Machine', 'R version'
    ),
    Value = c(
      handle_null(assessment_results$results$check),
      handle_null(assessment_results$results$covr),
      handle_null(assessment_results$results$date_time),
      handle_null(assessment_results$results$executor),
      handle_null(assessment_results$results$sysname),
      handle_null(assessment_results$results$release),
      handle_null(assessment_results$results$machine),
      handle_null(assessment_results$check_list$res_check$rversion)
    )
  )
  
  return(risk_details_table)
}

#' Generate file coverage df
#'
#' @description Generates file coverage df when errors list created.
#' 
#' @param file_names - file names
#' @param file_coverage - test coverage for files
#' @param errors - test coverage errors
#' @param notes - test coverage notes
#' 
#' @keywords internal
create_file_coverage_df <- function(file_names, file_coverage, errors, notes) {
  # Convert errors to a character string if it is a complex structure
  # browser()
  if (is.list(errors)) {
    errors <- sapply(errors, function(x) {
      if (is.null(x)) {
        return("N/A")
      } else if (is.data.frame(x)) {
        return(paste(capture.output(print(x)), collapse = "; "))
      } else if (is.list(x)) {
        return(paste(unlist(x), collapse = "; "))
      } else {
        return(as.character(x))
      }
    })
  }
  
  # Ensure the number of rows match
  max_len <- max(length(file_names), length(file_coverage), length(notes))
  
  # Extend lists to match the maximum length
  file_names <- c(file_names, rep("", max_len - length(file_names)))
  file_coverage <- c(file_coverage, rep(NA, max_len - length(file_coverage)))
  notes <- c(notes, rep("", max_len - length(notes)))
  errors <- rep(paste(errors, collapse = "; "), max_len)
  
  # Create the data frame
  file_coverage_df <- data.frame(
    File = file_names,
    Coverage = file_coverage,
    Errors = errors,
    Notes = notes,
    stringsAsFactors = FALSE
  )
  
  return(file_coverage_df)
}

#' Generate Coverage Section
#'
#' @description Generates the Coverage section for the HTML report.
#' 
#' @param assessment_results - input data
#' 
#' @keywords internal
generate_coverage_section <- function(assessment_results) {
  # browser()
  total_coverage <- assessment_results$covr_list$res_cov$coverage$totalcoverage
  file_coverage <- assessment_results$covr_list$res_cov$coverage$filecoverage
  
  # Extract file names from the attributes
  file_names <- attr(file_coverage, "dimnames")[[1]]
  
  # Handle errors and notes
  errors <- assessment_results$covr_list$res_cov$errors
  if (all(is.na(errors))) {
    errors <- "No test coverage errors"
  }
  
  notes <- assessment_results$covr_list$res_cov$notes
  if (all(is.na(notes))) {
    notes <- "No test coverage notes"
  }
  
  # Create a data frame for file coverage
  if (is.list(errors) && all(c("message", "srcref", "status", "stdout", "stderr", "parent_trace", "call", "procsrcref", "parent") %in% names(errors))) {
    # Create the file coverage data frame
    file_coverage_df <- create_file_coverage_df(file_names, file_coverage, errors, notes)
  } else {
    # Handle the case where errors does not have the expected structure
    file_coverage_df <- data.frame(
      Function = file_names,
      Coverage = file_coverage,
      Errors = errors,
      Notes = notes,
      stringsAsFactors = FALSE
    )
  }
  
  return(file_coverage_df)
}

#' Generate Doc Metrics Section
#'
#' @description Generates the documentation section for the HTML report.
#' 
#' @param assessment_results - input data
#' 
#' @keywords internal
generate_doc_metrics_section <- function(assessment_results) {
  
  # Extract the relevant elements from assessment_results
  doc_metrics <- data.frame(
      Metric = c(
        'Has Bug Reports URL', 'Has License', 'Has Examples', 'Has Maintainer',
        'Has News', 'Has Source Control', 'Has Vignettes',
        'Has Website', 'News Current', 'Export Help'
      ),
      Value = c(
        assessment_results$results$has_bug_reports_url,
        assessment_results$results$license,
        assessment_results$results$has_examples,
        assessment_results$results$has_maintainer,
        assessment_results$results$has_news,
        assessment_results$results$has_source_control,
        assessment_results$results$has_vignettes,
        assessment_results$results$has_website,
        assessment_results$results$news_current,
        assessment_results$results$export_help
      )
    )  
    
    doc_metrics$Value <- sapply(doc_metrics$Value, function(x) {
      if (x == 0) {
        return('Not Included')
      } else if (x == 1) {
        return('Included')
      } else {
        return(x)
      }
    })
    
  return(doc_metrics)
}

#' Generate Trace Matrix Section
#'
#' @description Generates the Trace Matrix section for the HTML report.
#' 
#' @param assessment_results - input data
#' 
#' @keywords internal
generate_trace_matrix_section <- function(assessment_results) {
    # browser()
  # Check if trace_matrix is empty
  total_coverage <- assessment_results$covr_list$res_cov$coverage$totalcoverage
  file_coverage <- assessment_results$covr_list$res_cov$coverage$filecoverage
  
  if (is.na(total_coverage) || (is.vector(file_coverage) && any(is.na(file_coverage)))) {
    trace_matrix <- data.frame(
      Exported_function = " ",
      Function_type = " ",
      Code_script = " ",
      Documentation = " ",
      Description = "Traceability matrix unsuccessful",
      Test_Coverage = " ",
      stringsAsFactors = FALSE
    )
  } else {
    trace_matrix <- data.frame(
      Exported_function = assessment_results$tm$exported_function,
      Function_type = assessment_results$tm$function_type,
      Code_script = assessment_results$tm$code_script,
      Documentation = assessment_results$tm$documentation,
      Description = assessment_results$tm$description,
      Test_Coverage = assessment_results$tm$coverage_percent,
      stringsAsFactors = FALSE
    )
    
    # remove re-exported functions and sort by Test Coverage
    trace_matrix <- trace_matrix |> 
        dplyr::filter(!is.na(`Code_script`) & `Code_script` != "") |> 
      dplyr::arrange(Test_Coverage)
    
  }
    
  return(trace_matrix)  
}

#' Generate Dependencies Section
#'
#' @description Generates the dependencies section for the HTML report.
#' 
#' @param assessment_results - input data
#' 
#' @keywords internal
generate_deps_section <- function(assessment_results) {
  
  # Extract dependencies from assessment_results
  dependencies <- assessment_results$results$dependencies
  dep_score <- assessment_results$results$dep_score
  
  dep_score <- 
    round(dep_score, 4)
  
  # Initialize empty lists to store package names, versions, types, and dep_score
  pkg_names <- c()
  pkg_versions <- c()
  pkg_types <- c()
  pkg_score <- c()
  
  # Process Imports
  if (!is.null(dependencies$imports)) {
    for (pkg in names(dependencies$imports)) {
      pkg_names <- c(pkg_names, pkg)
      pkg_versions <- c(pkg_versions, dependencies$imports[[pkg]])
      pkg_types <- c(pkg_types, "Imports")
    }
  }
  
  # Process Suggests
  if (!is.null(dependencies$suggests)) {
    for (pkg in names(dependencies$suggests)) {
      pkg_names <- c(pkg_names, pkg)
      pkg_versions <- c(pkg_versions, dependencies$suggests[[pkg]])
      pkg_types <- c(pkg_types, "Suggests")
    }
  }
  
  # Create a data frame
  deps_df <- data.frame(
    Package = pkg_names,
    Version = pkg_versions,
    Type = pkg_types,
    stringsAsFactors = FALSE
  )
  
  return(list(
    deps_df = deps_df,
    dep_score = dep_score 
  ))
}

#' Generate Reverse Dependencies Section
#'
#' @description Generates the reverse dependencies section for the HTML report.
#' 
#' @param assessment_results - input data
#' 
#' @keywords internal
generate_rev_deps_section <- function(assessment_results) {
  # Extract dependencies from assessment_results
  rev_deps <- assessment_results$results$rev_deps
  rev_deps_score <- assessment_results$results$revdep_score
  
  rev_deps_score <- 
    round(rev_deps_score, 4)
  
  # Convert the character vector to a data frame with one row per value
  rev_deps_df <- as.data.frame(rev_deps, 
                               stringsAsFactors = FALSE)
  
  # Rename the column 
  colnames(rev_deps_df) <- "Reverse_dependencies"
  
  # Create a summary data frame
  rev_deps_summary <- data.frame(
    rev_deps_score = rev_deps_score,
    rev_deps_no = nrow(rev_deps_df)
  )
  
  return(list(
    rev_deps_df = rev_deps_df,
    rev_deps_summary = rev_deps_summary
  ))
}

#' Generate HTML Report for Package Assessment
#'
#' @description Generates an HTML report for the package assessment results using rmarkdown.
#'
#' @param assessment_results List containing the results from risk_assess_pkg function.
#' @param output_dir Character string indicating the directory where the report will be saved. 
#'
#' @return Path to the generated HTML report.
#'
#' @examples
#' \dontrun{
#' assessment_results <- risk_assess_pkg()
#' generate_html_report(assessment_results, output_dir = "path/to/save/report")
#' }
#' @export
generate_html_report <- function(assessment_results, output_dir) {
  
  # Create the risk summary data
  risk_summary_output <- generate_risk_summary(assessment_results)
  
  # Create the risk summary data
  risk_details_output <- generate_risk_details(assessment_results)
  
  # Capture the output of generate_rcmd_check_section
  rcmd_check_output <- generate_rcmd_check_section(assessment_results)
  
  # Capture the output of generate_coverage_section
  coverage_output <- generate_coverage_section(assessment_results)
  
  # Capture the output of generate_doc_metrics_section
  doc_metrics_output <- generate_doc_metrics_section(assessment_results)
  
  # Capture the output of generate_deps_section
  deps_output <- generate_deps_section(assessment_results)
  
  # Capture the output of generate_rev_deps_section
  rev_deps_output <- generate_rev_deps_section(assessment_results)
  
  # Capture the output of generate_trace_matrix_section
  trace_matrix_output <- generate_trace_matrix_section(assessment_results)
  
  # Create a file name with pkg_name,version, and "risk_assessment.html"
  pkg_name <- assessment_results$results$pkg_name
  pkg_version <- assessment_results$results$pkg_version
  date_time <- assessment_results$results$date_time
  
  # set up report environment
  report_env <- new.env()
  report_env$pkg_name <- pkg_name
  report_env$pkg_version <- pkg_version
  report_env$risk_summary_output <- risk_summary_output
  report_env$risk_details_output <- risk_details_output
  report_env$rcmd_check_output  <- rcmd_check_output
  report_env$coverage_output  <- coverage_output
  report_env$doc_metrics_output  <- doc_metrics_output
  report_env$deps_df  <- deps_output$deps_df
  report_env$dep_score <- deps_output$dep_score
  report_env$rev_deps_df  <- rev_deps_output$rev_deps_df
  report_env$rev_deps_summary$rev_deps_no <- rev_deps_output$rev_deps_summary$rev_deps_no
  report_env$rev_deps_summary$rev_deps_score <- rev_deps_output$rev_deps_summary$rev_deps_score
  report_env$trace_matrix_output  <- trace_matrix_output
  
  if (fs::dir_exists(output_dir)) {
    output_file <- fs::path(output_dir, glue::glue("risk_report_{pkg_name}_{pkg_version}.html"))
    
    template_path <- system.file("report_templates", 
                                 "risk_report_template.Rmd", 
                                 package = "risk.assessr")
    
    # Render the R Markdown file to the output directory
    rmarkdown::render(template_path, 
                      output_file = output_file, 
                      envir = report_env)
  } else {
    message("The output directory does not exist.")
    return(NULL)
  }
  return(output_file)
}
