#' Parse DCF of description file
#'
#' @param path pkg_ref path
#' 
#' @export
#'
parse_dcf_dependencies <- function(path){
  dcf <- read.dcf(file.path(path, "DESCRIPTION"), all=TRUE)
  dcf <- dcf[colnames(dcf) %in% c("LinkingTo","Imports", "Depends", "Suggests")]
  dcf <- sapply(dcf, strsplit, strsplit, split=",")
  dcf <- lapply(dcf, trimws)
  deps <- data.frame(package=unlist(dcf),
                     type=rep(names(dcf), sapply(dcf, length)),
                     stringsAsFactors = FALSE,
                     row.names = NULL)
  deps <- remove_base_packages(deps)
  return(deps)
}
#' Helper function to remove base and recommended packages
#'
#' @param df Data frame of dependencies of a package.
#' 
#' @export
#'
remove_base_packages <- function(df){
  inst <- utils::available.packages()
  inst_priority <- inst[,"Priority"]
  inst_is_base_rec <- !is.na(inst_priority) & inst_priority %in% c("base", "recommended")
  base_rec_pkgs <- inst[inst_is_base_rec, "Package"]
  
  deps <- df[!grepl("^R\\s\\(.+\\)", df$package) | df$package %in% base_rec_pkgs, ] ##Remove "R" dependencies as well as base and recomended
  return(deps)
}
#' Score a package for dependencies
#'
#' Calculates a regularized score based on the number of dependencies a package has.
#' Convert the number of dependencies \code{NROW(x)} into a validation
#' score [0,1] \deqn{ 1 / (1 + exp(-0.5 * (NROW(x) + 19))) }
#' 
#' removed - 1 from the formula e.g. \deqn{ 1 - 1 / (1 + exp(NROW(x)- 19)) } to
#' reverse the return value e.g. 0 - low; 1 - high
#' 
#' The scoring function is the classic logistic curve \deqn{ / (1 + exp(-k(x-x[0])) }
#' \eqn{x = NROW(x)}, sigmoid midpoint is 20 reverse dependencies, ie. \eqn{x[0] = 19},
#' and logistic growth rate of \eqn{k = 0.5}.
#'
#' \deqn{ 1 / (1 + exp(NROW(x)- 19)) }
#'
#' @param x number of dependencies
#'
#' @return numeric value between \code{0} (low number of  dependencies) and
#'   \code{1} (high number of dependencies)
#'
#' @export
#' 
score_dependencies <- function(x) {
  1 /(1 + exp(-0.5 * (NROW(x) - 19)))
}

#' Calculate dependency score
#'
#' @param pkg_source_path package source path
#' 
#' @export
#' 
calc_dependencies <- function(pkg_source_path) {
  
  pkg_name <- basename(pkg_source_path)
  
  message(glue::glue("running package dependencies for {pkg_name}"))
  
  deps <- sanofi.risk.assessr::parse_dcf_dependencies(pkg_source_path)
  
  dep_score <- sanofi.risk.assessr::score_dependencies(deps)
  
  deps_results <- list(
    deps = deps,
    dep_score = dep_score
  )
  
  message(glue::glue("package dependencies successful for {pkg_name}"))
  
  return(deps_results)
}

#' find reverse dependencies
#'
#' @param path pkg_ref path
#' 
#' @export
#'
find_reverse_dependencies <- function(path){
  rev_deps <- devtools::revdep(path,
                               dependencies = c("Depends", 
                                                "Imports", 
                                                "Suggests", 
                                                "LinkingTo"),
                               bioconductor = FALSE)
  return(rev_deps)
}

#' Scoring method for number of reverse dependencies a package has
#'
#' Score a package for the number of reverse dependencies it has; regularized
#' Convert the number of reverse dependencies \code{length(x)} into a validation
#' score [0,1] \deqn{ 1 / (1 + exp(-0.5 * (sqrt(length(x)) + sqrt(20)))) }
#'
#' The scoring function is the classic logistic curve \deqn{
#' 1 / (1 + exp(-k(x-x[0])) } with a square root scale for the number of reverse dependencies
#' \eqn{x = sqrt(length(x))}, sigmoid midpoint is 20 reverse dependencies, ie. \eqn{x[0] =
#' sqrt(15)}, and logistic growth rate of \eqn{k = 0.5}.
#'
#' \deqn{ 1 / (1 + -0.5 * exp(sqrt(length(x)) - sqrt(20))) }
#'
#' @param x number of dependencies
#' @return numeric value between \code{1} (high number of reverse dependencies) and
#'   \code{0} (low number of reverse dependencies)
#'
#' @export
#' 
score_reverse_dependencies <- function(x){
  1 / (1 + exp(-0.5 * (sqrt(length(x)) - sqrt(20))))
}  

#' Calculate reverse dependency score
#'
#' @param pkg_source_path package source path
#' 
#' @export

calc_reverse_dependencies <- function(pkg_source_path) {
  
  pkg_name <- basename(pkg_source_path)
  
  #extract package name without version to pass to the revdep function
  name <- stringr::str_extract(pkg_name, "[^_|-]+")
  
  message(glue::glue("running reverse dependencies for {pkg_name}"))
  
  rev_deps <- sanofi.risk.assessr::find_reverse_dependencies(name)
  
  revdep_score <- sanofi.risk.assessr::score_reverse_dependencies(rev_deps)
  
  message(glue::glue("reverse dependencies successful for {pkg_name}"))
  
  return(revdep_score)
}

#' Assess dependencies for sigmoid point
#' 
#' @param riskdata_results - path to riskdata_results toy dataset
#' 
#' @description This function calculates average number of dependencies to 
#' determine the dependency sigmoid point
#'
#' @return nested list with dependencies, Import count mean, 
#' and all dependency count and mean
#' 
#' @examples 
#' riskdata_results <- system.file("test-data/riskdata_results_slim.csv", 
#' package = "sanofi.risk.assessr")
#' 
#' sigmoid_example <- assess_dep_for_sigmoid(riskdata_results)
#' print(sigmoid_example$all_count_mean)
#'   
#' @export
#'

assess_dep_for_sigmoid <- function(riskdata_results) {
  
  # read in the results
  results <- read.csv(file.path(riskdata_results))
  
  # filter existing data from initial run
  results <- results |> 
    dplyr::filter(grepl("\\Initial", comments, ignore.case = FALSE))
  
  # convert NAs and NANs to zero
  results <- rapply( results, f=function(x) ifelse(is.nan(x),0,x), how="replace" )	  
  results <- rapply( results, f=function(x) ifelse(is.na(x),0,x), how="replace" )
  
  results <- results |> dplyr::select(pkg_name,
                                      pkg_version,
                                      dependencies
                                      )
  
  # both imp_count and mean produce same result
  results$imp_count <- stringr::str_count(results$dependencies, '#Imports')
  
  results$link_count <- stringr::str_count(results$dependencies, '#LinkingTo')
  
  results$sug_count <- stringr::str_count(results$dependencies, '#Suggests')
  
  imp_link_count_mean <- 
    results |> 
      dplyr::summarize(dplyr::across(imp_count:link_count, 
                                     mean, 
                                     na.rm= TRUE))
  
  imp_link_count_mean <- 
    imp_link_count_mean |> dplyr::mutate(
      mean_total = imp_count + link_count
    )  
  
  all_count_mean <- results |> 
    dplyr::summarize(dplyr::across(imp_count:sug_count, mean, na.rm= TRUE))
  
  all_count_mean <- 
    all_count_mean |> dplyr::mutate(
      mean_total = imp_count + link_count + sug_count
    )
  
  results_list <- list(
    results = results,
    imp_link_count_mean = imp_link_count_mean,
    all_count_mean = all_count_mean
  )
  
  return(results_list)
}  