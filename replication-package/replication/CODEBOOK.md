# Codebook: Self-Targeting in U.S. Transfer Programs

**Paper:** "Self-Targeting in U.S. Transfer Programs"
**Authors:** Charlie Rafkin, Adam Solomon, and Evan J. Soltas
**Data coverage:** 1997–2023 (varies by source)

This codebook describes the variables obtained from each external data source used in the replication package. Its purpose is to allow others to verify that they have obtained a substantially similar dataset when successfully obtaining access to the same data.

---

## 1. Panel Study of Income Dynamics (PSID)

**Source:** Survey Research Center, Institute for Social Research, University of Michigan
**Access:** ICPSR deposit at https://doi.org/10.3886/ICPSR303531.V1 (or directly from https://simba.isr.umich.edu/data/data.aspx)
**Raw files:** `data/psid/J345111.txt`, `data/psid/J308959.txt`
**Codebooks:** `data/psid/J345111_codebook.html`, `data/psid/J308959_codebook.html`
**Time period:** Biennial waves, 1997–2019
**Unit of observation:** Individual (J345111); child (J308959)

The replication package uses two PSID extracts. The cleaning code reads these fixed-width ASCII files and produces a long-format panel (`data/psid_int.dta`, then `data/psid_base.dta`).

### 1a. Extract J345111 — All Individuals Data

**N variables:** 3,264 | **N observations:** 43,427 | **Date extracted:** March 20, 2025

This extract covers all PSID sample members across biennial waves from 1997 to 2019. Variables are stored in wide format (one row per person, one column per variable-year) in the raw file and reshaped to long panel format during cleaning.

The variable names below are the **renamed versions** used in the analysis (see `code/clean/psid/00_name_vars.do` for the mapping from original PSID variable codes, e.g., `ER10001`, to these names).

#### Identifiers

| Variable | Description |
|---|---|
| `famid_orig` | Original PSID 1968 family identifier |
| `perid_orig` | Original PSID person identifier within family |
| `id` | New unique person identifier (created during cleaning) |
| `famid` | Family interview number, by wave year |
| `hhid` | Household identifier |
| `year` | Survey wave year (1997, 1999, 2001, … , 2019) |

#### Weights

| Variable | Description |
|---|---|
| `wtfam` | Family weight |
| `wtind` | Individual weight |

#### Demographics

| Variable | Description |
|---|---|
| `sex` | Sex (time-invariant, from person-level file) |
| `age` | Age of individual |
| `rel` | Relationship to household head (10 = head, 20/22 = spouse) |
| `head` | Indicator: individual is household head |
| `spouse` | Indicator: individual is spouse of head |
| `marital` | Marital status of head |
| `hhsize` | Household size |
| `nchild` | Number of children in household |
| `race_h_` | Race of head |
| `race_s_` | Race of spouse |
| `hispanic_head` | Hispanic origin indicator for head |
| `hispanic_spouse` | Hispanic origin indicator for spouse |
| `educ_f_head` | Highest grade completed, head (father's metric) |
| `educ_m_head` | Highest grade completed, head (mother's metric) |
| `educ_f_spouse` | Highest grade completed, spouse (father's metric) |
| `educ_m_spouse` | Highest grade completed, spouse (mother's metric) |
| `ed` | Education of individual |
| `disabled_head` | Disability status of head |
| `disabled_spouse` | Disability status of spouse |
| `naturalized_h` | Naturalization status, head |
| `naturalized_s` | Naturalization status, spouse |
| `immstat_h` | Immigration status, head |
| `immstat_s` | Immigration status, spouse |
| `yrus_h` | Years in U.S., head |
| `yrus_s` | Years in U.S., spouse |
| `lang` | Language spoken at home |
| `state` | State FIPS code |
| `regiongrewup_h` | Region where head grew up |
| `regiongrewup_s` | Region where spouse grew up |

#### Income

| Variable | Description |
|---|---|
| `faminc` | Total family income |
| `faminct_hs` | Family income from head and spouse labor/business |
| `faminct_oth` | Family income from other sources |
| `transfer` | Total transfer income |
| `earnings_h_` | Earnings of head |
| `earnings_s_` | Earnings of spouse |
| `earnings_h_imp` | Imputed earnings of head |
| `earnings_s_imp` | Imputed earnings of spouse |
| `farminc` | Farm income |
| `assetincbus_h` | Asset income from business, head |
| `assetincbus_s` | Asset income from business, spouse |
| `laborincbus_h` | Labor income from business, head |
| `laborincbus_s` | Labor income from business, spouse |
| `assetinc_other` | Other asset income |
| `rent_h_amt` | Rental income amount, head |
| `rent_h_unit` | Rental income reporting unit, head |
| `div_h_amt` | Dividend income amount, head |
| `div_h_unit` | Dividend income reporting unit, head |
| `int_h_amt` | Interest income amount, head |
| `int_h_unit` | Interest income reporting unit, head |
| `trust_h_amt` | Trust income amount, head |
| `trust_h_unit` | Trust income reporting unit, head |
| `rent_s_amt` | Rental income amount, spouse |
| `div_s_amt` | Dividend income amount, spouse |
| `int_s_amt` | Interest income amount, spouse |
| `trust_s_amt` | Trust income amount, spouse |
| `fpl` | Federal poverty level threshold for household |

#### Transfer Program Participation

| Variable | Description |
|---|---|
| `snap` | SNAP (food stamps) receipt indicator, household |
| `snap_amt_hh` | SNAP benefit amount received, household |
| `snap_unit` | SNAP benefit reporting unit |
| `tanf_head` | TANF (welfare) receipt indicator, head |
| `tanf_amt_head` | TANF benefit amount, head |
| `tanf_unit_head` | TANF benefit reporting unit, head |
| `tanf_spouse` | TANF receipt indicator, spouse |
| `tanf_amt_spouse` | TANF benefit amount, spouse |
| `tanf_unit_spouse` | TANF benefit reporting unit, spouse |
| `ssi_hh` | SSI receipt indicator, household |
| `ssi_amt_head` | SSI benefit amount, head |
| `ssi_unit_head` | SSI benefit reporting unit, head |
| `ssi_spouse` | SSI receipt indicator, spouse |
| `ssi_amt_spouse` | SSI benefit amount, spouse |
| `ssi_unit_spouse` | SSI benefit reporting unit, spouse |
| `ui_head` | Unemployment insurance receipt, head |
| `ui_amt_head` | UI benefit amount, head |
| `ui_unit_head` | UI benefit reporting unit, head |
| `ui_spouse` | UI receipt indicator, spouse |
| `ui_amt_spouse` | UI benefit amount, spouse |
| `ui_unit_spouse` | UI benefit reporting unit, spouse |
| `othwelf_head` | Other welfare receipt, head |
| `othwelf_amt_head` | Other welfare amount, head |
| `othwelf_unit_head` | Other welfare reporting unit, head |
| `othwelf_spouse` | Other welfare receipt, spouse |
| `othwelf_amt_spouse` | Other welfare amount, spouse |
| `othwelf_unit_spouse` | Other welfare reporting unit, spouse |
| `liheap` | LIHEAP receipt indicator, household |
| `liheap_amt_hh` | LIHEAP benefit amount, household |
| `liheap_unit` | LIHEAP benefit reporting unit |
| `wic` | WIC receipt indicator |
| `schoolbfast` | School breakfast participation |
| `schoollunch` | School lunch participation |
| `schoolmeals` | Combined school meals participation |
| `med1`–`med7` | Medicaid/Medicare coverage indicators (multiple variables) |
| `ss_amt_h_` | Social Security benefit amount, head |
| `ss_amt_s_` | Social Security benefit amount, spouse |
| `wc_rec_h_` | Workers' compensation receipt indicator, head |
| `wc_amt_h_` | Workers' compensation benefit amount, head |
| `wc_rec_s_` | Workers' compensation receipt indicator, spouse |
| `wc_amt_s_` | Workers' compensation benefit amount, spouse |

#### Monthly Transfer Flags

For SNAP, TANF (head and spouse), and SSI (head and spouse): monthly receipt indicators across up to 12 months (`snap_m1_`–`snap_m12_`, `tanf_h_m1_`–`tanf_h_m12_`, etc.)

#### Program Application Variables (waves 1999, 2001, 2003)

| Variable | Description |
|---|---|
| `applied_tanf` | Applied for TANF |
| `applied_ssi` | Applied for SSI |
| `applied_wic` | Applied for WIC |
| `applied_snap` | Applied for SNAP |
| `applied_medicaid` | Applied for Medicaid |
| `applied_ha` | Applied for housing assistance |
| `applied_liheap` | Applied for LIHEAP |
| `applied_ui` | Applied for UI |
| `appstatus_tanf` | Application outcome, TANF |
| `appstatus_ssi` | Application outcome, SSI |
| `appstatus_wic` | Application outcome, WIC |
| `appstatus_snap` | Application outcome, SNAP |
| `appstatus_medicaid` | Application outcome, Medicaid |
| `appstatus_ha` | Application outcome, housing assistance |
| `appstatus_liheap` | Application outcome, LIHEAP |
| `appstatus_ui` | Application outcome, UI |

#### Housing

| Variable | Description |
|---|---|
| `ownhome` | Home ownership indicator |
| `houseval` | Home value |
| `rent` | Rent amount paid |
| `rent_unit` | Rent reporting unit |
| `ph1` | Public housing indicator 1 |
| `ph2` | Public housing indicator 2 |
| `rent_subsidy_part` | Partial rent subsidy indicator |
| `rent_subsidy_full` | Full rent subsidy indicator |
| `equivrent` | Equivalent rental value |
| `equivrent_unit` | Equivalent rental value reporting unit |
| `rooms` | Number of rooms |
| `aircond` | Air conditioning indicator |

#### Expenditure Variables

| Variable | Description |
|---|---|
| `housing_exp` | Housing expenditures |
| `utility_exp` | Utility expenditures |
| `food_exp` | Food expenditures |
| `trans_exp` | Transportation expenditures |
| `educ_exp` | Education expenditures |
| `childcare_exp` | Child care expenditures |
| `health_exp` | Health expenditures |
| `computer_exp` | Computer expenditures |
| `clothing_exp` | Clothing expenditures |
| `travel_exp` | Travel expenditures |
| `rec_exp` | Recreation expenditures |
| `mortgage_exp` | Mortgage expenditures |
| `proptax_exp` | Property tax expenditures |
| `furniture_exp` | Furniture expenditures |
| `vehadd_exp` | Vehicle additions expenditures |
| `foodathome_exp` | Food at home expenditures |
| `gasoline_exp` | Gasoline expenditures |
| `othtrans_exp` | Other transportation expenditures |
| `taxi_exp` | Taxi expenditures |
| `bustrain_exp` | Bus/train expenditures |
| `parking_exp` | Parking expenditures |
| `veh_rep_exp` | Vehicle repair expenditures |
| `veh_ins_exp` | Vehicle insurance expenditures |
| `veh_loan_exp` | Vehicle loan expenditures |
| `veh_dp_exp` | Vehicle down payment expenditures |

#### Employment and Occupation

| Variable | Description |
|---|---|
| `emp` | Employment status |
| `annual_hrs_head` | Annual hours worked, head |
| `annual_hrs_spouse` | Annual hours worked, spouse |
| `wks_unemp_head` | Weeks unemployed, head |
| `wks_unemp_spouse` | Weeks unemployed, spouse |
| `why_unemploy_head` | Reason for unemployment, head |
| `why_unemploy_spouse` | Reason for unemployment, spouse |
| `weeks_h` | Weeks worked, head |
| `hours_h` | Hours per week worked, head |
| `weeks_s` | Weeks worked, spouse |
| `hours_s` | Hours per week worked, spouse |
| `selfemp_h` | Self-employment indicator, head |
| `selfemp_s` | Self-employment indicator, spouse |
| `ind_h` | Industry code, head |
| `occ_h` | Occupation code, head |
| `ind_s` | Industry code, spouse |
| `occ_s` | Occupation code, spouse |

#### Vehicles

| Variable | Description |
|---|---|
| `veh1_manuf` | Vehicle 1 manufacturer |
| `veh1_make` | Vehicle 1 make |
| `veh1_model` | Vehicle 1 model |
| `veh1_type` | Vehicle 1 type |
| `veh1_howacq` | Vehicle 1 acquisition method |
| `veh1_yearacq` | Vehicle 1 year acquired |
| `veh1_price` | Vehicle 1 price |
| `veh1_leaseamt` | Vehicle 1 lease amount |
| `veh1_leasefreq` | Vehicle 1 lease frequency |
| `veh2_*`, `veh3_*` | Same variables for vehicles 2 and 3 |

#### Food Security

| Variable | Description |
|---|---|
| `foodsecy` | Food security indicator |
| `fsecmon1_`–`fsecmon12_` | Monthly food security indicators |

#### Other Variables

| Variable | Description |
|---|---|
| `grewuppoor_h` | Indicator: head grew up in poverty |
| `grewuppoor_s` | Indicator: spouse grew up in poverty |
| `health_h` | Health status, head |
| `health_s` | Health status, spouse |
| `js_month_h`, `js_year_h` | Job start month/year, head |
| `js_month_s`, `js_year_s` | Job start month/year, spouse |
| `je_year_h`, `je_year_s` | Job end year, head/spouse |
| `computer_h`, `smartphone_h` | Computer/smartphone ownership, head household |
| `computer_s`, `smartphone_s` | Computer/smartphone ownership, spouse |
| `oer` | Owner-equivalent rent |
| `split` | Indicator: family split from another family |
| `hval25_`–`hval400_` | Home value brackets |

### 1b. Extract J308959 — Child Development Supplement (CDS)

**N variables:** 43 | **N observations:** 10,169
**Waves:** 1997, 2001/2002, 2005, 2013/2014, 2019

This supplemental extract provides child-level data, merged to the main PSID on family identifiers. Used to construct a child disability indicator.

| Variable | Description |
|---|---|
| `famid_orig` | Original 1968 family ID |
| `perid_orig` | Person ID in original family |
| `famid{YYYY}` | Family interview number in wave year |
| `limitathletics{YYYY}` | Child health limits athletic activity (wave year) |
| `limitschattend{YYYY}` | Child health limits school attendance (wave year) |
| `limitschwork{YYYY}` | Child health limits school work (wave year) |
| `child_disabled` | Constructed indicator: child has at least one limitation (any wave) |

---

## 2. IPUMS Current Population Survey (CPS–ASEC)

**Source:** IPUMS CPS (Ruggles et al., 2024; https://doi.org/10.18128/D030.V12.0)
**Raw files:** `data/cps/cps_00091.dat`, `data/cps/cps_00092.dat`
**Codebook:** Embedded in loading scripts `code/clean/cps/00_cps_00091.do`
**Time period:** Annual (survey years covered by the ASEC supplement)
**Unit of observation:** Individual

The CPS extract is used primarily to impute income for PSID households via a regression of income on demographics and job characteristics. The archive contains the extracted data; IPUMS does not currently support stored extract URLs.

| Variable | Label |
|---|---|
| `year` | Survey year |
| `serial` | Household serial number |
| `month` | Month (1=January, …, 12=December) |
| `cpsid` | CPSID, household record |
| `asecflag` | Flag for ASEC (1=ASEC, 2=March Basic) |
| `asecwth` | Annual Social and Economic Supplement household weight |
| `statefip` | State FIPS code |
| `pernum` | Person number in sample unit |
| `cpsidp` | CPSID, person record |
| `asecwt` | Annual Social and Economic Supplement person weight |
| `relate` | Relationship to household head |
| `age` | Age |
| `sex` | Sex (1=Male, 2=Female) |
| `race` | Race |
| `marst` | Marital status |
| `hispan` | Hispanic origin |
| `educ` | Educational attainment recode |
| `occly` | Occupation last year |
| `indly` | Industry last year |
| `ind90ly` | Industry last year, 1990 basis |
| `classwly` | Class of worker last year |
| `wkswork1` | Weeks worked last year |
| `uhrsworkly` | Usual hours worked per week (last year) |
| `inctot` | Total personal income |
| `disabwrk` | Work disability |

**Derived variables used in analysis:**

| Variable | Description |
|---|---|
| `female` | Indicator: female (sex==2) |
| `married` | Indicator: currently married (marst==1 or 2) |
| `hispanic` | Indicator: Hispanic origin (hispan≠0) |
| `black` | Indicator: Black, non-Hispanic |
| `aian` | Indicator: American Indian/Alaska Native, non-Hispanic |
| `asian` | Indicator: Asian, non-Hispanic |
| `otherrace` | Indicator: other race, non-Hispanic |
| `disabled` | Indicator: work disability (disabwrk==2) |
| `edcat` | Education category (1=<HS, 2=HS, 3=Some college, 4=BA+) |

---

## 3. Consumer Expenditure Survey (CEX)

**Source:** U.S. Bureau of Labor Statistics, Consumer Expenditure Survey (Public Use Microdata)
**Raw files:** `data/cex/raw/intrvw{YY}.zip` for years 1997–2019
**Time period:** Quarterly interview surveys, 1997–2019
**Unit of observation:** Consumer unit (household), quarterly

The CEX is used to construct consumption measures for the analysis. The raw data consist of multiple file types per year-quarter, loaded using `code/clean/cex/01_load_cex.do` and processed in `code/clean/cex/02_process_cex.do`. The main file types are:

- **fmli / memi**: Family-level characteristics interview files (quarterly; `fmli` = family, `memi` = member)
- **hhp / ihp / ihb**: Housing and utilities expenditure files
- **opi**: Out-of-pocket expenditure files
- **ihc**: Income files
- **hhm**: Household member files
- **rnt**: Rented dwelling files
- **lsd**: Large durable goods files
- **ovb**: Owned vacation home files
- **eqb**: Major appliances files
- **apb / apl**: Apparel files

#### Identifiers and Weights

| Variable | Description |
|---|---|
| `newid` | Consumer unit identifier (new) |
| `hhid` | Household identifier |
| `cuid` | Consumer unit identifier |
| `state` | State FIPS code |
| `year` | Year |
| `qtr` | Quarter (1–4) |
| `finlwt21` | Final calibration weight |

#### Transfer Program Variables

| Variable | Description |
|---|---|
| `foodsmpm` / `foodsmpq` / `foodsmp1`–`foodsmp5` | SNAP (food stamp) amount: monthly, quarterly, and by interview quarters |
| `fs_amtx` / `fs_amtx1`–`fs_amtx5` | Food stamp dollar amount received |
| `jfdstmpa` / `jfs_amt` / `jfs_amt1`–`jfs_amt5` | Food stamp dollar amounts (annual file versions) |
| `jmdcdqvx` | Medicaid quarterly value |
| `mdcdcov` | Medicaid coverage indicator |
| `mdcdenr` | Medicaid enrollment indicator |
| `mdcdprmx` | Medicaid premium amount |
| `medicaid` | Medicaid participation indicator |
| `medprem` | Medicare premium amount |
| `hhmcrcov` | Medicare coverage indicator |
| `othmed` | Other medical insurance amount |
| `othplan` | Other health plan amount |
| `hhipdlib` | Health insurance plan indicator |
| `fssix` / `fssixm` / `ssibx` / `ssix` / `ssixm` | SSI benefit amount variables |
| `publhous` | Public housing indicator |
| `govtcost` | Government subsidy for housing costs |
| `welfarex` / `welfrebx` / `welfarem` / `welfareb` | TANF/welfare benefit amount variables |

#### Demographics

| Variable | Description |
|---|---|
| `fam_size` | Family size |
| `age_ref` | Age of reference person |
| `educ_ref` | Education of reference person |
| `ref_race` | Race of reference person |
| `horref1` / `horref2` | Hispanic origin of reference person |
| `hisp_ref` | Hispanic indicator, reference person |
| `marital1` | Marital status of reference person |
| `sex_ref` | Sex of reference person |

#### Consumption and Expenditure

| Variable | Description |
|---|---|
| `etotalp` / `etotalc` | Total expenditures (prior/current quarter) |
| `etotapx4` / `etotacx4` | Total expenditures (annual equivalent, prior/current) |
| `totexppq` / `totexpcq` | Total expenditures (prior/current quarter, alternative measure) |
| `rnteqvx` | Rental equivalence |
| `owndwecq` / `owndwepq` | Owner dwelling value (current/prior quarter) |
| `rntxrpcq` / `rntxrppq` | Rental expenditures (current/prior quarter) |
| `vehfinpq` / `vehfincq` | Vehicle financing (prior/current quarter) |
| `cartknpq` / `cartkncq` | Vehicle trade-in value (prior/current quarter) |
| `hlthinpq` / `hlthincq` | Health insurance expenditures (prior/current quarter) |
| `fdhomecq` / `fdhomepq` | Food at home expenditures (current/prior quarter) |
| `gasmocq` / `gasmopq` | Gasoline and motor oil (current/prior quarter) |
| `utilcq` / `utilpq` | Utilities (current/prior quarter) |
| `perinspq` / `perinscq` | Personal insurance (prior/current quarter) |
| `cntralac` | Central air conditioning indicator |
| `milesveh` | Miles on vehicle |
| `vehicyr` / `modelyr` | Vehicle year / model year |
| `make` / `mkmodel` | Vehicle make / make-model |

#### Income

| Variable | Description |
|---|---|
| `earnincx` | Earnings income |
| `fsalaryx` | Salary and wages |
| `fnonfrmx` | Non-farm self-employment income |
| `ffrmincx` | Farm income |
| `frretirx` | Retirement income |
| `intearnx` | Interest income |
| `finincx` | Financial income |
| `pensionx` | Pension income |
| `inclossa` / `inclossb` | Income loss variables |
| `liquidx` | Liquid assets |
| `secestx` | Securities |
| `stockx` | Stocks |
| `irax` | IRA balance |
| `othastx` | Other assets |
| `unemplx` | Unemployment income |
| `compensx` | Workers' compensation |
| `chdothx` | Child support/alimony |
| `aliothx` | Alimony |
| `othrincx` | Other income |
| `incnonw1` / `incnonw2` | Non-wage income indicators |
| `inc_rank` / `inc_rnkm` | Income rank (current/prior quarter) |
| `povlevcy` | Poverty level |
| `respstat` | Respondent status |

---

## 4. BEA Regional Economic Accounts (SASUMMARY)

**Source:** U.S. Bureau of Economic Analysis, Regional Economic Accounts
**Raw file:** `data/SASUMMARY__ALL_AREAS_1998_2023.csv`
**Time period:** Annual, 1998–2023
**Unit of observation:** State (52 geographic units: 50 states + D.C. + United States total)
**Used for:** State-level price indices and income normalization

This file is the BEA's SASUMMARY table (Summary of State Annual Personal Income and Employment). It contains 15 series for each state and year in wide format.

| Column | Description |
|---|---|
| `GeoFIPS` | Geographic FIPS code (e.g., `"00000"` = U.S., `"01000"` = Alabama) |
| `GeoName` | Geographic area name |
| `Region` | BEA region code |
| `TableName` | Table identifier (`SASUMMARY`) |
| `LineCode` | Series identifier (1–15) |
| `IndustryClassification` | Industry classification (`"..."` for aggregate) |
| `Description` | Series description (see below) |
| `Unit` | Unit of measurement |
| `1998`–`2023` | Annual values for each year |

#### Series Descriptions (LineCode → Description)

| LineCode | Description | Unit |
|---|---|---|
| 1 | Real GDP | Millions of chained 2017 dollars |
| 2 | Real personal income | Millions of constant 2017 dollars |
| 3 | Real PCE | Millions of constant 2017 dollars |
| 4 | Gross domestic product (GDP) | Millions of current dollars |
| 5 | Personal income | Millions of current dollars |
| 6 | Disposable personal income | Millions of current dollars |
| 7 | Personal consumption expenditures | Millions of current dollars |
| 8 | Real per capita personal income | Constant 2017 dollars |
| 9 | Real per capita PCE | Constant 2017 dollars |
| 10 | Per capita personal income | Dollars |
| 11 | Per capita disposable personal income | Dollars |
| 12 | Per capita personal consumption expenditures (PCE) | Dollars |
| 13 | Regional price parities (RPPs) | Index (U.S. = 100) |
| 14 | Implicit regional price deflator | Index |
| 15 | Total employment | Number of jobs |

**Note:** Series 2, 3, 8, 9, and 13–14 are unavailable (`(NA)`) for years before 2008.

---

## 5. Program Eligibility Simulation Data (eligsim)

The `data/eligsim/` directory contains policy parameter files used to simulate eligibility for U.S. transfer programs. These are organized by program.

### 5a. SNAP (data/eligsim/snap/)

**Source:** USDA Economic Research Service, SNAP Policy Database (via USDA SNAP Policy Data Sets)
**File:** `snap_params.csv`

| Variable | Description |
|---|---|
| `state` | State identifier (blank = federal, state-specific otherwise) |
| `year` | Calendar year |
| `hhsize` | Household size (1–8+) |
| `max_allotment` | Maximum SNAP benefit allotment (dollars per month) |
| `std_deduction` | Standard deduction (dollars per month) |
| `max_excess_shelter_deduction` | Maximum excess shelter deduction (dollars per month) |

**File:** `immigrant_elig.csv` — immigrant eligibility by state and program period

| Variable | Description |
|---|---|
| `statename` | State name |
| `state_fips` | State FIPS code |
| `tanf_imm_early` | TANF immigrant eligibility, early period |
| `medicaid_imm_early` | Medicaid immigrant eligibility, early period |
| `snap_imm_early` | SNAP immigrant eligibility, early period |
| `ssi_imm_early` | SSI immigrant eligibility, early period |
| `tanf_imm_late` | TANF immigrant eligibility, late period |
| `medicaid_imm_late` | Medicaid immigrant eligibility, late period |
| `snap_imm_late` | SNAP immigrant eligibility, late period |
| `ssi_imm_late` | SSI immigrant eligibility, late period |
| `snap_imm_late2021` | SNAP immigrant eligibility, post-2021 period |
| `ssi_imm_late2002` | SSI immigrant eligibility, post-2002 period |
| `medicaid_imm_late2012` | Medicaid immigrant eligibility, post-2012 period |
| `tanf_imm_late2011` | TANF immigrant eligibility, post-2011 period |

### 5b. Medicaid (data/eligsim/medicaid/)

**Source:** Kaiser Family Foundation (KFF) state Medicaid income eligibility threshold data

Three KFF files cover different eligibility groups:

**`medicaid_eligibility_fpl_nondisabled_adults_kff.csv`**
Medicaid income eligibility limits (as % FPL) for non-disabled adults, by state and year (January 1996–January 2020).

**`medicaid_eligibility_fpl_parents_kff.csv`**
Medicaid income eligibility limits (as % FPL) for parents, by state and year (January 1996–January 2020).

**`medicaid_eligibility_fpl_pregnant_women_kff.csv`**
Medicaid and CHIP income eligibility limits (as % FPL) for pregnant women, by state and year (April 2003–January 2020).

All three files share the structure: rows = states, columns = dates (snapshot months/years), values = income threshold as percent of FPL.

**`medicaid_eligibility_disabled_adults.csv`**
Medicaid eligibility rules for disabled adults by state and year.

| Variable | Description |
|---|---|
| `state` | State abbreviation |
| `year` | Year |
| `has_obra86_option` | Indicator: state adopted OBRA 86 option |
| `income_limit_single` | Income limit for single disabled adult (dollars/month) |
| `income_limit_couple` | Income limit for couple (dollars/month) |
| `income_limit_fpl_single` | Income limit as % FPL, single |
| `income_limit_fpl_couple` | Income limit as % FPL, couple |
| `disregard_single` | Income disregard, single |
| `disregard_couple` | Income disregard, couple |
| `asset_limit_single` | Asset limit, single |
| `asset_limit_couple` | Asset limit, couple |
| `has_medicaid_buyin` | Indicator: state has Medicaid buy-in option |
| `buyin_income_limit` | Income limit for buy-in |
| `buyin_asset_limit_single` | Asset limit for buy-in, single |
| `buyin_asset_limit_couple` | Asset limit for buy-in, couple |
| `buyin_income_limit_fpl` | Buy-in income limit as % FPL |
| `has_medically_needy_pathway` | Indicator: state has medically needy pathway |
| `needy_income_limit_single` | Medically needy income limit, single |
| `needy_income_limit_couple` | Medically needy income limit, couple |
| `needy_asset_limit_single` | Medically needy asset limit, single |
| `needy_asset_limit_couple` | Medically needy asset limit, couple |

### 5c. SSI (data/eligsim/ssi/)

**Source:** SSA administrative data (state supplement information)
**File:** `ssi_state_supplement.csv`

| Variable | Description |
|---|---|
| `statefip` | State FIPS code |
| `year` | Calendar year |
| `supplement_single_indep` | Monthly state supplement for single individual living independently |
| `supplement_couple_indep` | Monthly state supplement for couple living independently |
| `supplement_single_institution` | Monthly state supplement for single individual in institution |

**File:** `immigrant_elig.csv` — same structure as SNAP immigrant eligibility file (see 5a above)

### 5d. TANF (data/eligsim/tanf/)

**Source:** TRIM3 microsimulation model (Urban Institute), trim3.urban.org, downloaded April 3, 2025
**Files:** `da1.dta`, `da2.dta`, `da_long.dta` (Stata data files)
**Documentation:** `TRIM3 Data Dictionary.pdf`, `TRIM3_Documentation.pdf`

TRIM3 data contain state-level TANF eligibility parameters. Key variables in `da_long.dta` include state name, state FIPS code, year, and program eligibility/benefit parameters. See the included TRIM3 Data Dictionary for full variable descriptions.

### 5e. LIHEAP (data/eligsim/liheap/)

**Source:** HHS/state agency income documentation (web-scraped)
**Files:** HTML files named `{YEAR}_income.html` (e.g., `1997_income.html`)

These files contain state-level LIHEAP income eligibility limits by year, scraped from state and federal program documentation.

### 5f. Housing Assistance (data/eligsim/housing_assistance/)

**Source:** HUD income limits data
**Files:** `incfy{YY}.xls` (Excel files, one per federal fiscal year) and `inc_limit.dta` (compiled Stata file)

Key variables in `inc_limit.dta`:

| Variable | Description |
|---|---|
| `state` | State name |
| `fips` | State FIPS code |
| `hhsize` | Household size |
| `ami` | Area median income (dollars) |
| `year` | Year |
| Various limit variables | Income limits for different housing assistance thresholds (e.g., 30%, 50%, 80% of AMI) |

### 5g. UI (data/eligsim/ui/)

**Source:** Department of Labor / state UI agency documentation
**File:** `ui_params.xlsx` and compiled `ui_params.dta`

Variables include state-level UI program parameters: minimum/maximum weekly benefit amounts, base period rules, and eligibility thresholds by state and year.

---

## 6. Misreporting Correction Data (mittag2009/)

The `data/mittag2009/` folder contains files from the replication packages of two papers on correcting for underreporting of government transfer programs in survey data. The files are used to impute SNAP and Medicaid receipt in the PSID. For full methodological details, readers should consult these papers directly:

- Mittag, Nikolas. "Correcting for Misreporting of Government Benefits." *American Economic Journal: Economic Policy* (2019). https://www.aeaweb.org/articles?id=10.1257/pol.20160618
- Mittag, Nikolas. "A Method of Correcting for Misreporting Applied to the Food Stamp Program." *Journal of Survey Statistics and Methodology* 7(3): 440–468 (2019). https://academic.oup.com/jssam/article-abstract/7/3/440/5115554

The folder contains the following files:

| File | Description |
|---|---|
| `par_vec.xlsx` | Estimated parameter vectors for the conditional density of food stamp receipt and amounts, based on 2008–2010 New York State ACS samples (and two NY subsamples). Sheets: `cd_par`, with columns `par_2008`, `par_2009`, `par_2010`, `par_sub0`, `par_sub1`. |
| `var_mat.xlsx` | Variance matrices corresponding to `par_vec.xlsx`. Sheets: `var_mat2008`, `var_mat2009`, `var_mat2010`, `var_mat_nysub0`, `var_mat_nysub1`. |
| `par_vec_mod.csv` | Modified parameter vector; column `pname` identifies parameters, column `cd2008` contains parameter values. |
| `read_par.do` | Stata code (from Mittag's replication package) that reads `par_vec.xlsx` and `var_mat.xlsx` into Stata matrices named `par_{year}` and `varmat_{year}`. |
| `create_covariates.do` | Stata code (from Mittag's replication package) that constructs the required covariates from raw ACS data. |
| `povlines.dta` | Poverty line thresholds used by `create_covariates.do` to construct income-to-poverty-ratio variables. |
| `readme.txt` | Documentation from Mittag's original replication package. |
| `medicaid_models_davern_et_al.csv` | Logistic regression coefficients for predicting Medicaid receipt, attributed to Davern et al. and used in Mittag's misreporting correction framework for Medicaid. Columns: `pname` (parameter name), `model1` (coefficient, model 1), `model2` (coefficient, model 2). |

---

## 7. Federal Poverty Guidelines (data/psid/fed_pov_guidelines.dta)

**Source:** U.S. Department of Health and Human Services, "Prior HHS Poverty Guidelines and Federal Register References" (2025)
**File:** `data/psid/fed_pov_guidelines.dta`
**Unit:** Household size and year

This file contains the official annual HHS federal poverty level thresholds used to compute household poverty ratios. Variables include year, household size, and the dollar threshold for that cell.

---

## 8. Occupation and Industry Crosswalks (data/crosswalks/)

**Source:** David Autor and David Dorn - https://www.ddorn.net/data.htm
**Files:**

| File | Description |
|---|---|
| `occ1970_occ1990dd/occ1970_occ1990dd.dta` | Crosswalk from 1970-basis to 1990 DD occupation codes |
| `occ2000_occ1990dd/occ2000_occ1990dd.dta` | Crosswalk from 2000-basis to 1990 DD occupation codes |
| `occ2010_occ1990dd/occ2010_occ1990dd.dta` | Crosswalk from 2010-basis to 1990 DD occupation codes |
| `ind1970_ind1990.dta` | Crosswalk from 1970-basis to 1990-basis industry codes |
| `ind2000_ind1990.dta` | Crosswalk from 2000-basis to 1990-basis industry codes |
| `ind2010_ind1990.dta` | Crosswalk from 2010-basis to 1990-basis industry codes |

Each crosswalk file maps source-year occupation/industry codes to a harmonized 1990-basis code. These are used to construct consistent occupation (`occconst`) and industry (`indconst`) variables for use in the income imputation regressions.

---

## 9. Intermediate and Constructed Data Files

These files are outputs of the cleaning code and are not external data sources, but they are used directly in analysis code and may help replicators verify their output.

| File | Description |
|---|---|
| `data/psid_int.dta` | PSID data after reshaping and initial cleaning (output of `code/clean/psid/01_psid_reshape.do`) |
| `data/psid_base.dta` | Final PSID analysis file with income ranks and lifetime income (output of `code/clean/psid/03_merge_psid_reshape_lifetime_earnings.do`) |
| `data/lifetime_income.dta` | Empirical Bayes estimates of lifetime income by PSID individual (output of `code/clean/psid/02_ebayes_lifetime_earnings.do`) |
| `data/cps/cps_imputation.dta` | CPS-based income imputation predictions for PSID households |
| `data/cex/raw/workfile.dta` | Intermediate CEX workfile |
| `data/state_prices.dta` | State-level price indices (derived from BEA SASUMMARY RPPs) |
| `data/projections.dta` | Population projections or eligibility projections |
| `data/eligsim/snap.dta` | Compiled SNAP eligibility parameters |
| `data/eligsim/medicaid.dta` | Compiled Medicaid eligibility parameters |
| `data/eligsim/snap_immigrant.dta` | SNAP eligibility, immigrants |
| `data/eligsim/medicaid_immigrant.dta` | Medicaid eligibility, immigrants |
| `data/eligsim/ssi_immigrant.dta` | SSI eligibility, immigrants |
| `data/eligsim/tanf_immigrant.dta` | TANF eligibility, immigrants |
| `data/eligsim/liheap.dta` | Compiled LIHEAP eligibility parameters |
| `data/eligsim/povlines.dta` | Federal poverty lines |

---

## Notes on Data Access

- **PSID:** Data are not directly redistributable. They are available to registered users from the PSID website (https://simba.isr.umich.edu) or through the ICPSR deposit (https://doi.org/10.3886/ICPSR303531.V1). Users must agree to PSID terms of use.
- **IPUMS CPS:** Data can be downloaded by registered users at https://cps.ipums.org. IPUMS allows redistribution for replication purposes; the extracted files are included in the archive.
- **CEX:** Public-use microdata are available from the BLS website (https://www.bls.gov/cex/pumd.htm). The raw zip files (`intrvw{YY}.zip`) are included in `data/cex/raw/`.
- **BEA SASUMMARY:** Freely available from https://apps.bea.gov/regional/downloadzip.cfm. The file `SASUMMARY__ALL_AREAS_1998_2023.csv` is included.
- **KFF Medicaid thresholds:** Freely available from https://www.kff.org/medicaid/state-indicator/. The CSV files are included.
- **TRIM3:** Available from the Urban Institute (https://trim3.urban.org). The `da_long.dta` file is included; documentation PDFs are in `data/eligsim/tanf/`.
- **USDA SNAP Policy Database:** Available from USDA ERS (https://www.ers.usda.gov/data-products/snap-policy-data-sets/). The compiled file `snap_params.csv` is included.
- **SSI state supplements:** Compiled from SSA administrative reports.
- **HUD income limits:** Available from HUD (https://www.huduser.gov/portal/datasets/il.html). The compiled `inc_limit.dta` is included.
- **Occupation/industry crosswalks:** Available from David Autor's website and Census concordance files.
