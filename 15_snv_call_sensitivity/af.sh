#!/bin/bash -ue
DIR1="/isilon/Analysis/onco/v1_analyses/20160520_A162_multiplex_test1_subsample_rpbus500/1_subsample_8plex"
plex="8plex"

af="/home/users/fengl6/my_scripts/15_snv_call_sensitivity/af.pl"


for sample in "1" "2" "4" "5" "7" "8" "10" "11"
do

DIR="$DIR1/analysis/$sample"
cd "$DIR/snv-new"
file1=$sample.truth.whitelist.txt
file2=$sample.$plex.maf.txt

perl $af $sample $file1 $file2 $plex
done
