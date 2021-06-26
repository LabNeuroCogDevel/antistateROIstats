#!/usr/bin/env bash

#
# find each group in folder_mask_age.txt  and run roi stats with approprate mask
#
# output files to res/$grp.txt

# what do the final processed runs look like
subjdir="/Volumes/Governator/ANTISTATELONG/"
filepat="/run*/nfswkmt_functional_5.nii.gz"

#bash expands to 4 runs so xargs will overfill bash arg max in 3dRIOstats
# unless we further restrict the size
size=$(echo $(getconf ARG_MAX)/4.4 | bc ) 

[ ! -d res ] && mkdir res
for mask in masks/*+tlrc.HEAD; do
 grp=$(basename $mask +tlrc.HEAD)
 echo "#  $grp   $(date)"
 awk "(/$grp/){print \"$subjdir\" \$1 \"$filepat\"}" txt/folder_mask_age.txt  | 
  parallel --bar -s $size -n 10 -j 10  "echo 3dROIstats  -mask $mask {}|bash "  |
  sed '2,${/^File/d}' > res/$grp.txt
  #xargs -P5 -I{} bash -c "3dROIstats  -mask $mask {}"  | sort | uniq > res/$grp.txt # in parellel corrupts lines :(
  # installd parallel instead
done

# sep "File" path into Subj Date and Run
# remove [?]
# ...reduces file size by 5MB :)
perl -ipne '
s/File/Subj\tDate\tRun/; 
s:^\..*/(\d{5})/(\d{6})\d+/run(\d+)/n.*nii.gz:\1\t\2\t\3:;
s:\[\?\]::;
' res/*txt
