 #!/bin/bash
CC="cloudcompare.CloudCompare"

GT="gt/wageningen2_garden_10mm_binary_downsampled.ply"
echo "*** Computing accuracy ***"
$CC -silent -auto_save OFF -C_EXPORT_FMT PLY \
  -o $1 \
  -crop -9:-9:-2:10:7:4 \
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
  -crop -9:-9:-2:10:7:4 \
  -REMOVE_ALL_SFS \
  -c2c_dist \
  -pop_clouds \
  -SF_COLOR_SCALE cmap.xml \
  -SF_CONVERT_TO_RGB false \
  -save_clouds file "${1%.*}-comp.ply"