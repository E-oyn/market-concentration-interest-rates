/*==============================================================================
 run_all.do -- runs the full pipeline end to end, in order.
 Requires: data/raw/bach_export.csv and data/raw/interest_rate_data.csv
 to be present first (see ../data/README.md). Requires the packages listed
 in 00_setup.do to already be installed.
==============================================================================*/
do "00_setup.do"
do "01_editing.do"
do "02_interest.do"
do "03_markup_hhi.do"
do "04_merge.do"
do "05_var_lag1.do"
do "06_var_lag2_robustness.do"

di as result "Pipeline complete. See outputs/tables and outputs/figures."
