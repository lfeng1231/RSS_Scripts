source('/isilon/Analysis/onco/prog/lib/R/cm_utils.r')
source('/isilon/Analysis/onco/prog/lib/R/utils_basic.r')

library(ggplot2)
library(reshape2)

selector = read.delim('/isilon/Analysis/onco/designs/RUO_P1B_capture_targets.bed',header=F,as.is=T)
output="panel_1-2_punc_nopunc"
output2="sorted_panel_1-2_punc_nopunc"
sampid = "panel_1-2"
nopunc_file = "panel_1-2_withoutGTGN.dualindex-deduped.sorted.freq.paired.Q30.txt"
punc_file = "panel_1-2_withGTGN.dualindex-deduped.sorted.freq.paired.Q30.txt"

allfreqs = c()

npf = read.delim(nopunc_file,as.is=T,header=T,check.names=F)
npf = ontarget(npf,selector,points=T)
pf = read.delim(punc_file,as.is=T,header=T,check.names=F)
pf = ontarget(pf,selector,points=T)

npfvar = find_varpos(npf,afcutoff=-0.1,dcutoff=50)
names(npfvar) = sub('ALT','ALTnopunc',names(npfvar))
names(npfvar) = sub('AF','AFnopunc',names(npfvar))
pfvar = find_varpos(pf,afcutoff=-0.1,dcutoff=50)
names(pfvar) = sub('ALT','ALTpunc',names(pfvar))
names(pfvar) = sub('AF','AFpunc',names(pfvar))
m = merge(npfvar,pfvar,by=c('CHR','POS','REF'))
m$diffAF = abs(m$AFnopunc - m$AFpunc) 
m = m[order(m$diffAF,decreasing=T),]
write.table(m,file=paste0(output,'.txt'),sep='\t',row.names=F,quote=F)
m$sampno = sampid
allfreqs = m
allfreqs$diffsAF_sign = allfreqs$AFnopunc - allfreqs$AFpunc
bb = by(allfreqs,allfreqs$sampno,function(x){c(sum((x$AFnopunc > 0) & (x$AFpunc==0)),sum((x$AFnopunc == 0) & (x$AFpunc > 0)))})

final_out = allfreqs[((allfreqs$AFnopunc > 0) & (allfreqs$AFpunc==0)) | ((allfreqs$AFnopunc == 0) & (allfreqs$AFpunc > 0)),]
final_out = final_out[order(final_out$diffAF,decreasing = TRUE),]
write.table(final_out,file = paste0(output2,'.txt'),sep='\t',row.names=F,quote=F)

