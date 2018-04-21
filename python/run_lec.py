#!/usr/bin/python

def run_lec():
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
  

  if os.environ['DoNothing'] == "1":
    Options = ["lec","-LPGXL","-ultra","-nogui","-sgq",os.environ['SGQ'],"-64","-xl"]
    os.environ['runID'] = "Empty"+os.environ['TimeStamp']
  elif os.environ['SESSION'] != "0":
    Options = ["lec","-LPGXL","-ultra","-nogui","-sgq",os.environ['SGQ'],"-64","-xl","-RESTART_CHECKPOINT",os.environ['SESSION']]
    os.environ['runID'] = "Load."+os.environ['ID']+"."+os.environ['TimeStamp']
  elif os.environ['Mode'] == "g2g":
    Options = ["lec","-LPGXL","-ultra","-nogui","-sgq",os.environ['SGQ'],"-64","-xl","-dofile",os.environ['LecDIR']+"/g2g.do"]
    os.environ['runID'] = os.environ['TOPG']+"."+os.environ['Mode']+"."+os.environ['ID']+"."+os.environ['TimeStamp']
  elif os.environ['Mode'] == "rtl2g":
    Options = ["lec","-LPGXL","-ultra","-nogui","-sgq",os.environ['SGQ'],"-64","-xl","-dofile",os.environ['LecDIR']+"/rtl2g.do"]
    os.environ['runID'] = os.environ['TOPG']+"."+os.environ['Mode']+"."+os.environ['ID']+"."+os.environ['TimeStamp']
  else:
    print "Mode has to be g2g or rtl2g"
    quit()
  
  if os.environ['logfile'] == "Default.log": os.environ['logfile'] = "lec.log"
  if not(os.path.isdir(CurrentDIR + "/" + os.environ['runID'])): os.system('mkdir '+ CurrentDIR + "/" + os.environ['runID'])
  os.chdir(os.environ['runID'])
  env_print("EnvVar.rpt")

  call(Options)
  
if __name__ == "__main__": run_lec()

