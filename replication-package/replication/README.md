# Self-Targeting in U.S. Transfer Programs

# Data download information
- Please refer to replication tracker.
 
---
contributors:
  - Charlie Rafkin
  - Adam Solomon
  - Evan J. Soltas
---

## Overview

The code in this replication package constructs the analysis file from the listed data sources using Stata. `code/run_all.do` runs all of the code to generate the data for the 34 figures and 20 tables in the paper. The replicator should expect the code to run for about 14 hours.

## Data Availability and Provenance Statements

The paper uses data obtained from IPUMS (Ruggles et al, 2017). IPUMS-CPS does not currently provide the ability to store or reference custom extracts, but allows for redistribution for the purpose of replication. The archive contains the extracted data, codebook in the folder "data/cps".

### Statement about Rights

- [X] I certify that the author(s) of the manuscript have legitimate access to and permission to use the data used in this manuscript. 
- [X] I certify that the author(s) of the manuscript have documented permission to redistribute/publish the data contained within this replication package.

### Summary of Availability

- [ ] All data **are** publicly available.
- [X] Some data **cannot be made** publicly available.
- [ ] **No data can be made** publicly available.

Proprietary data used in analysis have been removed from the replication package. Please refer to cover letter for more detail.

## Dataset list

- Please refer to the `replication tracker`.

## Computational requirements

### Software Requirements
- [ ] The replication package contains one or more programs to install all dependencies and set up the necessary directory structure. [HIGHLY RECOMMENDED]

- Stata (code was last run with version 19)
  - `bspline` (as of 2021-08-21)
  - `gtools` (as of 2022-12-05)
  - `ppmlhdfe` (as of 2023-09-07)
  - `statastates` (as of 2018-01-10)
  - The relevant commands for each package is downloaded and provided in the `packages` folder.
  - For `ebayes.ado`, which can be found in the `packages` folder, if the error `ebayes command not found` appears, please try copying the file to your personal `ado` folder. This can be found by the `sysdir` command in Stata.

### Controlled Randomness

- [X] Random seed is set at:
  - Line 78 of code file `code/clean/psid/02_ebayes_lifetime_earnings`
  - Line 31-32 of code file `code/analyze/fig_A32`
  - Line 44-45 of code file `code/analyze/03_merge_psid_reshape_lifetime_earnings`
- [ ] No Pseudo random generator is used in the analysis described here.

### Memory, Runtime, Storage Requirements

#### Summary

Approximate time needed to reproduce the analyses on a standard (CURRENT YEAR) desktop machine:

- [ ] <10 minutes
- [ ] 10-60 minutes
- [ ] 1-2 hours
- [ ] 2-8 hours
- [ ] 8-24 hours
- [ ] 1-3 days
- [ ] 3-14 days
- [ ] > 14 days

Approximate storage space needed:

- [ ] < 25 MBytes
- [ ] 25 MB - 250 MB
- [ ] 250 MB - 2 GB
- [ ] 2 GB - 25 GB
- [ ] 25 GB - 250 GB
- [ ] > 250 GB

- [ ] Not feasible to run on a desktop machine, as described below.

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


| Figure/Table #    | Program                        | Line Number | Output file                                                        | Note                            |
|-------------------|--------------------------------|-------------|--------------------------------------------------------------------|---------------------------------|
| Table 1           | 02_analysis/table1.do          | 649         | summarystats.csv                                                   ||
| Table 2           | 02_analysis/table2and3.do      | 15          | table2.csv                                                         ||
| Table 3           | 02_analysis/table2and3.do      | 145         | table3.csv                                                         ||
| Figure 1, Panel A | analyze/fig_1ab_A23ab_A28ab.do | 649         | figures/participation_reg.csv; figures/eligregs_appear_2_c_no3.pdf | Program generates other figures not included in the paper |
| Figure 1, Panel B | analyze/fig_1ab_A23ab_A28ab.do | 591         | figures/participation_reg.csv; figures/eligregs_appear_2_eq_no.pdf | Program generates other figures not included in the paper |
| Figure 1, Panel C | analyze/fig_1c.do              | 213            | figures/participation_reg_within.csv; figures/eligregs_between_within_lifetime.pdf ||
| Figure 1, Panel D | analyze/fig_1d.do              | 206            | figures/participation_reg_mu.csv; figures/participation_reg_mu.pdf ||
| Figure 2 	    | analyze/fig_2_A23d.do          | 210            | figures/participation_reg_cex.csv; figures/eligregs_psid_cex.pdf | Program generates other figures not included in the paper |
| Appendix Figure 1 | analyze/fig_A1.do          | 136            | figures/participation_reg_ui_wc_ss.csv; figures/participation_reg_ui_wc_ss.pdf ||
| Appendix Figure 2, Panel A | analyze/fig_A2ab.do          | 256            | figures/participation_reg_robustness11.csv; figures/eligregs_robustness_11_c.pdf ||
| Appendix Figure 2, Panel B | analyze/fig_A2ab.do          | 256            | figures/participation_reg_robustness11.csv; figures/eligregs_robustness_11_li.pdf ||
| Appendix Figure 3 | analyze/fig_A3.do          | 98           | figures/friedman_binscatter.pdf ||
| Appendix Figure 4 | analyze/fig_A4.do          | 141         | fgiures/friedman_binscatter.pdf ||
| Appendix Figure 5 | analyze/fig_A5.do          | 181          | figures/participation_reg_robustness8.csv; figures/eligregs_robustness_8_c.pdf||
| Appendix Figure 6, Panel A | analyze/fig_A6ab.do          | 299            | figures/participation_reg_robustness11.csv; figures/eligregs_appear_2_c_no3hh.pdf ||
| Appendix Figure 6, Panel B | analyze/fig_A6ab.do          | 283            | figures/participation_reg_hh.csv; figures/eligregs_appear_2_hh_nohh.pdf | Program generates other figures not included in the paper |
| Appendix Figure 7, Panel A | analyze/fig_A7ab.do          | 226            | figures/participation_reg_robustness4.csv; figures/eligregs_robustness_4_c.pdf ||
| Appendix Figure 7, Panel B | analyze/fig_A7ab.do          | 226            | figures/participation_reg_robustness4.csv; figures/eligregs_robustness_4_li.pdf ||
| Appendix Figure 8 | analyze/fig_A8.do          | 231          | figures/participation_reg_robustness_rpp.csv; figures/participation_reg_robustness_rpp.pdf| Figure created will appear different than corresponding figure in the paper due to the removal of proprietary data |

## References

David Autor and David Dorn. "The Growth of Low Skill Service Jobs and the Polarization of the U.S. Labor Market." American Economic Review, 103(5), 1553-1597, 2013.

The Department of Housing and Urban Development. ""Prior HHS Poverty Guidelines and Federal Register References," 2025.

Economic Research Service (ERS), U.S. Department of Agriculture (USDA). SNAP Distribution Schedule Database, SNAP Policy Data Sets.

Mauricio Caceres Bravo, 2018. "GTOOLS: Stata module to provide a fast implementation of common group commands," Statistical Software Components S458514, Boston College Department of Economics, revised 05 Dec 2022.

Panel Study of Income Dynamics, public use dataset. Produced and distributed by the Survey Research Center, Institute for Social Research, University of Michigan, Ann Arbor, MI (2025).

Roger Newson, 2000. "BSPLINE: Stata modules to compute B-splines parameterized by their values at reference points," Statistical Software Components S411701, Boston College Department of Economics, revised 21 Aug 2022.

Sarah Flood, Miriam King, Renae Rodgers, Steven Ruggles, J. Robert Warren, Daniel Backman, Annie Chen, Grace Cooper, Stephanie Richards, Megan Schouweiler, and Michael Westberry. IPUMS CPS: Version 12.0 [dataset]. Minneapolis, MN: IPUMS, 2024. https://doi.org/10.18128/D030.V12.0

Sergio Correia & Paulo Guimaraes & Thomas Zylkin, 2019. "PPMLHDFE: Stata module for Poisson pseudo-likelihood regression with multiple levels of fixed effects," Statistical Software Components S458622, Boston College Department of Economics, revised 07 Sep 2023.

TRIM3 project website, trim3.urban.org, downloaded on 4/3/2025.

US Health and Human Services. ""Prior HHS Poverty Guidelines and Federal Register References," 2025.

William L. Schpero, 2016. "STATASTATES: Stata module to add US state identifiers to dataset," Statistical Software Components S458205, Boston College Department of Economics, revised 10 Jan 2018.

---

