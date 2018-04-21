#!/usr/bin/python
import sys, os, string
from datetime import datetime
global VARs

def var_get_by_name(name):
  for x in range(0, len(VARs)):
    if VARs[x][1] == name:return VARs[x][2]
  return 0

def var_get_by_option(option):
  for x in range(0, len(VARs)):
    if VARs[x][0] == option:return VARs[x][2]
  return 0

def var_set_by_name(name, value):
  global VARs
  for x in range(0, len(VARs)):
    if VARs[x][1] == name: VARs[x][2] = value

def var_set_by_option(option, value):
  global VARs
  for x in range(0, len(VARs)):
    if VARs[x][0] == option: VARs[x][2] = value

def var_print(logfile):
  import sys, os
  f=open(logfile, 'w')
  for x in range(0, len(VARs)): f.write(VARs[x][1] + " = " + VARs[x][2] +"\n")
  f.close

def env_print(logfile):
  import sys, os
  f=open(logfile, 'w')
  for x in range(0, len(VARs)): f.write(VARs[x][1] + " = " + os.environ[VARs[x][1]] +"\n")
  f.close

############### MAIN Program #######################
VARs = []
t = datetime.today()
USER = os.environ['USER']

DefaultFile = "/proj/elnath1/wa/"+USER+"/scr/var.txt"
for y in range(0, len(sys.argv)):
  if sys.argv[y] == "-default": DefaultFile = sys.argv[y+1]
VARs.append(["-default", "DefaultFile", DefaultFile])
## Set VAR default
f=open(DefaultFile, 'r')
for line in f:
  line = line.rstrip('\n')
  if len(line)>1 and line[0] != "#":
    words = string.split(line," ")
    VARs.append([words[0], words[1], words[2]])
f.close

var_set_by_name("TimeStamp",     t.strftime('%Y')+t.strftime('%m')+t.strftime('%d')+t.strftime('%H')+t.strftime('%M')+t.strftime('%S'))
var_set_by_name("USER",          USER)
var_set_by_name("ScrDIR",        "/proj/elnath1/wa/"+USER+"/scr/pt")
var_set_by_name("StaDIR",        "/proj/elnath1/wa/"+USER+"/scr/pt")
var_set_by_name("SynDIR",        "/proj/elnath1/wa/"+USER+"/scr/syn")
var_set_by_name("SdcDIR",        "/proj/elnath1/wa/"+USER+"/scr/sdc")
var_set_by_name("LecDIR",        "/proj/elnath1/wa/"+USER+"/scr/lec")
var_set_by_name("MvrcDIR",       "/proj/elnath1/wa/"+USER+"/scr/mvrc")
var_set_by_name("TempusDIR",     "/proj/elnath1/wa/"+USER+"/scr/tempus")
var_set_by_name("VclpDIR",     "/proj/elnath1/wa/"+USER+"/scr/vclp")
var_set_by_name("UPFplus_DIR",   "/proj/elnath1/wa/"+USER+"/scr/mvrc")
var_set_by_name("TCL2",          var_get_by_name("StaDIR")+"/SDC.tcl")
var_set_by_name("TCL3",          var_get_by_name("StaDIR")+"/UpdateTiming.tcl")
var_set_by_name("TCL4",          var_get_by_name("StaDIR")+"/Report.tcl")
var_set_by_name("Lscr",          var_get_by_name("SynDIR")+"/"+var_get_by_name("TOP")+"_dcg.tcl")

# Update VARs value based on user input
for y in range(0, len(sys.argv)-1): var_set_by_option(sys.argv[y], sys.argv[y+1])

## Update OS Envionment variable based on VARs
for x in range(0, len(VARs)): os.environ[VARs[x][1]] = VARs[x][2]
os.environ['DESIGN_NAME']   = os.environ['TOP']
os.environ['UPFfile']       = os.environ['UPF']
os.environ['TOP_MODULE']    = os.environ['TOP']
os.environ['FLAT_ANALYSIS'] = os.environ['FLAT']

## THE END
