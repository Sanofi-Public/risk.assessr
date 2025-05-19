# risk.assessr 2.0.0

## New Features

- **Author Metadata Expansion**:

  - Added `$author` section including `maintainer`, `funder`, and a full list of contributing authors with ORCID IDs and roles.

- **Hosting Metadata Extraction**:

  - New `$host` section includes GitHub and CRAN, Bioconductor and internal package

- **GitHub Repository**:

  - Added `$github_data` with:
    - `created_at`
    - `stars`
    - `forks`
    - `recent_commits_count`

- **CRAN download**:

  - Added `$download` with:
    - `total_download`
    - `last_month_download`

- **Package version**:

  - Added `$version_info` with:
    - `available_version`
    - `last_version`

- **Bioconductor compatibility**:

  - `assess_pkg_r_package()` function now fetches bioconductor source package
  
- **renv.lock processing**:

  - `risk_assess_pkg_lock_files()` function now processes `renv.lock` and `pak.lock` files
  
- **Suggested Dependency Analysis**:

  - Introduced `$suggested_deps` output as a tibble with `source`, `suggested_function`, `targeted_package`, and contextual `message`.

- **Traceability Matrix**:

  - now processes and reports on regular, S3, and S4 functions.

- **Package validation report**:

  - HTML report creation with interactive features for package validation

### Improvements

- **Structured Dependency Extraction**:

  - Dependencies are now returned as structured nested lists under `$dependencies$imports` and `$dependencies$suggests`, replacing the previous flat string format.
  
  - Each suggested package now includes installed version from `getsession()`
  - Added `$license_name` for readable license detection, e.g., `"MIT + file LICENSE"`
  - Added `$rev_deps` returning list reverse dependency 
  - risk_assess_pkg() now includes an optional parameter "path" for locally stored package
  - remove `httr2` and `tibble` dependencies

# risk.assessr 1.0.0

First package version inspired by `riskmetric`.

Package features include:

 - Run CMD, test coverage
 - Traceability Matrix
 - Metadata (Date, system, OS)
 - Quality extraction metrics (documentation, license, examples, vignettes)
 - `assess_pkg_r_package()` function fetches source code from CRAN






















  