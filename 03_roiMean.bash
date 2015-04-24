#!/usr/bin/env bash

#
# find each group in folder_mask_age.txt  and run roi stats with approprate mask
#
# output files to res/

subjdir="../ANTISTATELONG/"
[ ! -d res ] && mkdir res
for mask in masks/*+tlrc.HEAD; do
 grp=$(basename $mask +tlrc.HEAD)
 awk "(/$grp/){print \"$subjdir\" \$1 \"/run*/nfswkmt_functional_5.nii.gz\"}" txt/folder_mask_age.txt  | 
  xargs 3dROIstats -prefix res/$grp.txt -mask $mask
done

