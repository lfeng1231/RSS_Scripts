#!/usr/bin/env bash

source ~/.bashrc
module load rsu_sw_binaries
module load pipelines/cappmed
#module load docker

if [ "$#" -ne 5 ]
then
	echo "Need 3 command args"
	echo "sorted bam file"
	echo "slopped target bed file"
	echo "read length - 4 basepair MID length"
	exit
fi

snvcaller="/isilon/Analysis/onco/prog/CM_gitclone/ctdna-snv-caller/R/snv_caller3.r"
samtools="/isilon/Apps/site_sw/prd/RHEL7.1_x86_64/samtools/1.2/bin/samtools"
polish="/isilon/Analysis/onco/prog/CM_gitclone/ctdna-bg-polishing/filter-freq.pl"


sortedbam="$1"
targetbed="$2"
bg="$3"
white="$4"
sample="$5"

outname=${sortedbam/.sorted.bam/.dualindex-deduped.sorted.bam}
outnamedup=${sortedbam/.sorted.bam/.dualindex-deduped.duplex.sorted.bam}

# Now polish
polishout=$outname".snv.freq"
polishout=${polishout/.freq/.bg-polished.freq}
$polish $outname".snv.freq" $outnamedup".snv.freq" $bg 0.2 1 $polishout $polishout".qc"

#SNV_caller
$snvcaller $polishout $outnamedup".snv.freq" ${targetbed/.add500bp.bed/.bed} $white 0 $sample /isilon/Analysis/onco/indexes/hg38/6gene_blacklist.bed /isilon/Analysis/onco/indexes/hg38/RefSeq_Gencodev23_20160623.allexons.sorted.bed
