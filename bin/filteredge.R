args <- commandArgs(trailingOnly = TRUE)
illumina_read_length <- as.numeric(args[1])


library(dplyr)

# 0 part
data <- read.table("02daitotal.txt")
colnames(data) <- c("contig", "start")
daxiao <- read.table("contigsize.txt", header = FALSE)
colnames(daxiao) <- c("contig", "daxiao")
merge <- merge(data, daxiao, by = "contig")
merge$start <- as.numeric(merge$start)
merge$end <- merge$start + illumina_read_length  # end
#print(str(merge))  # type
#print(class(merge$end))  # end type

names<-unique(merge$contig)

# filter
beyond0 <- filter(merge, daxiao < end - 3)
beyond0.contig<-unique(beyond0$contig)

edge <- filter(merge, abs(daxiao - end) < 2)
tmp<-data.frame(table(edge$contig))
tmp<-filter(tmp,Freq>=5)

edge.contig<-as.character(tmp$Var1)

names.p<-intersect(names,edge.contig)
lookat<-which(!(names.p %in% beyond0.contig))
names.p<-names.p[lookat]

#influent0 <- beyond0[,-(2:4)]
#unique0 <- unique(influent0)
#write.csv(unique0, "total0.csv")

# 16 part
data <- read.table("162daitotal.txt", header = FALSE)
colnames(data) <- c("contig", "start")
data <- as.data.frame(data)
daxiao <- read.table("contigsize.txt", header = FALSE)
colnames(daxiao) <- c("contig", "daxiao")
merge <- merge(data, daxiao, by = "contig")

merge$end <- merge$start - illumina_read_length  # end

# filter
beyond1 <- filter(merge, end + 3 <0)
beyond1.contig<-unique(beyond1$contig)

edge1 <- filter(merge, end > -2 & end < 2)
tmp<-data.frame(table(edge1$contig))
tmp<-filter(tmp,Freq>=5)
edge1.contig<-as.character(tmp$Var1)

names.n<-intersect(names,edge1.contig)

lookat<-which(!(names.n %in% beyond1.contig))
names.n<-names.n[lookat]

result<-unique(c(names.p,names.n))



write.csv(result, "total.csv",  row.names = FALSE, quote = FALSE)









