#!/bin/bash -ue
DIR1="/isilon/Analysis/onco/v1_analyses/20160520_A162_multiplex_test1_subsample_rpbus500/1_subsample_8plex"

snvCaller="/isilon/Analysis/scratch/fengl6/ctdna-snv-caller/R/snv_caller2.r"
panel="/isilon/Analysis/onco/indexes/hg38/RUO_P2B_capture_targets.bed"
truth="/isilon/Analysis/onco/cappmed_analyses/20160520_B106_multiplex_variant_detection_A106/0_merged_whitelist/truth.bed"
combine="/isilon/Analysis/onco/cappmed_analyses/20160520_B106_multiplex_variant_detection_A106/0_merged_whitelist/combined.bed"
black="/isilon/Analysis/onco/indexes/hg38/6gene_blacklist.bed"
allexons="/isilon/Analysis/onco/indexes/hg38/RefSeq_Gencodev22_20160222.allexons.sorted.bed"
sen="/home/users/fengl6/my_scripts/15_snv_call_sensitivity/sensitivity.pl"


for sample in "1" "2" "4" "5" "7" "8" "10" "11"
do
out1="$sample.truth"
out2="$sample.combine"

DIR="$DIR1/analysis/$sample"
mkdir -p "$DIR/snv-new"
cd "$DIR/snv-new"
freq=$DIR/*dualindex-deduped.sorted.bam.snv.bg-polished.freq
duplex=$DIR/*dualindex-deduped.duplex.sorted.bam.snv.freq
file1=$sample.summary_truth_call.txt
file2=$sample.sensitivity_stats.txt
file3=$sample.summary_white_call.txt

$snvCaller $freq $duplex $panel $truth 0 $out1 $black $allexons
$snvCaller $freq $duplex $panel $combine 0 $out2 $black $allexons

cut -f1-5,21,22,24,32 *truth.whitelist_all.txt > $file1
grep -v truth 1.combine.whitelist.txt|grep -v TP53|cut -f1-5,21,22,24,32 > $file3

#q1=`grep '25th percentile' "$DIR/bcDedupedQc/qc_metrics_bcdedup_depth.txt" | cut -f3 | cut -d ' ' -f 1`
#q2=`grep 'Median' "$DIR/bcDedupedQc/qc_metrics_bcdedup_depth.txt" | cut -f3 | cut -d ' ' -f 1`
#q3=`grep '75th percentile' "$DIR/bcDedupedQc/qc_metrics_bcdedup_depth.txt" | cut -f3 | cut -d ' ' -f 1`

perl $sen $sample $file1 $file2 $file3
done
