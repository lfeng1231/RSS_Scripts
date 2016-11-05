#!/usr/bin/env bash

home="/isilon/Analysis/onco/v1_analyses/20160529_A169_Cindy_feasibility_LOD/cfDNAspike-new-bg-P1-analysis"
panel500="/isilon/Analysis/onco/indexes/hg38/RUO_P1B_capture_targets.add500bp.bed"
bgfile="/isilon/Analysis/onco/indexes/hg38/P1B_snvbg_20160627.txt"
white="/isilon/Analysis/onco/bioinfo_analyses/p1_p3_normals_whitelisteval/whitelist_final_P1_20160627_bkg.txt"
polish="/home/users/fengl6/my_scripts/20_bgpolish_snvcall/polish_snvcall.sh"

#L4 P1B
dir="/isilon/Analysis/onco/v1_analyses/20160529_A169_Cindy_feasibility_LOD/LOD_pool_04_P1B/analysis"

for sample in "LOD_pool_04_cfDNA_spikein_mix1_panel1_rep1" 
do
    subdir="$home/$sample"
    rm -rf $subdir
    mkdir -p $subdir
    ln -s "$dir/$sample/${sample}.sorted.bam" $subdir
    ln -s "$dir/$sample/${sample}.dualindex-deduped.sorted.bam.snv.freq" $subdir
    ln -s "$dir/$sample/${sample}.dualindex-deduped.duplex.sorted.bam.snv.freq" $subdir
    cd $subdir
    $polish "$subdir/${sample}.sorted.bam" $panel500 $bgfile $white $sample
done
