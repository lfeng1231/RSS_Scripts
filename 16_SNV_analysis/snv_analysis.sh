#!/bin/bash -ue
DIR1="/isilon/Analysis/onco/v1_analyses/20160529_A169_Cindy_feasibility_LOD/LOD_pool_03_SNV_cfDNAspike_P2B"

snvCaller="/isilon/Analysis/onco/prog/CM_gitclone/ctdna-snv-caller/R/snv_caller2.r"
panel="/isilon/Analysis/onco/indexes/hg38/RUO_P2B_capture_targets.bed"
truth="/home/users/fengl6/my_scripts/16_SNV_analysis/EEP_32CancerSNVmix_May5_2016.truth.hg38.txt"
white="/isilon/Analysis/onco/indexes/hg38/whitelist_final_P2_excluded.bed"
black="/isilon/Analysis/onco/indexes/hg38/6gene_blacklist.bed"
allexons="/isilon/Analysis/onco/indexes/hg38/RefSeq_Gencodev23_20160527.allexons.sorted.bed"
sens="/home/users/fengl6/my_scripts/16_SNV_analysis/sensitivity.pl"
bedtools="/remote/RSU/sw/BEDTools/2.23.0/bin/bedtools"

mkdir -p "$DIR1/SNV_analysis"
rm -f "$DIR1/SNV_analysis/all_TP_P2B.txt"
rm -f "$DIR1/SNV_analysis/all_FN_P2B.txt"
rm -f "$DIR1/SNV_analysis/all_variants_P2B.txt"
rm -f "$DIR1/SNV_analysis/all_sensitivity.txt"
echo -e "Sample\tEAF%\tSensitivity" >> "$DIR1/SNV_analysis/all_sensitivity.txt"


for sample in "0.13_panel2_rep1" "0.25_panel2_rep1" "0.5_panel2_rep1" "0.5_panel2_rep2" "1.5_panel2_rep1" "1.5_panel2_rep2"
do

DIR="$DIR1/analysis/LOD_pool_03_SNV_$sample"
mkdir -p "$DIR/snv-new"
cd "$DIR/snv-new"
freq=$DIR/*dualindex-deduped.sorted.bam.snv.bg-polished.freq
duplex=$DIR/*dualindex-deduped.duplex.sorted.bam.snv.freq

vcf="horizon_$sample.vcf"
out1="horizon_$sample.TP.txt"
out2="horizon_$sample.FN.txt"
out3="horizon_$sample.variants_table.txt"
out4="horizon_$sample.sensitivity.txt"

#Call SNV
$snvCaller $freq $duplex $panel $white 0 "horizon_$sample" $black $allexons

#Calculate sensitivity
perl $sens $sample $vcf $truth $out1 $out2 $out3 $out4 >> "$DIR1/SNV_analysis/all_sensitivity.txt"

cat "horizon_$sample.TP.txt" >> "$DIR1/SNV_analysis/all_TP_P2B.txt"
cat "horizon_$sample.FN.txt" >> "$DIR1/SNV_analysis/all_FN_P2B.txt"
cat "horizon_$sample.variants_table.txt" >> "$DIR1/SNV_analysis/all_variants_P2B.txt"

done
