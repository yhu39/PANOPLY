# ```panoply_unified_workflow```

## Description
Performs proteogenomic analysis on multiple omics types in parallel (ie ```panoply_main```) and leverages additional analysis modules such as ```panoply_immune_analysis```, ```panoply_blacksheep```, and ```panoply_mo_nmf```.

This pipeline executes the following modules and pipelines:

* [panoply_main](./Pipelines%3A-panoply_main)
* [panoply_immune_analysis](./Data-Analysis-Modules%3A-panoply_immune_analysis)
* [panoply_immune_analysis_report](./Report-Modules%3A-panoply_immune_analysis_report)
* [panoply_blacksheep](./Data-Analysis-Modules%3A-panoply_blacksheep)
* [panoply_blacksheep_report](./Report-Modules%3A-panoply_blacksheep_report)
* [panoply_mo_nmf](./Data-Analysis-Modules%3A-panoply_mo_nmf)
* [panoply_mo_nmf_report](./Report-Modules%3A-panoply_mo_nmf_report)

## Input

Required inputs:

* ```yaml```: (`.yaml` file) parameters in `yaml` format
* ```job_id```: (String) An identifier name given to the job
* ```run_ptmsea```: please see `run_ptmsea` input parameter in [panoply_main](./Pipelines%3A-panoply_main)
* ```run_cmap```: please see `run_cmap` input parameter in [panoply_main](./Pipelines%3A-panoply_main)
* ```rna_data```: (`.gct` file, default = this.rna_v3_ss) Input rna data matrix
* ```cna_data```: (`.gct` file, default = this.cna_ss) Input cna data matrix

Optional inputs (at least one *must* be specified):

* ```prote_ome```: (`.gct` file, default = this.proteome_ss) proteome data matrix
* ```phospho_ome```: (`.gct` file, default = this.phosphoproteome_ss) phosphoproteome data matrix
* ```acetyl_ome```: (`.gct` file, default = this.acetylome_ss) acetylome data matrix
* ```ubiquityl_ome```: (`.gct` file, default = this.ubiquitylome_ss) ubiquitylome data matrix

## Output
This pipeline outputs two `.zip	` files:

1. `all_results.zip` 
This file contains complete results from all pipelines and modules run. The directory structure and results are formatted as follows:

* `results`:
	- `proteogenomic_analysis`: contains all results from `panoply_main` including a folder called `all_html_reports` which contains all reports produced from the `panoply_main` pipeline. If `panoply_cmap_analysis` was run, a folder named `proteome_cmap_analysis` will be present containing results from this module. Please see the outputs from [panoply_main](./Pipelines%3A-panoply_main) for more information.
	- `blacksheep_outlier`: contains a folder for each ome type it was run on. Each ome folder will contain `panoply_blacksheep` results. Please see the outputs from [panoply_blacksheep](./Data-Analysis-Modules%3A-panoply_blacksheep) for more information.
	- `mo-nmf`: contains results from [panoply_mo_nmf](./Data-Analysis-Modules%3A-panoply_mo_nmf)
	- `immune_analysis`: contains results from [panoply_immune_analysis](./Data-Analysis-Modules%3A-panoply_immune_analysis)

2. `all_reports.zip`
This file contains all reports produced from every pipeline and module run. The directory structure for this file is formatted as follows:

* `reports`:
	- `proteogenomic_analysis`: contains all reports generated by the modules in [panoply_main](./Pipelines%3A-panoply_main)
	- `blacksheep_outlier`: contains all reports generated by [panoply_blacksheep_report](./Report-Modules%3A-panoply_blacksheep_report)
	- `mo-nmf`: contains all reports generated by [panoply_mo_nmf_report](./Report-Modules%3A-panoply_mo_nmf_report) and [panoply_ssgsea_report](./Report-Modules%3A-panoply_ssgsea_report)
	- `immune_analysis`: contains all reports produced by [panoply_immune_analysis_report](./Report-Modules%3A-panoply_immune_analysis_report)
