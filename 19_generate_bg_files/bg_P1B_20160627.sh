#!/usr/bin/env bash

module purge
module load pipelines/cappmed

freq_dir=/isilon/Analysis/onco/v1_analyses/20160626_A176_Jorge_normal_cfDNA_P1P3_H75KCBGXY_H75FTBGXY/JMD_Normal_cfDNA_Pool1/analysis
snv_dir=/isilon/Analysis/onco/v1_analyses/20160626_A176_Jorge_normal_cfDNA_P1P3_H75KCBGXY_H75FTBGXY/JMD_Normal_cfDNA_Pool1/analysis/generate_bg_P1/snv-bg
CM=/home/users/newmana3/cappmed-sandbox/CappMed_Software/cappmed-software-2.1.0/capp-scripts

for i in "CTRL10_P1_L3" "CTRL12_P1_L3" "CTRL13_P1_L3" "CTRL19_P1_L3" "CTRL1_P1_L3" "CTRL2_P1_L3" "CTRL3_P1_L3" "CTRL4_P1_L3" "CTRL6_P1_L3" "CTRL7_P1_L3" "CTRL8_P1_L3" "CTRL9_P1_L3"
do
    echo $i
    ln -s $freq_dir/$i/$i.sorted.bam.snv.freq $snv_dir/$i"_cfDNA.sorted.freq.paired.Q30.txt"
done

# make snv bg
date
perl $CM/bg-snvs.pl $snv_dir
date
echo "done"
