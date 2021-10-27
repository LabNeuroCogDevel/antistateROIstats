#!/usr/bin/env bash
set -euo pipefail
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT

TASKDIR=/Volumes/L/bea_res/Data/Tasks/AntiState/Basic
#
# 20211027WF - record task version (as noted by eprime log output)
#   combine with txt/Anti_Mix_Design_Lists_FINAL_minusfix_fixblockrecord_FINMOD.xls
#   for MR timing

echo "id ymd run task_version session_time" > txt/task_version.txt
sed s/-//g txt/id_date.txt | while read id ymd; do
  subj_score=$TASKDIR/$id/$ymd/Raw/Eprime/
  [ ! -d $subj_score ] && echo "${id}_$ymd has no eprimefiles?!" >&2 && continue
  files=(/Volumes/L/bea_res/Data/Tasks/AntiState/Basic/$id/$ymd/Raw/Eprime/*AntiVGSMix*txt)

  # check first file. if no matches will be the glob
  [ ! -r "$files" ] && echo "WARNING: no matches $files" >&2 && continue
  grep SessionTime ${files[@]} -m1|
     while IFS=: read file junk time; do
        echo "$file" >&2
        # skip incomplete. expect 944 lines in log file
        [ $(wc -l < "$file") -lt 900 ] && continue
        # extract counterbalence version by basename and removeing all after first _
        # should be like '2VA'
        f=${file//*\//} 
        f=${f//_*}
        # spit out useful info. caputure time incase our sort fails
        # also remove the DOS crlf \r from the time component
        echo $id $ymd $f ${time//\r/}
     done | sort -k2,2 -t' '| awk '{print $1, $2, NR, $3, $4}'
done  >> txt/task_version.txt
