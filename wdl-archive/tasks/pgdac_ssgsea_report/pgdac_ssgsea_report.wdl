task pgdac_ssgsea_report {
  File tarball
  String label
  String type
  String tmpDir

  Int? memory
  Int? disk_space
  Int? num_threads

  command {
    set -euo pipefail
    Rscript /home/pgdac/src/rmd-ssgsea.r ${tarball} ${label} ${type} ${tmpDir}
  }

  output {
    File report = "ssgsea_" + label + ".html"
  }

  runtime {
    docker : "broadcptac/pgdac_rmd:3"
    memory : select_first ([memory, 8]) + "GB"
    disks : "local-disk " + select_first ([disk_space, 20]) + " SSD"
    cpu : select_first ([num_threads, 1]) + ""
  }

  meta {
    author : "Karsten Krug"
    email : "karsten@broadinstitute.org"
  }
}

workflow pgdac_sampleqc_report_workflow {
	call pgdac_ssgsea_report
}
