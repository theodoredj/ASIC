#!/usr/bin/python

## Note: UPFfile variable is obsolete, use UPF instead
def run_vclp():
  import sys, os
  from subprocess import call
  sys.path.append(os.path.abspath("/proj/elnath1/wa/"+os.environ['USER']+"/scr/python"))
  from var import var_get_by_name
  from var import var_get_by_option
  from var import var_print
  from var import env_print
  import var

  CurrentDIR = os.getcwd()
  os.environ['runID']      = os.environ['TOP']+".VCLP."+os.environ['ID']+"."+os.environ['TimeStamp']

  if os.environ['UPF'] == "0":
    if os.environ['PG'] == "0":
      os.environ['UPF'] = os.environ['UPF_DIR'] +"/"+ os.environ['TOP'] + ".upf"
      os.environ['runID'] = os.environ['TOP']+".VCLP.NONPG."+os.environ['ID']+"."+os.environ['TimeStamp']
    else:
      os.environ['UPF'] = os.environ['UPF_DIR'] +"/"+ os.environ['TOP'] + ".pg.upf"
      os.environ['runID'] = os.environ['TOP']+".VCLP.PG."+os.environ['ID']+"."+os.environ['TimeStamp']

  if os.environ['DoNothing'] =="1":
    os.environ['runID'] = "Empty." + os.environ['runID']
  elif os.environ['SESSION'] != "0":
    os.environ['runID'] = "Load." + os.environ['runID']
    os.environ['SESSION'] = CurrentDIR + "/" + os.environ['SESSION']

  os.environ['RptDIR']     = CurrentDIR + "/" + os.environ['runID']+"/rpt"
  os.environ['SessionDIR'] = CurrentDIR + "/" + os.environ['runID']+"/session"
  os.environ['logfile']    = CurrentDIR + "/" + os.environ['runID']+"/vclp.log"
  os.environ['cmdfile']    = CurrentDIR + "/" + os.environ['runID']+"/vclp.cmd"

  if not(os.path.isdir(CurrentDIR + "/" + os.environ['runID'])): os.system('mkdir '+ CurrentDIR + "/" + os.environ['runID'])
  os.chdir(os.environ['runID'])
  if not(os.path.isfile("./.synopsys_vcst.setup")): os.system('ln -s '+os.environ['VclpDIR']+'/.synopsys_vcst.setup .')
  env_print("EnvVar.rpt")

  if os.environ['DoNothing'] == "1":
    VCLPoptions = ["vc_static_shell", "-sgq", os.environ['SGQ']]
  elif os.environ['SESSION'] != "0":
    VCLPoptions = ["vc_static_shell", "-sgq", os.environ['SGQ'], "-f", os.environ['VclpDIR'] + "/load.tcl"]
  else:
    VCLPoptions = ["vc_static_shell", "-sgq", os.environ['SGQ'], "-f", os.environ['VclpDIR'] + "/vclp.tcl"]

  call(VCLPoptions)

if __name__ == "__main__": run_vclp()
