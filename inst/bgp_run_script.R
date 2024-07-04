library(checkmate)
library(rstudioapi)

browser()
# create path to script file ----

# get the user name ----
user <- Sys.info()["user"]

# include directory creation?????

# create input dir based on user name ----



if (checkmate::check_os("linux") == TRUE) {
  
  list.of.packages <- c("unix")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)  
    
  ip <- paste0("/home/", 
               user, 
               "/github-helper-repos/sanofi.risk.metric/inst")
  
  input_path <- file.path(ip)

  sanofi.risk.metric::check_dir(input_path)  
    
  script_path <- paste0(input_path, "/bg_proc_tar.R")

  # create path to working directory ----
  
  wd <- paste0("/home/", 
               user, 
               "/github-helper-repos/sanofi.risk.metric")
  } else if (checkmate::check_os("windows")  == TRUE) {
  
    home_dir <- Sys.getenv()['HOME']
    
    ip <- paste0(home_dir, 
                 "/bp-art-sanofi.risk.metric/inst")
    
    input_path <- file.path(ip)
    
    sanofi.risk.metric::check_dir(input_path)
    
    script_path <- paste0(input_path, "/bg_proc_tar.R")
    
    script_path <- file.path(script_path)
    
    # create path to working directory ----
    
    wd <- paste0(home_dir,  
                 "/bp-art-sanofi.risk.metric")
    
    sanofi.risk.metric::check_dir(wd)
}


jobRunScript(
  path = script_path,
  name = NULL,
  encoding = "unknown",
  workingDir = wd,
  importEnv = FALSE,
  exportEnv = "bgpt_results_output"
)
