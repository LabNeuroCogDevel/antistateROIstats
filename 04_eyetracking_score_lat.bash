#!/usr/bin/env bash
set -euo pipefail
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT

TASKDIR=/Volumes/L/bea_res/Data/Tasks/AntiState/Basic
#
# 20190508WF - init
#    get saccade/eye timeseries
#
sed s/-//g txt/id_date.txt | while read id ymd; do
  subj_score=$TASKDIR/$id/$ymd/Scored/txt/
  [ ! -d $subj_score ] && echo "${id}_$ymd was not scored?!" >&2 && continue
  for f in $subj_score/$id.$ymd.*.trial.txt; do
     fb=$(basename $f .trial.txt)
     fb=${fb//./$'\t'}
     sed "1,1s/^/id\tymd\trun\t/;2,\$s:^:$fb\t:" $f
  done
done  | gzip -c > txt/lat_score.tsv.gz
