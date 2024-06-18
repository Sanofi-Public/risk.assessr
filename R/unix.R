#' Set temp dir Linux
#'
#' @param path path to temporary directory
#'
#' @export
#'
#' @useDynLib sanofi.risk.metric C_setTempDir
set_tempdir <- function(path) {
  invisible(.Call(C_setTempDir, path.expand(path)))
}
