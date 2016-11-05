#!/bin/bash -ue
DIR1="/isilon/Analysis/onco/v1_analyses/20160520_A162_multiplex_test1_subsample_rpbus500/1_subsample_8plex"
plex="8plex"

snvCaller="/isilon/Analysis/onco/prog/CM_gitclone/ctdna-snv-caller/R/snv_caller2.r"
panel="/isilon/Analysis/onco/indexes/hg38/RUO_P2B_capture_targets.bed"
truth="/isilon/Analysis/onco/cappmed_analyses/20160520_B106_multiplex_variant_detection_A106/0_merged_whitelist/new_truth.bed"
combine="/isilon/Analysis/onco/cappmed_analyses/20160520_B106_multiplex_variant_detection_A106/0_merged_whitelist/new_combine.bed"
black="/isilon/Analysis/onco/indexes/hg38/6gene_blacklist.bed"
allexons="/isilon/Analysis/onco/indexes/hg38/RefSeq_Gencodev22_20160222.allexons.sorted.bed"
whitesen="/home/users/fengl6/my_scripts/15_snv_call_sensitivity/sens_white.pl"
adaptivesen="/home/users/fengl6/my_scripts/15_snv_call_sensitivity/sens_adaptive.pl"
bedtools="/remote/RSU/sw/BEDTools/2.23.0/bin/bedtools"
exp="/isilon/Analysis/onco/cappmed_analyses/20160520_B106_multiplex_variant_detection_A106/0_merged_whitelist/new_expect_AF.txt"

rm -f "$DIR1/report_${plex}_white_sensitivity.txt"
rm -f "$DIR1/report_${plex}_adaptive_sensitivity.txt"
echo -e "Sample\tOverall\tAF=0.05%\tAF=0.25%\tAF=2.5%\t2.5%<AF<=6%\t40%<=AF<=60%\twhite_FP\tmax_FP_%AF" >> "$DIR1/report_${plex}_white_sensitivity.txt"
echo -e "Sample\tOverall\tAF=0.05%\tAF=0.25%\tAF=2.5%\t2.5%<AF<=6%\t40%<=AF<=60%\tadaptive_FP\tmax_FP_%AF" >> "$DIR1/report_${plex}_adaptive_sensitivity.txt"

for sample in "1" "2" "4" "5" "7" "8" "10" "11"
do
out1="$sample.truth"
out2="$sample.combine"

DIR="$DIR1/analysis/$sample"
mkdir -p "$DIR/snv-new3"
cd "$DIR/snv-new3"
freq=$DIR/*dualindex-deduped.sorted.bam.snv.bg-polished.freq
duplex=$DIR/*dualindex-deduped.duplex.sorted.bam.snv.freq
file1=$sample.summary_truth_call.txt
file2=$sample.report_white_sensitivity.txt
file3=$sample.summary_white_call.txt

$snvCaller $freq $duplex $panel $truth 0 $out1 $black $allexons
$snvCaller $freq $duplex $panel $combine 0 $out2 $black $allexons

#whitelist sensitivity and false positive
cut -f1-5,21,22,24,32 *truth.whitelist_all.txt > $file1
grep -v truth *combine.whitelist.txt|grep -v TP53|cut -f1-5,21,22,24,32 > $file3

perl $whitesen $sample $file1 $file2 $file3 >> "$DIR1/report_${plex}_white_sensitivity.txt"


#adaptive sensitivity and false positive
file4=$sample.adaptive.bed
file5=$sample.adaptive.filtered.bed
file6=$sample.summary_adaptive_call.txt
file7=$sample.report_adaptive_sensitivity.txt
file8=$sample.summary_adaptive_fp.txt
file9=$sample.adaptive.gen.bed
cut -f1-6,11 *truth.adaptive.txt|nohead -| awk 'BEGIN { FS = OFS = "\t" } { $(NF-5)=$2-1 FS $(NF-5); print $0 }' > $file4
$bedtools intersect -a $file4 -b $allexons -u > $file9
$bedtools intersect -a $file9 -b $panel -u > $file5

perl $adaptivesen $sample $file5 $exp $file6 $file7 $file8 $truth >> "$DIR1/report_${plex}_adaptive_sensitivity.txt"

done
