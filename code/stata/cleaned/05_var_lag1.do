/*==============================================================================
 05_var_lag1.do
 Main specification: panel VAR with lag(1), matching the thesis's headline
 results (Figures 7-12, Tables 2a/2b/3a/3b).
==============================================================================*/
do "00_setup.do"
do "_var_core.do" 1 lag1
