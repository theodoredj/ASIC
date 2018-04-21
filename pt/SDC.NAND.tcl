if { [file exists ${SDC}] } {
  echo "loading sdc file ${SDC}"
  source -e -v ${SDC} > $RptDIR/NAND.$LIB.rpt
  echo "loaded sdc file ${SDC}"
}

