library(dplyr)
library(data.table)

mydata<-fread("total.fa_last.80modified",header=F, sep="\t")
colnames(mydata)<-c("query","subject","similarity","align.length","mismatch","gap","q.start","q.end","s.start","s.end","evalue","bitscore","s.len","q.len")

# # only lookat long alignment longer than 1000bp
lookat<-which(mydata$align.length  > 1000)
mydata<-mydata[lookat,]

# # only lookat LR that are mostly aligned to contigs
lookat<-which(mydata$align.length/mydata$q.len  > 0.8)
mydata<-mydata[lookat,]


# make sure q.start < q.end ####
lookat<-which(mydata$q.start >= mydata$q.end) # find the row with q.start > q.end 
tmp2<-mydata[lookat,]
tmp2$q.start2<-tmp2$q.end
tmp2$q.end2<-tmp2$q.start
tmp2$q.start<-tmp2$q.start2
tmp2$q.end<-tmp2$q.end2
tmp2<-tmp2[,1:14]

tmp<-mydata[-lookat,] # contain all the row that do not need to switch 

mydata<-rbind(tmp,tmp2)
mydata<-arrange(mydata,query)


###### identify beyond #################
# leave 10 bp give for edge/beyond alignment because of the low per-base quality of the first and last 10bp of nanopore LRs.
g=10

lookat<-which(mydata$s.start<mydata$s.end)
tmp<-mydata[lookat,]
lookat2<-which(tmp$q.start>=(tmp$s.start+g) | ((tmp$q.len-tmp$q.end-g) >= (tmp$s.len-tmp$s.end)))
beyond1<-tmp[lookat2,]

lookat<-which(mydata$s.start > mydata$s.end)
tmp<-mydata[lookat,]
lookat2<-which((tmp$q.start>=(tmp$s.len-tmp$s.start-g) )| ((tmp$q.len-tmp$q.end) >= tmp$s.end+g))
beyond2<-tmp[lookat2,]

beyond<-rbind(beyond1,beyond2)

##### identify end to end ###################
qsxyqe <- filter(mydata, q.start < q.end)

zuokaqi1 <- filter(qsxyqe, s.start <= g)
zuokaqi1 <- filter(zuokaqi1, q.start <= g)

youkaqi1 <- filter(qsxyqe, s.len - s.end <= g)
youkaqi1 <- filter(youkaqi1, q.len - q.end <= g)

edge<-rbind(zuokaqi1,youkaqi1)


# remove edge contig that is also in beyond 
lookat<-which(edge$subject %in% beyond$subject)
edge2<-edge[-lookat,]

results<- unique(edge2$subject)
results <- results[results != "" & !is.na(results)]

write.csv(results, "REF-nanopore.csv", row.names = FALSE, quote = FALSE)








