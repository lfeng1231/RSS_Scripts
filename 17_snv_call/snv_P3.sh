#!/bin/bash -ue
DIR1=$(pwd)

snvCaller="/isilon/Analysis/onco/prog/CM_gitclone/ctdna-snv-caller/R/snv_caller2.r"
panel="/isilon/Analysis/onco/indexes/hg38/RUO_P3B_capture_targets.bed"
white="/isilon/Analysis/onco/indexes/hg38/whitelist_P1.bed"
black="/isilon/Analysis/onco/indexes/hg38/6gene_blacklist.bed"
allexons="/isilon/Analysis/onco/indexes/hg38/RefSeq_Gencodev23_20160605.allexons.sorted.bed"

for sample in "Repeatability_celllineDNA_P3B_Lot1_A" "Repeatability_celllineDNA_P3B_Lot3_A"
do

DIR="$DIR1/analysis/$sample"
mkdir -p "$DIR/snv-new"
cd "$DIR/snv-new"
freq=$DIR/*dualindex-deduped.sorted.bam.snv.bg-polished.freq
duplex=$DIR/*dualindex-deduped.duplex.sorted.bam.snv.freq

#Call SNV
$snvCaller $freq $duplex $panel $white 0 $sample $black $allexons

done
