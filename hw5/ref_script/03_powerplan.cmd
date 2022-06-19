# Add Core Ring
setAddRingMode -ring_target default
addRing -nets {VDD VSS} -type core_rings -layer {top Metal9 bottom Metal9 left Metal8 right Metal8} \
    -width 4 -spacing 1.5 -offset 2 \
    -use_wire_group 1 -use_wire_group_bits 3 -use_interleaving_wire_group 1

# Create Power Stripe
setAddStripeMode -extend_to_closest_target ring -spacing_type edge_to_edge \
    -stacked_via_top_layer Metal9 -stacked_via_bottom_layer Metal6
addStripe -nets { VDD VSS } -layer Metal6 -direction vertical -width 0.44 -spacing 0.5 -set_to_set_distance 14 \
    -start_from left -start_offset 5 -stop_offset 5 -merge_stripes_value auto 
setAddStripeMode -break_at {none} -extend_to_closest_target ring -spacing_type edge_to_edge \
    -stacked_via_top_layer Metal9 -stacked_via_bottom_layer Metal6
addStripe -nets { VDD VSS } -layer Metal7 -direction horizontal -width 0.44 -spacing 0.5 -set_to_set_distance 14 \
    -start_from bottom -start_offset 5 -stop_offset 5 -merge_stripes_value auto 

# Connect Follow Pin 
setSrouteMode -viaConnectToShape { ring stripe blockring blockpin }
sroute -connect {corePin} -allowJogging 0 -crossoverViaLayerRange { Metal1(1) Metal6(6) } \
    -nets { VDD VSS } 

# Save Design
saveDesign ../DBS/03_powerplan.enc
saveFPlan ../DBS/powerplan.fp
