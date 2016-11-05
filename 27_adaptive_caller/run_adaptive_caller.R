rm(list=ls())
setwd("/isilon/Analysis/onco/bioinfo_analyses/fengl6/20160826_tissue_tech_review/5_FFPE_position_deduped/2_adaptive_call_with_position_dedup")
#library(parallel)
source('/isilon/Analysis/onco/prog/lib/R/cm_utils.r')

# Reference data to be released with CappMed pipeline
# genome, background DB, whitelist etc.
source('/isilon/Analysis/onco/prog/CM_gitclone/ctdna-snv-caller/R/snv_caller2.r')

index='/isilon/Analysis/onco/indexes/hg38/'


freqs=Sys.glob("*.deduped.bam.snv.freq")
duplex=NULL
targets=paste0(index,"/RUO_P1B_capture_targets.bed")
targetsdf=read.delim(targets,as.is=T,check.names=F,header=F)
maxerrorpersub=0
wlst=paste0(index,"whitelist_P2.txt") 
blacklist=paste0(index,"6gene_blacklist.bed")
exons=paste0(index,"/RefSeq_Gencodev23_20160623.allexons.sorted.bed")
volbyml=4
mindepth=20
afcutoff_for_regfuncs=.3
maxitordepth=6
maxAF=1
emitall=F

depths = list()
ss = list()
for (f in freqs)
{
	print(f)
	outname = sub('.deduped.bam.snv.freq','',f)
	freq = read.delim(f,check.names=F,as.is=T)
	freqontarg = ontarget(freq,targetsdf)
	depths[[outname]] = quantile(freqontarg$DEPTH,c(.05,.5,.95))

	#ss[[outname]] = 
	res <- adaptive_caller(f,maxerrorpersub,targets,
					germlinesnps=NULL,duplex=duplex,
					mindepth=mindepth,maxAF=maxAF,
					blacklist=blacklist,exons=exons,
					afcutoff_for_regfuncs=afcutoff_for_regfuncs,
					maxitordepth=maxitordepth,
					emitall=emitall)

	write.table(res[[1]], paste(outname,".adaptive.txt",sep=""),sep="\t",quote=F)
}







