date
samtool="/isilon/Apps/site_sw/prd/RHEL7.1_x86_64/samtools/1.3/samtools-1.3/bin/samtools"
for f in "/isilon/Analysis/onco/v1_analyses/20160906_A202_ML_FFPE_PolishInFrag/Polishing2/analysis/HM_Polish1x37_10/bams/HM_Polish1x37_10.sorted.bam" \
	     "/isilon/Analysis/onco/v1_analyses/20160906_A202_ML_FFPE_PolishInFrag/Polishing2/analysis/HM_Polish1x37_50/bams/HM_Polish1x37_50.sorted.bam" \
	     "/isilon/Analysis/onco/v1_analyses/20160906_A202_ML_FFPE_PolishInFrag/Polishing2/analysis/HM_Polish3x50_10/bams/HM_Polish3x50_10.sorted.bam" \
	     "/isilon/Analysis/onco/v1_analyses/20160906_A202_ML_FFPE_PolishInFrag/Polishing2/analysis/HM_Polish3x50_50/bams/HM_Polish3x50_50.sorted.bam"
do
    bname=`basename $f`
    $samtool rmdup $f ${bname%%.bam}.posdeduped.bam
done
date
for f in *.posdeduped.bam
do
    $samtool index $f
done
date
