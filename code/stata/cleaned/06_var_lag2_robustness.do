/*==============================================================================
 06_var_lag2_robustness.do
 Robustness check: panel VAR with lag(2), matching the thesis's own caveat
 (chapter 9): "using the second lag produces insignificant results for all
 the firm sizes and variables."
==============================================================================*/
do "00_setup.do"
do "_var_core.do" 2 lag2
