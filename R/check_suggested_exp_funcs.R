#' Create items matched
#' 
#' @description create a df with functions that match exported functions from
#' a suggested package
#'  
#' @param extracted_functions - exported functions from the target package
#' @param suggested_exp_func - exported functions from a suggested package
#'
#' @keywords internal

create_items_matched <- function(extracted_functions, suggested_exp_func) {
  
  items_matched <- extracted_functions %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      matched = any(stringr::str_detect(suggested_function, 
                                        paste0("(", suggested_exp_func$package, 
                                               "::)?", 
                                               suggested_exp_func$exported_functions)))
    ) %>%
    dplyr::filter(matched) %>%
    dplyr::select(-matched)
  
  return(items_matched)
}

#' process items matched
#' 
#' @description create a df with functions that match exported functions from
#' a suggested package
#' 
#' @details This function extracts all the functions from the function body 
#' and filters them to keep only function calls
#' It also extracts all the valid function names, matches with the source package
#' and writes a message
#'  
#' @param items_matched - exported functions match the suggested package function
#' @param suggested_exp_func - exported functions from a suggested package
#'
#' @keywords internal
process_items_matched <- function(items_matched, suggested_exp_func) {
  
  # get all unique function names
  all_functions <- unique(suggested_exp_func$functions)
  
  # step 1 - extract function calls
  processed_items_int <- items_matched %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      function_calls = list(unique(unlist(
        stringr::str_extract_all(
          suggested_function,
          paste0("\\b(", paste(all_functions, collapse = "|"), ")\\b")
        )
      )))
    ) %>%
    tidyr::unnest(function_calls) %>%
    dplyr::filter(function_calls != "") %>% # Filter to keep non-empty function calls
    dplyr::filter(!grepl("\\(", function_calls)) %>% # Filter to exclude calls with parentheses
    dplyr::mutate(
      function_calls = gsub("[^a-zA-Z0-9_]", "", function_calls), # Remove non-alphanumeric characters
      is_assignment = sapply(function_calls, function(call) {
        # Caused by error in `grepl()`:
        # ! invalid regular expression '\b[data\b\s*(<-|=)', reason 'Missing ']''
        any(grepl(paste0("\\b", call, "\\b\\s*(<-|=)"), suggested_function, perl = TRUE))
      }),
      is_parameter = sapply(function_calls, function(call) {
        any(grepl(paste0("\\(", ".*\\b", call, "\\b", ".*\\)"), suggested_function, perl = TRUE)) &
          !any(grepl(paste0("\\b", call, "\\b\\s*(<-|=)"), suggested_function, perl = TRUE)) &
          !any(grepl(paste0("\\b", call, "\\b\\s*\\("), suggested_function, perl = TRUE))
      })
    ) %>%
    dplyr::ungroup()
  
  # Ensure is_assignment and is_parameter are logical vectors
  processed_items_int <- processed_items_int %>%
    dplyr::mutate(
      is_assignment = as.logical(is_assignment),
      is_parameter = as.logical(is_parameter)
    )
  
  # Filter out assignments
  processed_items_no_assignments <- processed_items_int %>%
    dplyr::filter(!is_assignment)
  
  # Filter out parameters
  processed_items_no_parameters <- processed_items_no_assignments %>%
    dplyr::filter(!is_parameter)
  
  # Remove the temporary columns
  processed_items_final <- processed_items_no_parameters %>%
    dplyr::select(-is_assignment, -is_parameter)
  
  # extract function names and set up targeted package and message
  processed_items <- processed_items_final %>%
    dplyr::mutate(
      suggested_function = stringr::str_extract(function_calls, "\\w+$"),  # Changed: Extract only the function names
      targeted_package = suggested_exp_func$package[match(function_calls, suggested_exp_func$functions)], 
      message = "Please check if the targeted package should be in Imports"
    ) %>%
    # filter(!is.na(source_package)) %>%
    dplyr::distinct(source, suggested_function, targeted_package, message) %>%
    dplyr::select(source, suggested_function, targeted_package, message)
  
  return(processed_items)
}

# Function to preprocess func_full_name and extract package, class, and generic
preprocess_func_full_name <- function(func_full_name) {
  # Split the func_full_name by "::" and "."
  parts <- strsplit(func_full_name, "::|\\.")[[1]]
  
  # Extract package, generic, and class
  package <- parts[1]
  generic <- parts[2]
  class <- parts[3]
  
  return(list(package = package, generic = generic, class = class))
}

#' function to preprocess func_full_name 
#' 
#' @description function to extract package, class, and generic
#'  
#' @param func_full_name - full name of the function 
#'
#' @keywords internal
preprocess_func_full_name <- function(func_full_name) {
  # Check if the func_full_name contains ":::"
  if (grepl(":::", func_full_name)) {
    
    # Split the func_full_name by "."
    parts <- strsplit(func_full_name, "\\.")[[1]]
    
    # Extract generic
    generic <- parts[1]
    
    # Extract class
    class <- paste(parts[-1], collapse = ".")
    
    # Extract package name from class
    class_parts <- strsplit(class, ":::", fixed = TRUE)[[1]]
    package <- class_parts[1]
    class <- paste(class_parts, collapse = ":::") 
    
    # Adjust generic if it contains "::"
    if (grepl("::", generic)) {  
      generic_parts <- strsplit(generic, "::")[[1]]
      generic <- generic_parts[2]  
    }
    
  } else {
    # Split the func_full_name by "::"
    parts <- strsplit(func_full_name, "::")[[1]]
    
    # Extract package name
    package <- parts[1]
    
    # Split the remaining part by "."
    remaining_parts <- strsplit(parts[2], "\\.")[[1]]
    
    # Extract generic and class
    generic <- remaining_parts[1]
    class <- paste(remaining_parts[-1], collapse = ".")
  }
  
  return(list(package = package, generic = generic, class = class))
}

#' function to get S3 method 
#' 
#' @description function to get S3 method from generic
#'  
#' @param generic - function generic
#' @param class - function class
#' @param package - package name 
#'
#' @keywords internal
get_s3_method <- function(generic, class, package) {
  # Construct the function name
  
  func_name <- paste0(generic, ".", class)
  
  # Check if the function is exported
  if (exists(func_name, envir = asNamespace(package), inherits = FALSE)) {
    return(get(func_name, envir = asNamespace(package)))
  } else {
    return(NULL)
  }
}

#' function to check value of ggproto
#' 
#' @description function to check if first argument inherits from any of the classes specified
#'  
#' @param x - ggproto functions from the target package
#'
#' @keywords internal
function_is_ggproto <- function(x) inherits(x, "ggproto")

#' function to check value of ggproto
#' 
#' @description function to check all classes of a ggproto function
#'  
#' @param value - ggproto functions from the target package
#'
#' @keywords internal
check_ggproto <- function(value) {
  any(class(value) %in% c("ggproto"))
}

#' function to extract ggproto methods
#' 
#' @description function to get all the methods of a ggproto function
#'  
#' @param obj - ggproto env from the target package
#'
#' @keywords internal
extract_ggproto_methods <- function(obj) {
  
  methods <- lapply(names(obj), function(method) {
    if (is.function(obj[[method]])) {
      paste(deparse(body(obj[[method]])), collapse = "\n")
    } else {
      NULL
    }
  })
  methods <- methods[!sapply(methods, is.null)]
  
  return(paste(methods, collapse = "\n\n"))
}

# Main function to get function details
get_function_details <- function(package_name, exp_func, pkg_source_path) {
  
  # Dynamically load the package
  if (!require(package_name, character.only = TRUE)) {
    stop(paste("Package", package_name, "could not be loaded"))
  }
  
  results <- data.frame(source = character(),
                        function_type = character(),
                        suggested_function = character(), 
                        where = character(), 
                        stringsAsFactors = FALSE)
  
  for (i in seq_along(exp_func$exported_function)) {
    
    func_name <- exp_func$exported_function[i]
    func_type <- exp_func$function_type[i]  # Get the function type for the current function
    func_full_name <- paste0(package_name, "::", func_name)
    
    # Preprocess func_full_name to extract package, generic, and class
    preprocessed <- preprocess_func_full_name(func_full_name)
    package <- preprocessed$package
    generic <- preprocessed$generic
    class <- preprocessed$class
    
    
    # Check for S3 methods
    if (isTRUE(func_type == "S3 function")) {
      
      value <- get_s3_method(generic, class, package)
      
      if (!is.null(value)) {
        func_body <- tryCatch(body(value), error = function(e) NULL)
        suggested_function <- paste(deparse(func_body), collapse = "\n")
      } else {
        suggested_function <- paste("'", 
                                    generic, 
                                    ".", class, 
                                    "' unable to parse from:", package, "'", 
                                    sep = "")
      }
      
      results <- rbind(results, data.frame(
        source = func_name,
        function_type = "S3",
        suggested_function = suggested_function,
        where = package_name,
        stringsAsFactors = FALSE
      ))
    } else {
      # Evaluate the function or variable to see if it is numeric
      value <- tryCatch(eval(parse(text = func_full_name)), error = function(e) NULL)
      if (is.numeric(value)) {
        # 1) Check if function is a numeric variable
        func_body <- as.character(value)
        results <- rbind(results, data.frame(
          source = func_name,
          function_type = "numeric",
          suggested_function = paste(deparse(func_body), collapse = "\n"),
          where = package_name,
          stringsAsFactors = FALSE
        ))
      } else if (class(value)[1] %in% c("rlang_fake_data_pronoun")) {
        # check if this is an rlang re-export
        results <- rbind(results, data.frame(
          source = func_name,
          function_type = "rlang tidy eval",
          suggested_function = "check rlang as this is a re-export",
          where = package_name,
          stringsAsFactors = FALSE
        )) 
      } else if (check_ggproto(value)) {
        # check if this is a ggproto object
        if (function_is_ggproto(value)) {
          func_body <- tryCatch({
            extract_ggproto_methods(value)
          }, error = function(e) NULL)
          results <- rbind(results, data.frame(
            source = func_name,
            function_type = "ggproto",
            suggested_function = if (!is.null(func_body)) paste(deparse(func_body), collapse = "\n") else "Function body not found",
            where = package_name,
            stringsAsFactors = FALSE
          ))
        }  
      } else {
        # 2) Check for S4 methods
        if (methods::isGeneric(func_name)) {
          s4_methods <- capture.output(methods::showMethods(func_name, where = topenv()))
          method_signatures <- s4_methods[grepl("^[[:space:]]*[[:alnum:]]+=", s4_methods)]
          method_definitions_vector <- character()
          
          for (method in method_signatures) {
            all_methods <- tryCatch(methods::findMethods(func_name, where = asNamespace(package_name)), error = function(e) NULL)
            method_definitions <- all_methods@.Data
            
            if (!is.null(method_definitions)) {
              for (method_def in method_definitions) {
                method_definitions_vector <- deparse(method_def@.Data)
                results <- rbind(results, data.frame(
                  source = paste(func_name, sep = "."),
                  function_type = "S4",
                  suggested_function = paste(method_definitions_vector, collapse = "\n"),
                  where = package_name,
                  stringsAsFactors = FALSE
                ))
              }
            } else {
              method_message <- paste0("No method details found for method: ", method)
              results <- rbind(results, data.frame(
                source = paste(func_name, sep = "."),
                function_type = "S4",
                suggested_function = paste(method_message),
                where = package_name,
                stringsAsFactors = FALSE
              ))
            }
          }
        } else {
          warns <- list()
          errs <- list()
          
          # 3) Check for regular functions
          func_body <- tryCatch(
            withCallingHandlers(
              expr = body(eval(parse(text = func_full_name))),
              
              # Handle the warnings.
              warning = function(w) {
                if (grepl("argument is not a function", w$message)) {
                  results <<- rbind(results, data.frame(
                    source = func_name,
                    function_type = "Unknown",
                    suggested_function = "Function type is unknown",
                    where = package_name,
                    stringsAsFactors = FALSE
                  ))
                  invokeRestart("muffleWarning")
                } else {
                  warns <<- c(warns, list(w))
                }
              }
            ),
            
            # Handle the errors.
            error = function(e) {
              errs <<- c(errs, list(e))
              NULL
            }
          )
          
          if (!is.null(func_body)) {
            results <- rbind(results, data.frame(
              source = func_name,
              function_type = "regular",
              suggested_function = paste(deparse(func_body), collapse = "\n"),
              where = package_name,
              stringsAsFactors = FALSE
            ))
          } else {
            results <- rbind(results, data.frame(
              source = func_name,
              function_type = "regular",
              suggested_function = "Function body not found",
              where = package_name,
              stringsAsFactors = FALSE
            ))
          }
        }
      }
    }
  }
  
  return(results)
}

#' get regular function bodies
#' 
#' @description create a tibble with regular function bodies
#'
#' @param pkg_name - name of the package   
#' @param func_name - current function
#'
#' @keywords internal
get_regular_function_body <- function(pkg_name, func_name) {
  # Load the package
  if (!require(pkg_name, character.only = TRUE)) {
    stop(paste("Package", pkg_name, "could not be loaded"))
  }
  
  # Initialize lists to store function names and function bodies
  function_names <- c()
  function_bodies <- c()
  
  # Use getAnywhere to find the function
  func_details <- getAnywhere(func_name)
  
  # Check if the function is found in the specified package
  if (length(func_details$objs) > 0 && any(grepl(pkg_name, func_details$where))) {
    func_body <- paste(deparse(func_details$objs[[1]]), collapse = "\n")
    function_names <- c(function_names, func_name)
    function_bodies <- c(function_bodies, func_body)
  }
  
  # Create a dataframe with function names and function bodies
  func_df <- dplyr::tibble(source = function_names, 
                            suggested_function = function_bodies,
                            where = pkg_name)
  
  return(func_df)
}


#' Function to check suggested exported functions
#'
#' @description This function checks the exported functions of target package
#' against the exported functions of Suggested dependencies to see if any 
#' Suggested packages should be in Imports in the DESCRIPTION file
#'
#' @param pkg_name - name of the target package   
#' @param pkg_source_path - source of the target package 
#' @param suggested_deps - dependencies in Suggests
#'
#' @return - data frame with results of Suggests check
#' @export
#'
check_suggested_exp_funcs <- function(pkg_name, 
                                      pkg_source_path, 
                                      suggested_deps) {
  
  # Input checks
  checkmate::assert_string(pkg_name)
  checkmate::assert_string(pkg_source_path)
  checkmate::assert_class(suggested_deps, "data.frame")
  
  assert_non_empty_string <- function(x, var.name = deparse(substitute(x))) {
    checkmate::assert_string(x, min.chars = 1, .var.name = var.name)
    if (x == "" || x == " ") {
      stop(sprintf("%s cannot be an empty string", var.name))
    }
  }
  
  assert_non_empty_string(pkg_name)
  assert_non_empty_string(pkg_source_path)
  
  # check if there are any dependencies to be checked
  if (nrow(suggested_deps) != 0) {
    # Check if the package source path contains an R folder
    exp_possible <- contains_r_folder(pkg_source_path)
    
    if (exp_possible == TRUE) {
      # Get the exported functions from the package source path
      exp_func <- get_exports(pkg_source_path)
      
      func_df <- get_function_details(pkg_name, 
                                      exp_func,
                                      pkg_source_path
      )
      
      # browser()
      
      # Get the suggested exported functions
      suggested_exp_func <- get_suggested_exp_funcs(suggested_deps)
      # browser()
      # Function to test if each column has no values
      test_no_values <- function(df) {
        sapply(df, function(column) all(is.na(column)))
      }
      
      # test for no values
      no_values_test <- test_no_values(suggested_exp_func)
      
      if (!all(no_values_test)) {
        
        # check if func_df is empty of values    
        is_empty <- func_df %>% 
          dplyr::summarise_all(~ all(is.na(.) | . == " ")) %>% 
          unlist() %>% all()
        
        if (is_empty) {
          message(glue::glue("No exported functions from source package {pkg_name}"))
          suggested_matched_functions <- data.frame(
            source = pkg_name,
            suggested_function = NA,
            targeted_package = NA,
            message = glue::glue("No exported functions from source package {pkg_name}")
          ) 
        } else {
          
          items_matched <- create_items_matched(func_df, 
                                                suggested_exp_func)
          
          
          suggested_matched_functions <- 
            process_items_matched(items_matched, 
                                  suggested_exp_func)
        }
        
      } else {
        message("No Suggested packages in the DESCRIPTION file")
        suggested_matched_functions <- data.frame(
          source = pkg_name,
          suggested_function = NA,
          targeted_package = NA,
          message = "No Suggested packages in the DESCRIPTION file"
        ) 
      }
    } else {
      message("No R folder found in the package source path")
      suggested_matched_functions <- data.frame(
        source = pkg_name,
        suggested_function = NA,
        targeted_package = NA,
        message = "No R folder found in the package source path"
      )  
      
    }
    
    # check if suggested_matched functions is empty of values    
    is_empty <- suggested_matched_functions %>% 
      dplyr::summarise_all(~ all(is.na(.) | . == " ")) %>% 
      unlist() %>% all()
    
    if (is_empty) {
      message("No exported functions from Suggested packages in the DESCRIPTION file")
      suggested_matched_functions <- data.frame(
        source = pkg_name,
        suggested_function = NA,
        targeted_package = NA,
        message = "No exported functions from Suggested packages in the DESCRIPTION file"
      ) 
    }
  } else {
    message("No Imports or Suggested packages in the DESCRIPTION file")
    suggested_matched_functions <- data.frame(
      source = pkg_name,
      suggested_function = NA,
      targeted_package = NA,
      message = "No Imports or Suggested packages in the DESCRIPTION file"
    ) 
  }
  
  
  return(suggested_matched_functions)
}