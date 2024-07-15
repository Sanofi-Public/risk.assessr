library(here)
library(rlang)
library(sanofi.risk.metric)

# Restart R
# Rebuild the package
# #Load all

# processing of vignettes
# when running bg_proc_tar, the following message may appear:
#  Run R CMD build without --no-build-vignettes to re-create
#  go to sanofi.risk.metric::assess_pkg() line 32
#  comment out build_args = "--no-build-vignettes"
#  Document package
#  Install package
#  Load All

# for eWise need to set tmpDir to own directory rather than
# eWise default
# run set_temp_dir_linux() in the inst folder
#
# file paths in line 19 and line 100 are absolute to avoid known R package problems with maintaining
# reliable package paths - when setting up a local repo, these need to be set for local use 
# 
##############################################
# Processing of individual tar files
# choose the tar file for processing
# 
# choose method for uploading file
# 1) file.choose to choose your tar file manually
# file_path <- file.choose()
# 2) write input path for tar file
# file_path <- file.path("/home/u1004798/github-helper-repos/data/tar-files/tidyverse/purrr-1.0.2.tar.gz")
# 
##############################################
# Processing of multiple tar files
# data tunneling method - copy tar files to folder input_bg_data
# 
##############################################
# Run bg_proc_tar as a background job
# 
# Click Source with Down arrow
# 
# Choose ` Source as Background job`
# 
# when sourcing as background job,
# set working directory to project root folder e.g. sanofi.risk.metric not inst
# set copy job results to 'To results object in global environment' to have audit of job execution

# background process main function ----

bg_proc_tar <- function(tar_file, input_tar_path, out_dir) {
  
  input_path <- input_tar_path
  
  file_path <- paste0(input_path,"/", {{tar_file}})
  
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  # get initial working directory
  initial_wd <- getwd()
  
  start_time <- proc.time() 
  
  # get the name of the file
  pkg <- basename(file_path)
  
  # load file path into the data path variable
  dp <- file_path 
  
  # check where vignettes are in the package
  bv_result <- sanofi.risk.metric::contains_vignette_folder(dp)
  
  #set up build vignettes for R CMD check
  if (bv_result == FALSE) {
    build_vignettes <- TRUE
  } else {
    build_vignettes <- FALSE
  }
  
  rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)
  
  pkg_disp <- stringr::str_extract(pkg, "[^_]+")
  
  pkg_source_path <- 
    sanofi.risk.assessment.tar::unpack_tarball(dp, pkg_disp)
  
  package_installed <- 
    sanofi.risk.assessment.tar::install_package_local(pkg_source_path, 
                                                      pkg_disp) 
  
  if (package_installed == TRUE ) {	
    
    # get home directory
    
    home <- setwd(find.package("sanofi.risk.metric"))
    
    message("home is ", home)
    
    # set working directory back to initial directory
    here::here(initial_wd)
    
    # set up current package
    current_package <- "sanofi.risk.metric"
    
    # check if risk score data exists and set up path to risk score data
    riskscore_data_list <- 
      sanofi.risk.metric::check_riskscore_data_internal()
    
    riskscore_data_path <- riskscore_data_list$riskscore_data_path
    
    message("data path is ", riskscore_data_path)
    
    riskscore_data_exists <- riskscore_data_list$riskscore_data_exists
    
    message("data path exists ", riskscore_data_exists)
    
    # assess package for risk
    assess_package <- 
      sanofi.risk.metric::assess_pkg(pkg,
                                     dp,
                                     pkg_source_path,
                                     out_dir,
                                     riskscore_data_path,
                                     riskscore_data_exists,
                                     overwrite = TRUE,
                                     rcmdcheck_args
      ) 
    
    # calculate elapsed time
    end_time <- proc.time()  
    
    elapsed_time <- end_time - start_time 
    
    message("Elapsed time (seconds) is ", elapsed_time["elapsed"])
    
  } else {
    message("Package not installed")
  }
  
}

# check directory ----


setdir_linux <- function() {
  # get the user name
  user <- Sys.info()["user"]
  
  # create input dir based on user name
  itp <- paste0("/home/", 
                user, 
                "/github-helper-repos/data/input_bg_data")
  
  input_tar_path <- file.path(itp)
  
  # create output path for results
  out_path <- paste0("/home/", 
                     user, 
                     "/github-helper-repos/sanofi.risk.metric")
  
  message("out path is ", out_path)
  
  out_dir <- file.path(out_path, "inst/results")
  
  message("out_dir is ", out_dir)
  
  sanofi.risk.metric::check_dir(out_dir)
  
  # create tmp dir based on user name
  tmp_dir <- paste0("/home/", user, "/tmp")
  
  # normalize the path
  tmp_dir <- normalizePath(tmp_dir)
  
  # check if the temp directory doesn't exist
  if (!dir.exists(tmp_dir)) {
    message("temp directory exists: ", dir.exists(tmp_dir))
    # create directory with all the files 
    # in the current directory have all permissions type
    dir.create(tmp_dir, showWarnings = TRUE, recursive = FALSE, mode = "0777")
  }
  
  # check directory existence
  message("temp directory exists: ", dir.exists(tmp_dir))
  
  # set R session temp directory
  Sys.setenv(R_SESSION_TMPDIR = tmp_dir)
  message("R_SESSION_TMPDIR is ", Sys.getenv("R_SESSION_TMPDIR"))
  
  # set Linux session temp directory
  unix:::set_tempdir(tmp_dir)
  message("tempdir is ", tempdir())
  
  input_output_list <- list(
    input_tar_path = input_tar_path,
    out_dir =  out_dir)
  
  return(input_output_list)
}

setdir_windows <- function() {
  
  #get Windows home directory
  home_dir <- Sys.getenv()['HOME']
  
  # set input tar file path
  itp <- paste0(home_dir, "/input_bg_data")
  
  # convert to file path
  input_tar_path <- file.path(itp)
  
  # check directory exists
  sanofi.risk.metric::check_dir(input_tar_path)
  
  # set output file path  
  otp <- paste0(home_dir, "/bp-art-sanofi.risk.metric/inst/results")
  
  # convert to file path
  out_dir <- file.path(otp) 
  
  # check directory exists
  sanofi.risk.metric::check_dir(out_dir)
  
  input_output_list <- list(
    input_tar_path = input_tar_path,
    out_dir =  out_dir)
  
  return(input_output_list)
}

# background process setup ----

bg_proc_tar_setup <- function() {
  
  # create path to tar files
  if (checkmate::check_os("linux") == TRUE) {
    list_of_packages <- c("unix")
    new_packages <- list_of_packages[!(list_of_packages %in% installed.packages()[,"Package"])]
    if(length(new_packages)) {
      install.packages(new_packages)
    }
    library({{list_of_packages}}, character.only = TRUE)
    
    input_output_list <- setdir_linux()
  }  else if (checkmate::check_os("windows")  == TRUE) {
    input_output_list <- setdir_windows()
  }
  
  input_tar_path <- input_output_list$input_tar_path
  out_dir <- input_output_list$out_dir
  
  # check directory existence
  sanofi.risk.metric::check_dir(input_tar_path)
  sanofi.risk.metric::check_dir(out_dir)
  
  # create list of tar files 
  input_tar_list <- list.files(path = input_tar_path, 
                               pattern = "*.tar.gz$", 
                               full.names = FALSE)
  
  bpt_list <- list(
    input_tar_path = input_tar_path,
    input_tar_list = input_tar_list,
    out_dir =  out_dir 
  )
  return(bpt_list)
}

bpt_list <- bg_proc_tar_setup()

# create list with 1 tar file
# input_tar_list <- list.files(path = input_tar_path, pattern = "dplyr_1.0.1.tar.gz$", full.names = FALSE)

# apply list vector to function
purrr::pmap(list(bpt_list$input_tar_list, 
                 bpt_list$input_tar_path, 
                 bpt_list$out_dir), 
            bg_proc_tar)
