
<!-- README.md is generated from README.Rmd. Please edit that file -->

# risk.assessr <a><img src="man/figures/logo.png" align="right" height="138" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/Sanofi-GitHub/bp-art-risk.assessr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Sanofi-GitHub/bp-art-risk.assessr/actions/workflows/R-CMD-check.yaml)
[![test-coverage](https://github.com/Sanofi-GitHub/bp-art-risk.assessr/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/Sanofi-GitHub/bp-art-sanofi.risk.assessr/actions/workflows/test-coverage.yaml)
![Coverage](https://img.shields.io/badge/coverage-95%25-brightgreen.svg)


<!-- badges: end -->

# risk.assessr

# Overview

Open-source projects can improve how clinical trials work by making them more transparent and collaborative to solve problems and define a common standard in the clinical trial ecosystem.

Successful open source packages such as `admiral`, `tern` and as well as collaborative initiatives (`Pharmaverse`, `Transcellerate`, `Phuse`) could greatly standardize and harmonize processes for different laboratories as well as allowing for faster deliverable for submission.

However, open source raises inherent challenges in terms of:

| Aspect         | Security                                                | Legal                                                 | Operational                                                                                                          |
|----------------|---------------------------------------------------------|-------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| Considerations | \- Vulnerability issues <br> - Confidentiality concerns | \- Is the source code under a non-permissive license? | \- Is the package maintained by an active community? <br> - Does it follow good practices? <br> - Is it sustainable? |


We need to use open-source projects responsibly and safely by adhering to best practices and ensure the reliability of the package being utilized for FDA submission.


Our goal is to establish a comprehensive and reliable package that helps to determine a package’s reliability and security in terms of maintenance, documentation, and dependencies.

This package is designed to carry out a risk assessment for internal or open source R packages.

This packages can:

-   Actively run `R CMD check` (a series of technical checks that ensure examples run\
    successfully, tests pass, the packages are compatible with other packages on CRAN)

-   Provide some answers as to why certain steps are not passing

-   Actively run `test coverage` checks to ensure tests pass and calculate unit test coverage

-   create a `traceability matrix` that matches the function / test descriptions to tests\
    and match to test pass/fail and associated test coverage

-   Can be executed in several environments (different OS, wise) and with different R\
    versions

-   Can work with package versions


-   Provide a overall risk score



It calculates risk metrics such as:

**Core metrics** - includes R command check, unit test coverage and
composite coverage of dependencies

**Documentation metrics** - availability of vignettes, news tracking,
example(s), return object description for exported functions, and type
of license



# Description

This package has the following steps in the workflow to assess the risk
of an R package using riskmetric:

Finding a source for package information locally (**renv.lock** file or
installed local package **tar.gz** file Assessing the package under
validation criteria and scoring the assessment criteria `assess_pkg()`

The results are assembled in a dataset of validation criteria containing
an overall risk score for each package as shown in the example below.

This package executes the following tasks:

1.  upload the source package(`tar.gz` file) locally

2.  Unpack the `tar.gz` file

3.  Install the package locally

4.  Run code coverage

5.  Run a traceability matrix

6.  Run R CMD check

7.  Run risk assessment metrics using default weighting



# Installation

## from github repository

- Create a `Personal Access Token` (PAT) on `github`

  - Log into your `github` account
  - Go to the token settings URL using the [Token Settings
    URL](https://github.com/settings/tokens)

- Create a `.Renviron` file with your GITHUBTOKEN as:

<!-- -->

    # .Renviron
    GITHUBTOKEN=dfdxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxfdf

- restart R session
- You can install the package with:

<!-- -->

``` r
auth_token = Sys.getenv("GITHUBTOKEN")
devtools::install_github("Sanofi-GitHub/bp-art-risk.assessr", ref = "main", auth_token = auth_token)

```

## from CRAN

``` r
install.package("risk.assessr")
```

# Assessing package

To assess your package, do the following steps:

1 - save your package as a `tar.gz` file

- This can be done in `RStudio` -\> `Build Tab` -\> `More` -\>
  `Build Source Package`

2 - Run the following code sample and use `file.choose` to load your
`tar.gz` file

``` r
library(risk.assessr)

# for local tar.gz R package
risk_assess_package <- risk.assessr::risk_assess_pkg()
```

OR

To assess Open source package on CRAN/Bioconductor

```
library(risk.assessr)
# The function will retrieve the latest version of the package if no version is provided

results <- sanofi.risk.assessr::assess_pkg_r_package(package_name, version=NA)
```


# Result: Metrics and Risk assessment

``` r
# to check the overall riskmetric results
risk_assess_package$results
```

``` r

$pkg_name
[1] "here"

$pkg_version
[1] "1.0.1"

$pkg_source_path
  C:/Users/I0555262/AppData/Local/Temp/RtmpOc7aOz/temp_file_5a30450d2c4c/here 
"C:/Users/I0555262/AppData/Local/Temp/RtmpOc7aOz/temp_file_5a30450d2c4c/here" 

$date_time
[1] "2024-10-29 12:08:35"

$executor
[1] ""

$sysname
[1] "Windows"

$version
[1] "build 19045"

$release
[1] "10 x64"

$machine
[1] "x86-64"

$comments
[1] " "

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

$dependencies
$dependencies$imports
$dependencies$imports$rprojroot
[1] "2.0.4"


$dependencies$suggests
$dependencies$suggests$conflicted
[1] "None"

$dependencies$suggests$covr
[1] "3.6.4"

$dependencies$suggests$fs
[1] "1.6.3"

$dependencies$suggests$knitr
[1] "None"

$dependencies$suggests$palmerpenguins
[1] "None"

$dependencies$suggests$plyr
[1] "None"

$dependencies$suggests$readr
[1] "None"

$dependencies$suggests$rlang
[1] "1.1.3"

$dependencies$suggests$rmarkdown
[1] "None"

$dependencies$suggests$testthat
[1] "3.2.1.1"

$dependencies$suggests$uuid
[1] "None"

$dependencies$suggests$withr
[1] "3.0.1"


$dep_score
[1] 0.04742587

$rev_deps
  [1] "adepro"                     "APCalign"                   "archetyper"                
  [4] "ARUtools"                   "AzureAppInsights"           "bdc"                       
  [7] "BeeBDC"                     "blastula"                   "boxr"                      
 [10] "bscui"                      "cache"                      "cape"                      
 [13] "cbcTools"                   "ciTools"                    "clockify"                  
 [16] "CohortCharacteristics"      "CohortConstructor"          "CohortSymmetry"            
 [19] "cpsvote"                    "cricketdata"                "crosstalkr"                
 [22] "denguedatahub"              "DescrTab2"                  "designit"                  
 [25] "did"                        "diffEnrich"                 "DrugUtilisation"           
 [28] "dtrackr"                    "dyn.log"                    "EIEntropy"                 
 [31] "elaborator"                 "emayili"                    "EpiNow2"                   
 [34] "filecacher"                 "flourishcharts"             "flow"                      
 [37] "folders"                    "formods"                    "funspotr"                  
 [40] "fusen"                      "gghdx"                      "ggseg"                     
 [43] "ghclass"                    "GIMMEgVAR"                  "GISSB"                     
 [46] "gitignore"                  "golem"                      "graphicalMCP"              
 [49] "gtfsrouter"                 "Guerry"                     "heddlr"                    
 [52] "heplots"                    "hkdatasets"                 "IncidencePrevalence"       
 [55] "isotracer"                  "ixplorer"                   "justifier"                 
 [58] "k5"                         "kindisperse"                "logitr"                    
 [61] "logrx"                      "longsurr"                   "lterdatasampler"           
 [64] "mailmerge"                  "maraca"                     "marginaleffects"           
 [67] "metabolic"                  "metR"                       "midfieldr"                 
 [70] "MiscMetabar"                "mlr3spatiotempcv"           "morphemepiece"             
 [73] "naijR"                      "naniar"                     "nascaR.data"               
 [76] "nestedLogit"                "nettskjemar"                "OlinkAnalyze"              
 [79] "omopgenerics"               "OmopSketch"                 "OmopViewer"                
 [82] "OptimalGoldstandardDesigns" "organizr"                   "PatientProfiles"           
 [85] "pharmr"                     "phdcocktail"                "phsmethods"                
 [88] "popstudy"                   "precommit"                  "projects"                  
 [91] "PUMP"                       "r4lineups"                  "RAINBOWR"                  
 [94] "rang"                       "rdfp"                       "REDCapCAST"                
 [97] "regions"                    "reticulate"                 "retroharmonize"            
[100] "ReviewR"                    "rfold"                      "rjtools"                   
[103] "rnassqs"                    "rsf"                        "rUM"                       
[106] "rworkflows"                 "salesforcer"                "schtools"                  
[109] "SHAPforxgboost"             "smdi"                       "socialmixr"                
[112] "Spectran"                   "stRoke"                     "styler"                    
[115] "tcplfit2"                   "tfrmtbuilder"               "tfruns"                    
[118] "tibble"                     "tidychangepoint"            "tidyxl"                    
[121] "toxEval"                    "tsgc"                       "UKB.COVID19"               
[124] "unpivotr"                   "upstartr"                   "validateIt"                
[127] "vcdExtra"                   "vegawidget"                 "vembedr"                   
[130] "weed"                       "wither"                     "x3ptools"                  
[133] "xpose"                      "yum"                       

$revdep_score
[1] 0.9721276

$overall_risk_score
[1] 0.2963372

$risk_profile
[1] "Medium"
```

# Check the RCMD check results

``` r
risk_assess_package$check_list$res_check
```

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


# Traceability Matrix

``` r
risk_assess_package$tm
```

    # A tibble: 4 × 5
      exported_function code_script  documentation description                   coverage_percent
      <chr>             <chr>        <chr>         <chr>                                    <dbl>
    1 dr_here           R/dr_here.R  dr_here.Rd    "dr_here() shows a message t…            100  
    2 here              R/here.R     here.Rd       "here() uses a reasonable he…            100  
    3 i_am              R/i_am.R     i_am.Rd       "Add a call to here::i_am(\"…             95.8
    4 set_here          R/set_here.R set_here.Rd   "html<a href='https://www.ti…            100



# Current/Future directions

- Experimental analysis to define overall risk profile
- Open source database with `risk.assessr` data on package and on internal environment


# Acknowledgements

The project is inspired by the
[`riskmetric`](https://github.com/pharmaR/riskmetric) package and the
[`mpn.scorecard`](https://github.com/metrumresearchgroup/mpn.scorecard)
package and draws on some of their ideas and functions.

