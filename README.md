
<!-- README.md is generated from README.Rmd. Please edit that file -->

# risk.assessr <a><img src="man/figures/logo.png" align="right" height="138" /></a>

<!-- badges: start -->

![R-CMD-check](https://img.shields.io/badge/Test%20coverage-Passing-brightgreen.svg)
![Coverage](https://img.shields.io/badge/R%20CMD%20check-Passing-brightgreen.svg)
[<img src="http://pharmaverse.org/shields/risk.assessr.svg">](https://pharmaverse.org)
![Coverage](https://img.shields.io/badge/coverage-94%25-brightgreen.svg)
<!-- badges: end -->

# Overview

risk.assessr helps in the initial determining of a package’s reliability and
security in terms of maintenance, documentation, and dependencies.

This package is designed to carry out a risk assessment of R packages at
the beginning of the validation process (either internal or open source).

It calculates risk metrics such as:

**Core metrics** - includes R command check, unit test coverage and
composite coverage of dependencies

**Documentation metrics** - availability of vignettes, news tracking,
example(s), return object description for exported functions, and type
of license

**Dependency Metrics** - package dependencies and reverse dependencies

It also calculates a:

**Traceability matrix** - matching the function / test descriptions to
tests and match to test pass/fail

# Description

This package executes the following tasks:

1.  upload the source package(`tar.gz` file)

2.  Unpack the `tar.gz` file

3.  Install the package locally

4.  Run code coverage

5.  Run a traceability matrix

6.  Run R CMD check

7.  Run risk assessment metrics using default or user defined weighting

# Notes

This package fixes a number of errors in `pharmaR/riskmetric`

1.  running R CMD check and code coverage with locally installed
    packages
2.  user defined weighting works
3.  `Suggests` added to checking dependencies
4.  `assess_dependencies` and `assess_reverse_dependencies` has sigmoid
    point increased
5.  `assess_dependencies` has value range changed to fit in with other
    scoring metrics


# Installation

- Create a `Personal Access Token` (PAT) on `github`

  - Log into your `github` account
  - Go to the token settings URL using the [Token Settings
    URL](https://github.com/settings/tokens)
    - (do not forget to add the SSH `Sanofi-Public` authorization)

- Create a `.Renviron` file with your GITHUBTOKEN as:

<!-- -->

    # .Renviron
    GITHUBTOKEN=dfdxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxfdf

- restart R session
- You can install the package with:

<!-- -->

    auth_token = Sys.getenv("GITHUBTOKEN")
    devtools::install_github("Sanofi-Public/risk.assessr", ref = "main", auth_token = auth_token)
    
    
# Usage

## Assessing your own package

To assess your package, do the following steps:

1 - save your package as a `tar.gz` file

- This can be done in `RStudio` -\> `Build Tab` -\> `More` -\>
  `Build Source Package`

2 - Run the following code sample by loading or add path parameter to your
`tar.gz` package source code

``` r
# for local tar.gz R package
risk_assess_package <- risk_assess_pkg()

risk_assess_package <- risk_assess_pkg(path/to/your/package)
```

## Assessing from local renv.lock file

This function processes `renv.lock` to produce risk metric data for each package.

``` r
# for local renv.lock file

risk_assess_package <- risk_assess_pkg(path/to/your/package)
```

Note: This process can be very time-consuming and is recommended to be performed as a batch job or within a GitHub Action.


## Assessing Open source R package on CRAN or bioconductor

To check a source code package from `CRAN` or `bioconductor`, run the following code:

``` r
risk_assess_package <- assess_pkg_r_package(package_name, package_version)
```


# Metrics and Risk assessment


``` r
# Metadata

$pkg_name
[1] "here"

$pkg_version
[1] "1.0.1"

$pkg_source_path
  C:/Users/xxxx/AppData/Local/Temp/Rtmp4A0ht7/temp_file_8bec8fd299c/here 
"C:/Users/xxxx/AppData/Local/Temp/Rtmp4A0ht7/temp_file_8bec8fd299c/here" 

$date_time
[1] "2025-02-19 14:25:39"

$executor
[1] ""

$sysname
[1] "Windows"

$version
[1] "build 22631"

$release
[1] "10 x64"

$machine
[1] "x86-64"

$comments
[1] " "

``` 

``` r
# Documentation metric

$has_bug_reports_url
[1] 1

$license
[1] 1

$has_examples
[1] 1

$has_maintainer
[1] 1

$size_codebase
[1] 0.4680851

$has_news
[1] 1

$has_source_control
[1] 1

$has_vignettes
[1] 1

$has_website
[1] 1

$news_current
[1] 1

$export_help
[1] 1

$export_calc
[1] 0.6791787

$check
[1] 0

$covr
[1] 0.9867

$license_name
[1] "MIT + file LICENSE"
``` 

``` r
# Dependencies

$dependencies
$dependencies$imports
$dependencies$imports$rprojroot
[1] "2.0.4"


$dependencies$suggests
$dependencies$suggests$conflicted
[1] "1.2.0"

$dependencies$suggests$covr
[1] "3.6.4"

$dependencies$suggests$fs
[1] "1.6.3"

$dependencies$suggests$knitr
[1] "1.48"

$dependencies$suggests$palmerpenguins
[1] "0.1.1"

$dependencies$suggests$plyr
[1] "1.8.9"

$dependencies$suggests$readr
[1] "2.1.5"

$dependencies$suggests$rlang
[1] "1.1.3"

$dependencies$suggests$rmarkdown
[1] "2.28"

$dependencies$suggests$testthat
[1] "3.2.1.1"

$dependencies$suggests$uuid
[1] "1.2-1"

$dependencies$suggests$withr
[1] "3.0.1"

$dep_score
[1] 0.04742587
``` 

``` r
# $suggested_deps

$suggested_deps
# A tibble: 3 × 4
  source suggested_function targeted_package message                                                  
  <chr>  <chr>                         <dbl> <chr>                                                    
1 here   0                                 0 Please check if the targeted package should be in Imports
2 here   f                                 0 Please check if the targeted package should be in Imports
3 i_am   0                                 0 Please check if the targeted package should be in Imports
``` 

``` r
# reverse dependencies
$rev_deps
  [1] "adepro"                  "APCalign"                "archetyper"              "ARUtools"               
  [5] "AzureAppInsights"        "bdc"                     "BeeBDC"                  "blastula"               
  [9] "boxr"                    "bscui"                   "bsitar"                  "cache"                  
 [13] "cape"                    "cbcTools"                "ciTools"                 "clockify"               
 [17] "CohortCharacteristics"   "CohortConstructor"       "CohortSymmetry"          "cpsvote"                
 [21] "cricketdata"             "crosstalkr"              "denguedatahub"           "DescrTab2"              
 [25] "designit"                "did"                     "diffEnrich"              "diseasystore"           
 [29] "DrugExposureDiagnostics" "DrugUtilisation"         "dtrackr"                 "dyn.log"                
 [33] "EIEntropy"               "elaborator"              "emayili"                 "EpiNow2"                
 [37] "filecacher"              "flourishcharts"          "flow"                    "folders"                
 [41] "formods"                 "froggeR"                 "fromhere"                "funspotr"               
 [45] "fusen"                   "gghdx"                   "ggseg"                   "ghclass"                
 [49] "GIMMEgVAR"               "GISSB"                   "gitignore"               "golem"                  
 [53] "graphicalMCP"            "gtfsrouter"              "Guerry"                  "heddlr"                 
 [57] "heplots"                 "hkdatasets"              "IncidencePrevalence"     "isotracer"              
 [61] "ixplorer"                "jetty"                   "justifier"               "k5"                     
 [65] "kindisperse"             "logitr"                  "logrx"                   "longsurr"               
 [69] "lterdatasampler"         "mailmerge"               "maraca"                  "marginaleffects"        
 [73] "metabolic"               "metR"                    "midfieldr"               "MiscMetabar"            
 [77] "mlr3spatiotempcv"        "morphemepiece"           "naijR"                   "naniar"                 
 [81] "nestedLogit"             "nettskjemar"             "omopgenerics"            "OmopSketch"             
 [85] "OmopViewer"              "organizr"                "PatientProfiles"         "pharmr"                 
 [89] "phdcocktail"             "PhenotypeR"              "phsmethods"              "popstudy"               
 [93] "precommit"               "projects"                "PUMP"                    "r4lineups"              
 [97] "RAINBOWR"                "rang"                    "ratlas"                  "rdfp"                   
[101] "REDCapCAST"              "regions"                 "reticulate"              "retroharmonize"         
[105] "ReviewR"                 "rfold"                   "rjtools"                 "rnassqs"                
[109] "rsf"                     "rUM"                     "rworkflows"              "salesforcer"            
[113] "SCDB"                    "schtools"                "SHAPforxgboost"          "shiny2docker"           
[117] "smdi"                    "socialmixr"              "spanishoddata"           "Spectran"               
[121] "srppp"                   "stRoke"                  "styler"                  "tatooheene"             
[125] "tcplfit2"                "tfrmtbuilder"            "tfruns"                  "tibble"                 
[129] "tidychangepoint"         "tidyprompt"              "tidyxl"                  "toxEval"                
[133] "tsgc"                    "tugboat"                 "UKB.COVID19"             "unpivotr"               
[137] "upstartr"                "validateIt"              "vcdExtra"                "vegawidget"             
[141] "vembedr"                 "weed"                    "wither"                  "x3ptools"               
[145] "xpose"                   "yum"                    

$revdep_score
[1] 0.9782352
``` 

``` r
# Authorship


$author
$author$maintainer
[1] "Kirill Müller <krlmlr+r@mailbox.org> [aut, cre] (<https://orcid.org/0000-0002-1416-3412>)"

$author$funder
[1] "No package foundation found"

$author$authors
[1] "Kirill Müller <krlmlr+r@mailbox.org> [aut, cre] (<https://orcid.org/0000-0002-1416-3412>)"
[2] "Jennifer Bryan <jenny@rstudio.com> [ctb] (<https://orcid.org/0000-0002-6983-2759>)"       
``` 

``` r

# hosting

$host
$host$github_links
[1] "https://github.com/r-lib/here"

$host$cran_links
[1] "https://cran.r-project.org/src/contrib/here_1.0.1.tar.gz"

$host$internal_links
NULL

$host$bioconductor_links
[1] "No Bioconductor link found"
``` 

``` r
# Github data

$github_data
$github_data$created_at
[1] "2016-07-19T14:47:19Z"

$github_data$stars
[1] 417

$github_data$forks
[1] 43

$github_data$date
[1] "2025-02-19"

$github_data$recent_commits_count
[1] 0
``` 

``` r
# version_info

$version_info
$version_info$available_version
[1] "0.1"   "1.0.0" "1.0.1"

$version_info$last_version
[1] "1.0.1"
``` 
``` r
# CRAN download

$download
$download$total_download
[1] 9900000

$download$last_month_download
[1] 338000
``` 
``` r
# Risk

$overall_risk_score
[1] 0.2962086

$risk_profile
[1] "Medium"

```

# Check the RCMD check results

``` r

risk_assess_package$check_list$res_check
```

## R CMD check results

    risk_assess_package$check_list$res_check
    ── R CMD check results ─────────────────────────────────────────────────────────── here 1.0.1 ────
    Duration: 46.9s

    0 errors ✔ | 0 warnings ✔ | 0 notes ✔
    > 
    > # to check the RCMD check score
    > risk_assess_package$check_list$check_score
    [1] 1

# Check the test coverage results

``` r

risk_assess_package$covr_list
```

# Test coverage results

    risk_assess_package$covr_list
    $total_cov
    [1] 0.9867

    $res_cov
    $res_cov$name
    [1] "here-1.0.1"

    $res_cov$coverage
    $res_cov$coverage$filecoverage
         R/aaa.R  R/dr_here.R     R/here.R     R/i_am.R R/set_here.R      R/zzz.R 
          100.00       100.00       100.00        95.83       100.00       100.00 

    $res_cov$coverage$totalcoverage
    [1] 98.67


    $res_cov$errors
    [1] NA

    $res_cov$notes
    [1] NA

# Check the traceability matrix

``` r
risk_assess_package$tm
```

# Traceability Matrix

    # A tibble: 4 × 5
      exported_function function_type code_script  documentation description                   coverage_percent
      <chr>             <chr>         <chr>        <chr>         <chr>                                    <dbl>
    1 dr_here           regular       R/dr_here.R  dr_here.Rd    "dr_here() shows a message t…            100  
    2 here              regular       R/here.R     here.Rd       "here() uses a reasonable he…            100  
    3 i_am              regular       R/i_am.R     i_am.Rd       "Add a call to here::i_am(\"…             95.8
    4 set_here          regular       R/set_here.R set_here.Rd   "html<a href='https://www.ti…            100


# Current/Future directions

- Github action to call risk.assessr data (from R package/renv managed project)
- More fine grained features for test coverage report
- Produce database of risk assessment for Sanofi packages


# Acknowledgements

The project is inspired by the
[`riskmetric`](https://github.com/pharmaR/riskmetric) package and the
[`mpn.scorecard`](https://github.com/metrumresearchgroup/mpn.scorecard)
package and draws on some of their ideas and functions.
