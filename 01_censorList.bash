grep -n 0 /Volumes/Governator/ANTISTATELONG/*/*/run*/censor.1D|
 perl -lne 'print "$1:$2:$3$4" if m:(\d{5})/(\d+)/run(\d)/.*1D(.*)\:0$:'|
 Rio -d: -nre 'df %>% group_by(V1,V2,V3) %>% summarise(n=n(),list=paste(collapse=" ",V4))' > \
 txt/censored
