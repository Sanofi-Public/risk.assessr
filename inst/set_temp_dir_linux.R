# set tmp folder for installing packages locally

Sys.setenv(R_SESSION_TMPDIR = "/home/u1004798/tmp")
Sys.getenv("R_SESSION_TMPDIR") 
# 
unix:::set_tempdir("/home/u1004798/tmp")
# [1] "/home/u1004798/tmp"
tempdir()
