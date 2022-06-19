# Route
setNanoRouteMode -quiet -routeInsertAntennaDiode 1
setNanoRouteMode -quiet -routeAntennaCellName ANTENNA
setNanoRouteMode -quiet -routeWithTimingDriven 1
setNanoRouteMode -quiet -routeWithSiDriven 1
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true
routeDesign -globalDetail -viaOpt -wireOpt

# Check Timing
# setAnalysisMode -checkType setup
# setAnalysisMode -cppr both -analysisType onChipVariation
# setDelayCalMode -SIAware true
# timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 50 -prefix top_pipe_postRoute -outDir timingReports
# timeDesign -postRoute -hold -pathReports -slackReports -numPaths 50 -prefix top_pipe_postRoute -outDir timingReports

# ECO fix drc
# setAnalysisMode -cppr both -analysisType onChipVariation
# getNanoRouteMode -quiet -routeWithTimingDriven
# setSIMode -acceptableWNS same -fixDRC 1
# setOptMode -fixCap true -fixTran true -fixFanoutLoad true
# setDelayCalMode -engine default -siAware true
# optDesign -postRoute

# Save Design
saveDesign ../DBS/06_Route.enc
