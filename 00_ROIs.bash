#!/usr/bin/env bash

#
# build ROIs in MNI from Kai's 26 Tal coords in JNuero
# coords are for adult,teen, and child
#

roirad=5
mnitmplt="/opt/ni_tools/standard_old/mni_icbm152_nlin_asym_09c/mni_icbm152_t1_tal_nlin_asym_09c_3mm.nii"

# http://www.jneurosci.org/content/30/46/15535/T1.expansion.html > txt/Kais26ROI.txt
Rscript ROIs.R

[ ! -d masks ] && mkdir masks && ln -s $mnitmplt masks/

for f in txt/*tal_xyz.1D; do
  grp=$(basename $f _tal_xyz.1D)
  mni1d=txt/${grp}_MNI_xyz.1D
  # whereami -coord_file $f -calc_chain TLRC MNI  -xform_xyz_quiet > txt/$(basename $f tal_xyz.1D)MNI_xyz.1D
  n=1
  cat $f | while read line; do 
     echo $(whereami $line -calc_chain TLRC MNI  -xform_xyz_quiet) $n
     let n++
  done > $mni1d 

  3dUndump -overwrite -prefix masks/$grp -srad $roirad -master $mnitmplt -xyz $mni1d 
done

