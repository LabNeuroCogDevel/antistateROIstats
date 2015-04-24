#!/usr/bin/env bash

roirad=5
mnitmplt="$HOME/standard/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_3mm.nii"

# http://www.jneurosci.org/content/30/46/15535/T1.expansion.html > txt/Kais26ROI.txt
Rscript ROIs.R

[ ! -d masks ] && mkdir masks && ln -s $mnitmplt masks/

for f in txt/*tal_xyz.1D; do
  grp=$(basename $f _tal_xyz.1D)
  mni1d=txt/${grp}_MNI_xyz.1D
  # whereami -coord_file $f -calc_chain TLRC MNI  -xform_xyz_quiet > txt/$(basename $f tal_xyz.1D)MNI_xyz.1D
  cat $f | while read line; do 
     whereami $line -calc_chain TLRC MNI  -xform_xyz_quiet
  done > $mni1d 

  3dUndump -prefix masks/$grp -srad $roirad -master $mnitmplt -xyz $mni1d 
done

