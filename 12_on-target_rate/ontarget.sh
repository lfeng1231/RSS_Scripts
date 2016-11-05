#!/usr/bin/env bash

echo -e "adapter1"
SORTEDBAM=Sample_adapter1_cfDNA.sorted.bam
SELECTOR=RUO_P1A_capture_targets.bed
BEDTOOLS=/remote/RSU/sw/BEDTools/2.23.0/bin/bedtools
SAMBAMBA=/remote/RSU/sw/sambamba/v0.5.8/sambamba

# Output QC metrics for sorted BAM
$SAMBAMBA flagstat $SORTEDBAM > $SORTEDBAM".flagstat"
alnreads=`grep mapped ${SORTEDBAM}.flagstat | grep '(' | grep -v mate | cut -d' ' -f 1`
echo -e "Number of aligned reads\tnumber\t$alnreads" >> stats_ontarget.txt

# Output depth and on-target rate metrics: this uses the original unslopped selector
reads_on_target=`$BEDTOOLS intersect -bed -u -abam $SORTEDBAM -b $SELECTOR | wc -l | cut -d ' ' -f 1`
on_target_rate=`expr "scale=2;$reads_on_target*100 / $alnreads" | bc`
echo -e "Reads on target\tnumber\t$reads_on_target" >> stats_ontarget.txt
echo -e "On-target rate\tnumber\t$on_target_rate" >> stats_ontarget.txt


