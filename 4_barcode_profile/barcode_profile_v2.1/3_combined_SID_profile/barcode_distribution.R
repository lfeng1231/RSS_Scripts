rm(list=ls())
dat <- read.table("SID_counts.txt",header=F)
expected <- dat[1:24,]
unexpected <-dat[25:nrow(dat),]
total <- sum(dat[,4])

#plot expected SID
pdf("Expected_SID_distribution.pdf")
cols <- c("gray", "dark blue")[(expected[,3] == "expected_used") + 1]
idx <- expected[,4]
names(idx) <- expected[,2]
barplot(idx/total*100, col = cols, xlab="Expected SIDs", ylab="Percentage over total observed SID (%)")
legend("topright",fill=c("dark blue","gray"),c("Used in the experiment","Nsot used in the experiment"))
dev.off()

#plot unexpected SID
pdf("Unexpected_SID_distribution.pdf")
seq <-unexpected[,4]
plot(seq/total*100,type="p",pch=16,cex=0.5,xlab="Unexpected SID", ylab="Percentage over total observed SID (%)")
dev.off()
