#!/usr/bin/env bash
childagemax=12.9
teenagemax=19.9


ls -d ../ANTISTATELONG/1*/*/|perl -lne 'print "$1 20$2-$3-$4" if m:(\d{5})/(\d{2})(\d{2})(\d{2}):' > txt/id_date.txt

mysql -uroot lncddb3 -NBe "
CREATE TEMPORARY TABLE tempid ( id INT, vd DATE);
LOAD DATA LOCAL INFILE 'txt/id_date.txt'
 INTO TABLE tempid FIELDS TERMINATED BY ' ' (id,vd) ;

select 
 concat(t.id,'/', date_format(t.vd,'%y%m%d*')) as d,
 age,
 CASE WHEN age<=$childagemax THEN 'Children'
      WHEN age<=$teenagemax  THEN 'Teenagers'
      WHEN age>$teenagemax   THEN 'Adults'
 END as mask
  
from tempID as t 
 left join peopleEnroll e on e.value = t.id
 left join visits v on
 v.visitdate = t.vd and e.peopleid=v.peopleid;
" > txt/folder_mask_age.txt 
