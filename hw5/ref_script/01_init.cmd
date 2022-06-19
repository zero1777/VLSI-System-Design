set init_verilog ../pre_layout/netlist/dnn_syn.v
set init_top_cell DNN_MMAP
set init_io_file ../pre_layout/netlist/DNN_MMAP.save.io
set init_lef_file { \
    /theda21_2/library/GPDK045/cur/gsclib045/lef/gsclib045_tech.lef \
    /theda21_2/library/GPDK045/cur/gsclib045/lef/gsclib045_macro.lef }
set init_gnd_net VSS
set init_pwr_net VDD
set init_mmmc_file ../pre_layout/netlist/mmmc.view

init_design
setDesignMode -process 45

# Connect Global Nets
clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -instanceBasename *
globalNetConnect VSS -type pgpin -pin VSS -instanceBasename *

# Save design
saveDesign ../DBS/01_init.enc 