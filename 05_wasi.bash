#!/usr/bin/env bash
set -euo pipefail
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT

#
# 20190529WF - init
#    find wasi for subjects
#
subj_list="$(cut -f 1 -d' ' txt/id_date.txt|sed "s/\(.*\)/'\1'/"|sort |uniq|tr '\n' ,|sed 's/,$//')"
qry() { psql -h arnold.wpic.upmc.edu lncddb lncd -F$'\t' -Aqtc "$@"; }
echo -e "id\tvdate\twfull2\twfull4" > txt/wasi.txt
qry "
  select
      id, to_char(vtimestamp,'YYYYmmdd') as v,
      measures->'wfull2' wfull2,
      measures->'wfull4' wfull4
  from visit_task
  natural join enroll natural join visit 
  where
   task like 'WASI' and 
   etype like 'LunaID' and
   id in ($subj_list)
   order by id, vtimestamp" >> txt/wasi.txt

echo -e "id\tvdate\trist_sum_t" > txt/rist.txt
qry "
  select
      id, to_char(vtimestamp,'YYYYmmdd') as v,
      measures->'rist_sum_tscores' rist_t
  from visit_task
  natural join enroll natural join visit 
  where
   task like 'RIST' and 
   etype like 'LunaID' and
   id in ($subj_list)
   order by id, vtimestamp" >> txt/rist.txt
