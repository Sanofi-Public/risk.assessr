library(here)
library(rlang)
library(unix)
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

bg_proc_tar <- function(tar_file) {
  
  file_path <- paste0("/home/u1004798/github-helper-repos/data/input_bg_data/", {{tar_file}})
  
  
  # get initial working directory
  initial_wd <- getwd()
  
  start_time <- proc.time() 
  
  # get the name of the file
  pkg <- basename(file_path)
  
  # load file path into the data path variable
  dp <- file_path 
  
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
    
    out_path <- paste0("/home/u1004798/github-helper-repos/sanofi.risk.metric")
    
    out_dir <- file.path(out_path, "inst/results")
    
    message("out_dir is ", out_dir)
    
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
    
    browser()
    build_vignettes <- TRUE
    
    rcmdcheck_args <- sanofi.risk.metric::setup_rcmdcheck_args(build_vignettes)
    
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

# create path to tar files
Sys.getenv("R_SESSION_TMPDIR") 
tempdir()

input_tar_path <- file.path("/home/u1004798/github-helper-repos/data/input_bg_data")

# create list of tar files 
input_tar_list <- list.files(path = input_tar_path, pattern = "*.tar.gz$", full.names = FALSE)


# create list with 1 tar file
# input_tar_list <- list.files(path = input_tar_path, pattern = "dplyr_1.0.1.tar.gz$", full.names = FALSE)

# apply list vector to function
purrr::map(input_tar_list, bg_proc_tar)

