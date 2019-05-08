#!/usr/bin/env bash
set -euo pipefail
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT

TASKDIR=/Volumes/L/bea_res/Data/Tasks/AntiState/Basic
#
# 20190508WF - init
#    get saccade/eye timeseries
#
sed s/-//g txt/id_date.txt | while read id ymd; do
  subj_raw=$TASKDIR/$id/$ymd/Raw/
  [ ! -d $subj_raw ] && echo "${id}_$ymd has no raw?!" >&2 && continue
  find $subj_raw -iname '*.data.tsv'
done  | tar -cJvf txt/CogLong_et_ts_tsv.tar.xz -T -
