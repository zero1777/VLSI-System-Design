setStreamOutMode -specifyViaName default -SEvianames false -virtualConnection false -uniquifyCellNamesPrefix false -snapToMGrid false -textSize 1 -version 3

streamOut ../post_layout/CHIP.gds -mapFile /theda21_2/library/GPDK045/gpdk045_v_6_0/soce/streamOut.map \
      -merge { /theda21_2/library/GPDK045/cur/gsclib045/gds/gsclib045.gds } \
      -units 2000 -mode ALL -uniquifyCellNames

