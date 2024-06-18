#include <string.h>

#include <Rinternals.h>
#include <Rembedded.h>
#include <R_ext/Rdynload.h>

SEXP C_setTempDir(SEXP sName) {
  if (TYPEOF(sName) != STRSXP || LENGTH(sName) != 1)
    Rf_error("invalid path");
  R_TempDir = strdup(CHAR(STRING_ELT(sName, 0)));
  return sName;
}