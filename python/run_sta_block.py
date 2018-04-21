#!/usr/bin/python

import sys, os, string
from subprocess import call
sys.path.append(os.path.abspath("/proj/elnath1/wa/"+os.environ['USER']+"/scr/python"))
from run_sta import run_sta

myargv = sys.argv[1]
Options = ["-top","toptop","-sgq","normal:32m:2c"]


if (myargv == "help") or (myargv == "-help"):
  print "Help is coming...."
  quit()
elif myargv == "typ25":
  Options.extend( ["-lib","tt0p8v25c","-rc","typical25c"] )
elif myargv == "typ85":
  Options.extend( ["-lib","tt0p8v85c","-rc","typical85c"] )
elif myargv == "slown10_10":
  Options.extend( ["-lib","slow0p81vn10","-rc","cworstn10"] )
elif myargv == "slow125_10":
  Options.extend( ["-lib","slow0p81v125","-rc","rcworst125"] )
elif myargv == "slown10_11":
  Options.extend( ["-lib","slow0p81vn10","-rc","cworstn10"] )
elif myargv == "slow125_11":
  Options.extend( ["-lib","slow0p81v125","-rc","rcworst125"] )
elif myargv == "fastn40_11":
  Options.extend( ["-lib","fast0p99vn40","-rc","rcbestn40"] )
elif myargv == "fast125_11":
  Options.extend( ["-lib","fast0p99v125","-rc","cbest125"] )
elif myargv == "dmsa":
  Options.extend( ["-dmsa","1","-flat","0","-mode","postCTS_scanshift_TDF","-scenario_all","1","-ice","0",
             "-TCL1","NONE","-libset","/proj/elnath1/wa/jundong/libset20160829_ND1216"] )
elif myargv == "dmsa_FUNC":
  Options.extend( ["-dmsa","1","-flat","0","-mode","postCTS","-scenario_all","1","-ice","0",
             "-TCL1","NONE","-libset","/proj/elnath1/wa/jundong/libset20160829_ND1216"] )
elif myargv == "dmsa_TDF":
  Options.extend( ["-dmsa","1","-flat","0","-mode","TDF","-scenario_all","1","-ice","0"] )
elif myargv == "dmsa_sdf":
  Options.extend( ["-mode","postCTS","-id","SDF","-sdf","-TCL4","NONE","-TCL3","NONE",
             "-scenario_slow125_10","-scenario_fastn40_11","-scenario_fast125_11","-scenario_slown10_10","-scenario_typ110_11"] )
elif myargv == "dmsa_nand":
  Options.extend( ["-dmsa","1","-flat","0","-mode","NAND",
             "-TCL2","/proj/elnath1/wa/jundong/scr/pt/SDC.NAND.tcl","-TCL3","NONE","-TCL4","NONE",
             "-scenario_slow125_11","1","-scenario_fastn40_11","1","-scenario_fast125_11","1","-scenario_slown10_11","1","-scenario_typ110_11","1",
             "-libset","/proj/elnath1/wa/jundong/libset20160829_ND1216"] )
elif myargv == "load_slown10_10":
  Options.extend( ["-top","u_be_top","-m9","1","-id","postCTS","-lib","slow0p81vn10","-rc","cworstn10","-xtalk","1","-ocv","0",
             "-session","DMSA.u_be_top.postCTS.Normal.0420225200/postCTS_slow0p81vn10_cworstn10_1_0/session"] )
elif myargv == "load_slow125_10":
  Options.extend( ["-top","u_be_top","-m9","1","-id","postCTS","-lib","slow0p81v125","-rc","rcworst125","-xtalk","1","-ocv","0",
             "-session","DMSA.u_be_top.postCTS_scanshift.Normal.0619120514/postCTS_slow0p81v125_rcworst125_1_0/session"] )
elif myargv == "load_fast125_11":
  Options.extend( ["-top","u_be_top","-m9","1","-id","postCTS","-lib","fast0p99v125","-rc","cbest125","-xtalk","1","-ocv","1",
             "-session","DMSA.u_be_top.postCTS.Normal.0701211404/postCTS_fast0p99v125_cbest125_1_1/session"] )
elif myargv == "load_slow125_nand":
  Options.extend( ["-top","u_be_top","-m9","1","-id","NAND","-lib","slow0p81v125","-rc","rcworst125","-xtalk","1","-ocv","1",
             "-session","DMSA.u_be_top.NAND.Normal.0625174051/NAND_slow0p81v125_rcworst125_1_1/session"] )
elif myargv == "load_fast125_nand":
  Options.extend( ["-top","u_be_top","-m9","1","-id","NAND","-lib","fast0p99v125","-rc","cbest125","-xtalk","1","-ocv","1",
             "-session","DMSA.u_be_top.NAND.Normal.0622114535/NAND_fast0p99v125_cbest125_1_1/session"] )
elif myargv == "load_dmsa":
  Options.extend( ["-dmsa","1","-flat","0","-mode","postCTS","-scenario_all","1","-session","DMSA.u_be_top.postCTS_scanshift_TDF.Normal.1220233459"] )
elif myargv == "load_empty":
  Options.extend( ["-dono","1","-id","NONE","-lib","slow0p81v125","-rc","rcworst125","-xtalk","0","-ocv","0"] )

for x in range (0, len(Options)): sys.argv.insert(x+1,Options[x])
run_sta()
