set power_enable_analysis true
set power_analysis_mode time_based
set power_enable_clock_scaling true

set search_path ". /theda21_2/library/GPDK045/cur/gsclib045/db/  \
                   /theda21_2/library/GPDK045/cur/gsclib045/verilog/ \
                   /usr/cad/synopsys/synthesis/cur/libraries/syn/ \
                   $search_path"
set target_library  "slow_vdd1v2_basicCells.db \
                     fast_vdd1v2_basicCells.db "
set link_library  "  * $target_library  \
                       dw_foundation.sldb "
read_verilog  ../../post_layout/CHIP.v
current_design  DNN_MMAP
link
read_sdc ../../post_layout/CHIP_layout.sdc
# read spef here
read_parasitics ../../post_layout/CHIP_layout.gz
# read waveform
read_vcd -rtl ../../pre_layout/rtl/testbench.fsdb -strip_path testbench/top/dnn_mmap

check_power
update_power
report_power  -hier > report_power_hier.rpt
report_power  > pre_sim_power_report.rpt
exit
