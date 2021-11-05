 #!/bin/bash
CC="cloudcompare.CloudCompare"

GT="gt/model_10mm_$2.ply"
echo "*** Computing accuracy ***"
$CC -silent -auto_save OFF -C_EXPORT_FMT PLY \
  -o $1 \
  -crop -2:-2:-1:14:14:7 \
  -SS SPATIAL 0.01 \
  -o $GT  \
  -REMOVE_ALL_SFS \
  -c2c_dist \
  -pop_clouds \
  -SF_COLOR_SCALE cmap.xml \
  -SF_CONVERT_TO_RGB false \
  -SS SPATIAL 0.01 \
  -save_clouds file "${1%.*}-acc.ply"
  
echo "*** Computing completeness ***"  
$CC -silent -auto_save OFF -C_EXPORT_FMT PLY \
  -o $GT \
  -o $1  \
  -crop -2:-2:-1:14:14:7 \
  -REMOVE_ALL_SFS \
  -c2c_dist \
  -pop_clouds \
  -SF_COLOR_SCALE cmap.xml \
  -SF_CONVERT_TO_RGB false \
  -save_clouds file "${1%.*}-comp.ply"