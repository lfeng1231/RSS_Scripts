source('/isilon/Analysis/onco/prog/CM_gitclone/ctdna-ground-truth-1.0/R/define_truth_set.r')

testfiles = Sys.glob(paste0('/isilon/Analysis/onco/projects/ctDNA_RUO_V1/',
							'pipeline_runs/20161030_A258_BM_TPVmaterialcheck2/',
							'20161028_BMpool3/analysis/LODsample*/',
							'*.dualindex-deduped.sorted.bam.snv.bg-polished.freq'))

#testfiles = Sys.glob('/isilon/Analysis/onco/bioinfo_analyses/fengl6/20161025_TPV_sample_verification/3_SNV_truth_set/bgPolished_freq/*.bg-polished.freq')


# This is bizarre but the sample names are sequential and numbers don't match the donor numbers
# Here's the mapping
mapping = as.list(paste0('LODsample',17:24))
names(mapping) = paste0('Donor',c(1:3,6:10))

selector = read.delim('/isilon/Analysis/onco/indexes/hg38/RUO_P2B_capture_targets.bed',
					                        header=F,as.is=T)

mix1 = c(0.98,.01,.01)
mix2 = c(0.996,.002,.002)

names(mix1) = c(mapping[['Donor1']],mapping[['Donor2']],mapping[['Donor3']])
names(mix2) = c(mapping[['Donor1']],mapping[['Donor2']],mapping[['Donor3']])
dd1 = define_truth_set(testfiles,selector,
      mixes=list(expAF.1=mix1,expAF.2=mix2),
      outprefix='truth1_2_3',distfile='1_2_3_AFdists.pdf',
      sampcapture='(.*).dualindex-deduped.sorted.bam.snv.bg-polished.freq',
      remove_triallelic=T)

