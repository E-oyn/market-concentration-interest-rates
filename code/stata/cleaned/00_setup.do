/*==============================================================================
 00_setup.do

 Sets the single path root used by every other script in this pipeline.
 Edit ONLY this file when moving the project to a new machine/clone.

 Expected folder layout under $root (created by 01_editing.do onwards):
   data/interim/editing/
   data/interim/interest/
   data/interim/markup/<country>/
   data/interim/hhi/<country>/
   data/interim/merge/
   data/final/
   outputs/tables/
   outputs/figures/

 Countries covered: Aus, Be, Cz, De, Es, Fr, It, Lu, Pl, Pt, Sk (11 countries).

 NOTE ON EXCLUDED COUNTRY: the original project folders used the abbreviation
"Hr" for an EU country, but Merge Do Zero.do's own `label define country_n`
 line labels that slot "Hungary" (Hr normally reads as Croatia's ISO code).
 Because this mismatch was never resolved against the raw BACH source, that
 country (encoded country_n == 7 in the original pipeline) has been EXCLUDED
 from this cleaned version rather than guessed at. See ../data/README.md.
=============================================================================*/

clear
clear matrix
capture log close

* --- EDIT THIS LINE ONLY ---
global root "`c(pwd)'"
* ----------------------------

cap mkdir "$root/data"
cap mkdir "$root/data/interim"
cap mkdir "$root/data/interim/editing"
cap mkdir "$root/data/interim/interest"
cap mkdir "$root/data/interim/markup"
cap mkdir "$root/data/interim/hhi"
cap mkdir "$root/data/interim/merge"
cap mkdir "$root/data/final"
cap mkdir "$root/outputs"
cap mkdir "$root/outputs/tables"
cap mkdir "$root/outputs/figures"

foreach c in aus be cz de es fr it lu pl pt sk {
    cap mkdir "$root/data/interim/markup/`c'"
    cap mkdir "$root/data/interim/hhi/`c'"
}

di as text "Root set to: $root"
di as text "Run 01_editing.do next."

/*==============================================================================
 REQUIRED THIRD-PARTY STATA PACKAGES (install once per machine)
==============================================================================*/
* ssc install acfest, replace      // Ackerberg-Caves-Frazer production function / TFP estimation (Manjon & Manez 2016)
* ssc install hhi, replace         // Herfindahl-Hirschman Index (Yujun 2016)
* ssc install hhi5, replace        // HHI variant used for the Pan-EU index in the merge stage
* ssc install pvar, replace        // Panel VAR: pvarsoc / pvar / pvargranger / pvarstable / pvarirf (Abrigo & Love 2016)
* ssc install missings, replace    // used once in 04_merge.do for a missing-data report
