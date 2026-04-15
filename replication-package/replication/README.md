# Data and Code for: Self-Targeting in U.S. Transfer Programs

# Data download information
- Please refer to replication tracker.
 
---
contributors:
  - Charlie Rafkin (UC Berkeley)
  - Adam Solomon (MIT)
  - Evan J. Soltas (Princeton University)
---

## Overview

The code in this replication package constructs the analysis file from the listed data sources using Stata. `code/run_all.do` runs all of the code to generate the data for the 34 figures and 20 tables in the paper. The replicator should expect the code to run for about 14 hours.

## Data Availability and Provenance Statements

The paper uses Panel Study of Income Dynamics (PSID) data obtained from the UMich Survey Research Center. PSID data cannot, under their terms of use, be included in these replication files. The Survey Research Center instead allows them to be posted at ICPSR, which we have done here: https://doi.org/10.3886/ICPSR303531.V1. Users may also wish to download raw PSID data files here: https://simba.isr.umich.edu/data/data.aspx. 

The paper also uses data obtained from IPUMS (Ruggles et al, 2017). IPUMS-CPS does not currently provide the ability to store or reference custom extracts, but allows for redistribution for the purpose of replication. The archive contains the extracted data, codebook in the folder "data/cps".

We commit to preserving the data and code for a period of five years following the publication of the paper, including data files that we cannot make publicly available. We also commit to provide reasonable assistance to requests for clarification and replication.

### Statement about Rights

- [X] I certify that the author(s) of the manuscript have legitimate access to and permission to use the data used in this manuscript. 
- [X] I certify that the author(s) of the manuscript have documented permission to redistribute/publish the data contained within this replication package.

### Summary of Availability

- [ ] All data **are** publicly available.
- [X] Some data **cannot be made** publicly available.
- [ ] **No data can be made** publicly available.

Proprietary data used in analysis have been removed from the replication package. 

## Dataset list

- Please refer to the `replication tracker`.

## Computational requirements

### Software Requirements

- Stata (code was last run with version 19.5)
  - `bspline` (as of 2021-08-21)
  - `ftools` (as of 2026-01-11)
  - `gtools` (as of 2022-12-05)
  - `ppmlhdfe` (as of 2023-09-07)
  - `statastates` (as of 2018-01-10)
  - The relevant commands for each package is downloaded and provided in the `packages` folder.
  - For `ebayes.ado`, which can be found in the `packages` folder, if the error `ebayes command not found` appears, please try copying the file to your personal `ado` folder. This can be found by the `sysdir` command in Stata.

### Controlled Randomness

- Random seed is set at:
  - Line 78-79 of code file `code/clean/psid/02_ebayes_lifetime_earnings`
  - Line 31-32 of code file `code/analyze/fig_A32`
  - Line 44-45 of code file `code/clean/psid/03_merge_psid_reshape_lifetime_earnings`

### Memory, Runtime, Storage Requirements

#### Summary

Approximate time needed to reproduce the analyses on a standard 2025 desktop machine:
- 8-24 hours

Approximate storage space needed:
- 2 GB - 25 GB

#### Details

The code was last run on a **Intel(R) Xeon(R) Gold 6146 CPU @ 3.20GHz 3.19 GHz (2 processors) with 1.5TB of installed memory (RAM)**.

## Description of programs/code

- Code in `code/clean` will extract and reformat all relevant datasets used in analyses.
  - If running the files individually, please follow the order in `code/run_all.do` (i.e., files that are ran before a given file must be ran before running said file).
- Code in `code/analysis` generate all tables and figures in the main body of the article. Each program called from `run_all.do` identifies the table or figure it creates (e.g., `05_table5.do`).  The names of output files corresponding to tables/figures can be found in the replication tracker.
- Code in `code/eligsim` will generate all tables and figures  in the online appendix. The program `programs/03_appendix/main-appendix.do` will run them all. 
- The file `code/progs.do` collects sub-programs used frequently across code files.
- The file `code/settings.do` sets the relevant filepaths used in all data cleaning and analyses code files.
- The file `code/simplescheme.scheme` sets the formatting schemes for figures.
- The files `code/stata-tex.do` and `table_from_tpl.py` set the formatting for tables.

## Instructions to Replicators

- Edit `code/settings.do` to adjust the default path
- Download the data files referenced above. Each should be stored in the prepared subdirectories of `data/`, in the format that you download them in.
- Run `code/run_all.do` to run all steps in sequence.

## List of tables and programs

Please refer to the `replication tracker` for more details.

## References

David Autor and David Dorn. "The Growth of Low Skill Service Jobs and the Polarization of the U.S. Labor Market." American Economic Review, 103(5), 1553-1597, 2013. [Crosswalks for occ1970_occ1990dd.dta, occ2000_occ1990dd.dta, and occ2010_occ1990dd.dta.]

Department of Housing and Urban Development. ""Prior HHS Poverty Guidelines and Federal Register References," 2025.

Economic Research Service (ERS), U.S. Department of Agriculture (USDA). SNAP Distribution Schedule Database, SNAP Policy Data Sets.

Jeroen Weesie, 1999. "MMERGE: Stata module: Safer and easier to use variant of merge," Statistical Software Components S420201, Boston College Department of Economics, revised 26 Feb 2002.

Mauricio Caceres Bravo, 2018. "GTOOLS: Stata module to provide a fast implementation of common group commands," Statistical Software Components S458514, Boston College Department of Economics, revised 05 Dec 2022.

Mead Over, 2024. "GRC1LEG2: Stata module to combine multiple graphs with a single common legend," Statistical Software Components S459360, Boston College Department of Economics.

Panel Study of Income Dynamics, public use dataset. Produced and distributed by the Survey Research Center, Institute for Social Research, University of Michigan, Ann Arbor, MI (2025). Files available for download: https://doi.org/10.3886/ICPSR303531.V1.

Roger Newson, 2000. "BSPLINE: Stata modules to compute B-splines parameterized by their values at reference points," Statistical Software Components S411701, Boston College Department of Economics, revised 21 Aug 2022.

Sarah Flood, Miriam King, Renae Rodgers, Steven Ruggles, J. Robert Warren, Daniel Backman, Annie Chen, Grace Cooper, Stephanie Richards, Megan Schouweiler, and Michael Westberry. IPUMS CPS: Version 12.0 [dataset]. Minneapolis, MN: IPUMS, 2024. https://doi.org/10.18128/D030.V12.0

Sergio Correia, 2016. "FTOOLS: Stata module to provide alternatives to common Stata commands optimized for large datasets," Statistical Software Components S458213, Boston College Department of Economics, revised 11 Jan 2026.

Sergio Correia & Matthew P. Seay, 2023. "require: Package dependencies for reproducible research," Papers 2309.11058, arXiv.org, revised Apr 2024.

Sergio Correia & Noah Constantine, 2014. "REGHDFE: Stata module to perform linear or instrumental-variable regression absorbing any number of high-dimensional fixed effects," Statistical Software Components S457874, Boston College Department of Economics, revised 11 Jan 2026.

Sergio Correia & Paulo Guimaraes & Thomas Zylkin, 2019. "PPMLHDFE: Stata module for Poisson pseudo-likelihood regression with multiple levels of fixed effects," Statistical Software Components S458622, Boston College Department of Economics, revised 07 Sep 2023.

TRIM3 project website, trim3.urban.org, downloaded on 4/3/2025.

US Health and Human Services. ""Prior HHS Poverty Guidelines and Federal Register References," 2025.

William L. Schpero, 2016. "STATASTATES: Stata module to add US state identifiers to dataset," Statistical Software Components S458205, Boston College Department of Economics, revised 10 Jan 2018.

---

