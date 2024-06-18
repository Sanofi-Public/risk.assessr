#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>
#include <R_ext/Visibility.h>

/* .Call calls */
extern SEXP C_setTempDir(SEXP);

static const R_CallMethodDef CallEntries[] = {
  {"C_setTempDir",       (DL_FUNC) &C_setTempDir,       1},
  {NULL, NULL, 0}
};

attribute_visible void R_init_unix(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}