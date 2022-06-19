# Reset Clock Latency
set_interactive_constraint_modes [all_constraint_modes]
reset_clock_latency [all_clocks]

# CCOPT

set_ccopt_property buffer_cells   { CLKBUFX2 CLKBUFX3 CLKBUFX4 CLKBUFX6 CLKBUFX8 CLKBUFX12 CLKBUFX16 CLKBUFX20 }
set_ccopt_property inverter_cells { CLKINVX1 CLKINVX2 CLKINVX3 CLKINVX4 CLKINVX6 CLKINVX8 CLKINVX12 CLKINVX16 CLKINVX20 }
# set_ccopt_property clock_gating_cells { \
#    CLKAND2X2 CLKAND2X3 CLKAND2X4 CLKAND2X6 CLKAND2X8 CLKAND2X12 \
#    }
set_ccopt_property logic_cells { \
   CLKAND2X2 CLKAND2X3 CLKAND2X4 CLKAND2X6 CLKAND2X8 CLKAND2X12 \

   }
set_ccopt_property use_inverters true
set_ccopt_property update_io_latency false
create_ccopt_clock_tree_spec
# ccopt_design -cts
ccopt_design

#set_interactive_constraint_modes [all_constraint_modes]
#set_propagated_clock [all_clocks]

# ECO optimize
# setOptMode -fixCap true -fixTran true -fixFanoutLoad true
# optDesign -postCTS

# Save Design
saveDesign ../DBS/05_cts.enc
