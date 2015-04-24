# from table:
# http://www.jneurosci.org/content/30/46/15535/T1.expansion.html
# saved as txt/Kais26ROI.txt
library(plyr)
df <- read.table(sep="\t",'txt/Kais26ROI.txt')
names(df)<-c('ROI','Grp','x','y','z')
df$ROI <- df$ROI[(ceiling(1:nrow(df)/3)-1)*3+1 ]
ddply(df,.(Grp),function(g) write.table(g[,c('x','y','z')],file=paste0('txt/',g$Grp[1],'_tal_xyz.1D'),row.names=F, quote=F, col.names=F) )

write.table(unique(df$ROI),row.names=T,quote=F,col.names=F,file='txt/roikey.txt')

