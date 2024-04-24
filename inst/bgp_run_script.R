library(rstudioapi)

# create path to script file

# get the user name
user <- Sys.info()["user"]

# create input dir based on user name
ip <- paste0("/home/", 
              user, 
              "/github-helper-repos/sanofi.risk.metric/inst")

input_path <- file.path(ip)

script_path <- paste0(input_path, "/bg_proc_tar.R")

# create path to working directory

wd <- paste0("/home/", 
             user, 
             "/github-helper-repos/sanofi.risk.metric")

jobRunScript(
  path = script_path,
  name = NULL,
  encoding = "unknown",
  workingDir = wd,
  importEnv = FALSE,
  exportEnv = "bgpt_results_output"
)
