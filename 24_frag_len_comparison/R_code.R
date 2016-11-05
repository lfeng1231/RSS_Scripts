setwd("/isilon/Analysis/onco/bioinfo_analyses/fengl6/20160728_signature_plasma_fragment_length/frag_len")
library(ggplot2)


dat<-read.table("chr1_114713909_G_T_NRAS_Q61K_plasma11_FragLen.txt", header=TRUE)
normal<-dat[(dat$Type == "reference"&(dat$Frag_Len>0)),3]
cancer<-dat[(dat$Type == "mutation"&(dat$Frag_Len>0)),3]
t.test(normal,cancer)

dat2 <- dat[dat$Frag_Len>0,c("Frag_Len","Type")]
pdf()
ggplot(dat2, aes(Frag_Len, colour=Type,..density..)) + geom_freqpoly(binwidth = 10,size=1.2) +
  xlab("fragment length (bp)") +
  ylab("frequency of reads cover the mutation") + scale_x_continuous(breaks=seq(0,400,25))+
  theme(text = element_text(size=20)) + 
  theme(legend.title=element_blank()) + 
  scale_colour_discrete(name  ="Frag_Len",
                       breaks=c("mutation", "reference"),
                       labels=c("Cancer", "Normal"))

dev.off()

###############################

setwd("/isilon/Analysis/onco/bioinfo_analyses/fengl6/20160728_signature_plasma_fragment_length/frag_out")
library(ggplot2)
files <- dir(pattern=".txt")
res <- NULL
for (fm in files){
  dat<-read.table(fm, header=TRUE)
  normal<-dat[(dat$Type == "reference"&(dat$Frag_Len>0)),3]
  cancer<-dat[(dat$Type == "mutation"&(dat$Frag_Len>0)),3]
  out <- t.test(normal,cancer)
  res <- rbind(res,c(sub("_FragLen.txt","",fm),mean(cancer),mean(normal),out$p.value))

  dat2 <- dat[dat$Frag_Len>0,c("Frag_Len","Type")]
  outname <- paste(sub("_FragLen.txt","",fm),".pdf",sep="")
  #pdf(outname,width=10,height=6)
  ggplot(dat2, aes(Frag_Len, colour=Type,..density..)) + geom_freqpoly(binwidth = 10,size=1.2) +
    xlab("fragment length (bp)") +
    ylab("frequency of reads cover the mutation") + scale_x_continuous(breaks=seq(0,400,25)) +
    theme(text = element_text(size=20)) + 
    theme(legend.title=element_blank()) + 
    scale_colour_discrete(name  ="Frag_Len",
                        breaks=c("mutation", "reference"),
                        labels=c("Cancer", "Normal"))
  ggsave(file = outname,width=10,height=6)
  #dev.off()
}
res <- as.data.frame(res)
names(res) <- c("name","mean_cancer","mean_normal","p_val")
res$mean_cancer <- as.numeric(as.vector(res$mean_cancer))
res$mean_normal <- as.numeric(as.vector(res$mean_normal))
res$p_val <- as.numeric(as.vector(res$p_val))
write.csv(res,"stat.csv")

res$diff <- res$mean_cancer - res$mean_normal
res2 <- res[res$p_val < 0.05,]
dim(res2)
#[1] 38  5
dim(res)
#[1] 69  5
sum(res2$diff<0)
#[1] 17
sum(res2$diff>0)
#[1] 21
sum(res2$dif==0)
#[1] 0


