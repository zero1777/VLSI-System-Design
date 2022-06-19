# Floor Plan -r <H/W Utilization Margin<left bottom right top>>
# see $innovus> man floorPlan
floorPlan -site CoreSite -r 1 0.7 35.5 35.5 35.5 35.5
fit

# load io constraint
loadIoFile ../pre_layout/netlist/DNN_MMAP.save.io

# Automatic Plan Design
# setPlanDesignMode -effort high -incremental false -boundaryPlace true -fixPlacedMacros false -noColorize false
# planDesign

# Initial Placement 
setPlaceMode -reset
setPlaceMode -place_design_floorplan_mode true
place_design
refinePlace -checkRoute 1 

# Early Global Route
earlyGlobalRoute

# Save Design
saveDesign ../DBS/02_floorplan.enc