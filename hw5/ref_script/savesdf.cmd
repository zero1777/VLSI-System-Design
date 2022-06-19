setAnalysisMode -analysisType bcwc
write_sdf -max_view AV_max -typ_view AV_max -min_view AV_min  \
          -remashold -splitrecrem -recompute_delay_calc ../post_layout/CHIP.sdf
saveNetlist ../post_layout/CHIP.v
saveNetlist -includePowerGround ../post_layout/CHIP_pg.v
