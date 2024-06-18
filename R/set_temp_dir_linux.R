#' set temp dir Linux
#'
#' setup temp directory for Linux ----
#' 
#' @export
#'
set_temp_dir_linux <- function() {
  
  # get the user name
  user <- Sys.info()["user"]
  
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
  sanofi.risk.metric::set_tempdir(tmp_dir)
  message("tempdir is ", tempdir())
}
