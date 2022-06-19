
//setup mode

set system mode setup

set log file lec.log -replace

setenv TOP_DESIGN DNN_MMAP


read design -file golden.f -golden -verilog2k
read design -file revised.f -revised

set flatten model -gated_clock
set flatten model -seq_constant

set root module $TOP_DESIGN -golden
set root module $TOP_DESIGN -revised

