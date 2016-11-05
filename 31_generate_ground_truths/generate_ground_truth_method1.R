source('/isilon/Analysis/onco/prog/CM_gitclone/ctdna-ground-truth-1.0/R/define_truth_set.r')

#testfiles = Sys.glob(paste0('/isilon/Analysis/onco/projects/ctDNA_RUO_V1/',
#							'pipeline_runs/20161030_A258_BM_TPVmaterialcheck2/',
#							'20161028_BMpool3/analysis/LODsample*/',
#							'*.dualindex-deduped.sorted.bam.snv.bg-polished.freq'))

testfiles = Sys.glob('/isilon/Analysis/onco/bioinfo_analyses/fengl6/20161025_TPV_sample_verification/3_SNV_truth_set/bgPolished_freq/*.bg-polished.freq')

selector = read.delim('/isilon/Analysis/onco/indexes/hg38/RUO_P2B_capture_targets.bed',
					                        header=F,as.is=T)

dd1 = define_truth_set(testfiles,selector,
      mixes=list(expAF2.1=c(`Donor1_LODsample17`=0.98,`Donor2_LODsample18`=0.01,`Donor3_LODsample19`=0.01),
                 expAF2.2=c(`Donor1_LODsample17`=0.996,`Donor2_LODsample18`=.002,`Donor3_LODsample19`=.002)),
      outprefix='truth_123',distfile='123_AFdistsDE_all_.pdf',
      sampcapture='(.*).dualindex-deduped.sorted.bam.snv.bg-polished.freq',
      remove_triallelic=T)
