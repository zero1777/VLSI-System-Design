# Create path groups
createBasicPathGroups -expanded
get_path_groups

### Add Tap Cell
addWellTap -cell FILL4 -cellInterval 20 -checkerBoard

# Placement
setPlaceMode -reset
place_opt_design

# Check Placement
checkPlace top_pipe.checkPlace

# ECO optimize
# setOptMode -fixCap true -fixTran true -fixFanoutLoad true
# optDesign -preCTS

# Add Tie High/Low
addTieHiLo -cell {TIEHI TIELO} -prefix LTIE
checkDesign -tieHiLo

# Save Design
saveDesign ../DBS/04_placement.enc
