library(sanofi.risk.assessment.tar)
library(sanofi.risk.metric)

# choose the tar file for processing
file_path <- file.choose()

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
  home <- setwd(Sys.getenv("HOME"))
  
  home
  
  
  out_dir <- file.path(home, "github-helper-repos/sanofi.risk.metric/inst/results")
  
  out_dir
  
  # set up current package
  current_package <- "sanofi.risk.metric"
  
  # check if risk score data exists and set up path to risk score data
  riskscore_data_list <- 
    sanofi.risk.assessment.tar::check_riskscore_data(current_package)
  
  riskscore_data_path <- riskscore_data_list$riskscore_data_path
  
  # data written to different data path
  # change to out_dir?
  riskscore_data_path
  #[1] "/home/u1004798/R/x86_64-pc-linux-gnu-library/4.1/sanofi.risk.metric/extdata/riskdata_results.csv"
  
  riskscore_data_exists <- riskscore_data_list$riskscore_data_exists
  
  # assess package for risk
  assess_package <- 
    sanofi.risk.metric::assess_pkg(pkg,
                                   dp,
                                   pkg_source_path,
                                   out_dir,
                                   overwrite = TRUE,
                                   riskscore_data_path,
                                   riskscore_data_exists
    ) 
  
  # calculate elapsed time
  end_time <- proc.time()  
  
  elapsed_time <- end_time - start_time 
  
  message("Elapsed time (seconds) is ", elapsed_time["elapsed"])
  
} else {
  message("Package not installed")
}	 