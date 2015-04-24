#!/usr/bin/env bash

#
# find each group in folder_mask_age.txt  and run roi stats with approprate mask
#
# output files to res/$grp.txt

# what do the final processed runs look like
subjdir="../ANTISTATELONG/"
filepat="/run*/nfswkmt_functional_5.nii.gz"

[ ! -d res ] && mkdir res
for mask in masks/*+tlrc.HEAD; do
 grp=$(basename $mask +tlrc.HEAD)
 awk "(/$grp/){print \"$subjdir\" \$1 \"$filepat\"}" txt/folder_mask_age.txt  | 
   xargs -P5 -I{} bash -c "3dROIstats  -mask $mask {}"  | sort | uniq > res/$grp.txt
done

