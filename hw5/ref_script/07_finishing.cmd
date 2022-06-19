# Sign-off timing analysis
setExtractRCMode -engine postRoute
reset_parasitics
extractRC
timeDesign -reportOnly -pathReports -drvReports -slackReports -numPaths 50 -prefix CHIP -outDir timingReports

timeDesign -hold -reportOnly -pathReports -slackReports -numPaths 50 -prefix CHIP_hold -outDir timingReports


# Add Filler
getFillerMode -quiet
addFiller -cell FILL8 FILL64 FILL4 FILL32 FILL2 FILL16 FILL1 -prefix FILLER

# verify_drc
# verifyConnectivity -type all -noAntenna -error 1000 -warning 50
# verifyProcessAntenna -report top_pipe.antenna.rpt -error 1000

# Save sdf
source ../ref_script/savesdf.cmd
global dbgLefDefOutVersion
defOut -floorplan -netlist -scanChain -routing ../post_layout/Convnet_top.def

# Save gds
source ../ref_script/savegds.cmd

# Save sdc
write_sdc ../post_layout/CHIP_layout.sdc

# Save spef
setExtractRCMode -engine postRoute
reset_parasitics
extractRC
rcOut -rc_corner RC -spef ../post_layout/CHIP_layout.gz

# Save Design
saveDesign ../DBS/07_Finish.enc
