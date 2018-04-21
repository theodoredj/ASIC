set SESSION $env(SESSION)

set LrunID $runID
set LRptDIR $RptDIR
set LSessionDIR $SessionDIR

restore_session $SESSION
current_design $TOP
link
report_timing

set SessionDIR $LSessionDIR
set RptDIR $LRptDIR
set runID $LrunID

if ![file exists $RptDIR] {file mkdir $RptDIR}
if ![file exists $SessionDIR] {file mkdir $SessionDIR}
