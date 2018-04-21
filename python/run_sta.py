#!/usr/bin/python

def run_sta():
  import sys, os
  from subprocess import call
  sys.path.append(os.path.abspath("/proj/elnath1/wa/"+os.environ['USER']+"/scr/python"))
  from var import var_get_by_name
  from var import var_get_by_option
  from var import var_print
  from var import env_print
  
  import var
  myargv = sys.argv[1]
  CurrentDIR = os.getcwd()

# This script will launch 3 tasks: Normal STA / Load STA Session / Start Empty PT or Tempus Shell
# If SESSION is not 0, then Load STA Session task
# If SESSION is 0 & DoNothing is 1, then Start Empty PT or Tempus Shell
# If SESSION is 0 & DoNothing is 0, then Start Normal STA

  if os.environ['DMSA'] == "0":
    Corners=[]
    if os.environ['scenario_setup_ssLVLT_m40'] == "1":  Corners=["ssgnp0p72vm40c","cworstm40c","setup"]
    if os.environ['scenario_setup_ssLVLT_ccw'] == "1":  Corners=["ssgnp0p72v0c","cworst0c","setup"]
    if os.environ['scenario_setup_ssLVHT_rcw'] == "1":  Corners=["ssgnp0p72v125c","rcworst125c","setup"]
    if os.environ['scenario_setup_ssLVHT_ccw'] == "1":  Corners=["ssgnp0p72v125c","cworst125c","setup"]
    if os.environ['scenario_setup_typ85'] == "1":       Corners=["tt0p8v85c","typical85c","setup"]
    if os.environ['scenario_hold_ssLVHT_ccb'] == "1":   Corners=["ssgnp0p72v125c","cbest125c","hold"]
    if os.environ['scenario_hold_ssLVLT_ccw'] == "1":   Corners=["ssgnp0p72vm40c","cworstm40c","hold"]
    if os.environ['scenario_hold_ssHVHT_rcw'] == "1":   Corners=["ssgnp0p9v125c","rcworst125c","hold"]
    if os.environ['scenario_hold_ffHVLT_rcb'] == "1":   Corners=["ffgnp0p88vm40c","rcbestm40c","hold"]
    if os.environ['scenario_hold_ffHVHT_rcw'] == "1":   Corners=["ffgnp0p88v125c","rcworst125c","hold"]
    if os.environ['scenario_hold_typ25'] == "1":        Corners=["tt0p8v25c","typical25c","hold"]
    if len(Corners)==3:
      os.environ['LIB']=Corners[0]
      os.environ['rcCorner']=Corners[1]
      os.environ['TYPE']=Corners[2] 
    os.environ['runID']      = os.environ['TOP']+"."+os.environ['LIB']+"."+os.environ['rcCorner']+"."+os.environ['TYPE']+"."+os.environ['Mode']+"."+os.environ['ID']+"."+os.environ['TimeStamp']+"."+os.environ['TOOL']
    if os.environ['SDC'] == "0": os.environ['SDC'] = os.environ['SdcDIR']+"/"+os.environ['TOP']+"/"+os.environ['TOP']+"."+os.environ['Mode']+".sdc"
  else:
    os.environ['runID'] = "DMSA."+os.environ['TOP']+"."+os.environ['Mode']+"."+os.environ['ID']+"."+os.environ['TimeStamp']+"."+os.environ['TOOL']

  if os.environ['DoNothing'] =="1": 
    os.environ['runID'] = "Empty." + os.environ['runID']
  elif os.environ['SESSION'] != "0":
    os.environ['runID'] = "Load." + os.environ['runID']
    os.environ['SESSION'] = CurrentDIR + "/" + os.environ['SESSION']

  os.environ['RptDIR']     = "./rpt"
  os.environ['SessionDIR'] = "./session"
  os.environ['logfile']    = "./sta.log"
  os.environ['cmdfile']    = "./sta.cmd"

  if not(os.path.isdir(CurrentDIR + "/" + os.environ['runID'])): os.system('mkdir '+ CurrentDIR + "/" + os.environ['runID'])
  os.chdir(os.environ['runID'])
  if not(os.path.isfile("./.synopsys_pt.setup")): os.system('ln -s '+os.environ['StaDIR']+'/.synopsys_pt.setup .')
  env_print("EnvVar.rpt")

  if os.environ['DoNothing'] == "1":
    PToptions = ["pt_shell", "-sgq", os.environ['SGQ'], "-f", os.environ['StaDIR'] + "/setup.tcl"]
    TEMPUSoptions = ["tempus", "-sgq", os.environ['SGQ'], "-files", os.environ['TempusDIR'] + "/Tvar.tcl","-no_gui"]
  elif os.environ['DoNothing'] != "0":
    PToptions = ["pt_shell", "-sgq", os.environ['SGQ'], "-f", os.environ['DoNothing']]
    TEMPUSoptions = ["tempus", "-sgq", os.environ['SGQ'], "-files", os.environ['DoNothing'],"-no_gui"]
  elif (os.environ['SESSION'] != "0") and (os.environ['DMSA'] == "1"):
    PToptions = ["pt_shell","-multi_scenario", "-sgq", os.environ['SGQ'], "-f ", os.environ['StaDIR']+"/load_dmsa.tcl"]
    TEMPUSoptions = ["tempus", "-sgq", os.environ['SGQ'], "-files", os.environ['TempusDIR'] + "/Tload.tcl","-no_gui"]
  elif (os.environ['SESSION'] != "0") and (os.environ['DMSA'] == "0"):
    PToptions = ["pt_shell", "-sgq", os.environ['SGQ'], "-f", os.environ['StaDIR'] + "/load.tcl"]
    TEMPUSoptions = ["tempus", "-sgq", os.environ['SGQ'], "-files", os.environ['TempusDIR'] + "/Tload.tcl","-no_gui"]
  elif os.environ['DMSA'] == "0":
    PToptions = ["pt_shell", "-sgq", os.environ['SGQ'], "-f", os.environ['StaDIR'] + "/slave.tcl"]
    TEMPUSoptions = ["tempus", "-sgq", os.environ['SGQ'], "-files", os.environ['TempusDIR'] + "/Tslave.tcl","-no_gui"]
  else:
    PToptions = ["pt_shell","-multi_scenario", "-sgq", os.environ['SGQ'], "-f ", os.environ['StaDIR']+"/master.tcl"]
    TEMPUSoptions = ["tempus", "-sgq", os.environ['SGQ'], "-files", os.environ['TempusDIR'] + "/var.tcl","-no_gui"]

  if os.environ['TOOL'] == "PT":
    call(PToptions)
  elif os.environ['TOOL'] == "TEMPUS":
    call(TEMPUSoptions)
  else:
    print('Please set -tool option to PT or TEMPUS')

if __name__ == "__main__": run_sta()
