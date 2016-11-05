#/isilon/Analysis/onco/prog/CM_gitclone/ctdna-freqgen/bam-snvfreq.pl
#    <Sorted BAM file>
#    <Absolute path to genome sequence in fasta format> 
#    <Target BED file>
#    <Consider properly paired reads only 1-YES, 0-NO>
#    <Phred quality cutoff 30>
#    <1=Consider single stranded families, 2=Consider families with duplex support only>
#    <minimum number of copies per family; if 1, 2X + singletons; if >1, minimum copies per family>
#    <Absolute path to samtools binary v1.0.0+>
#    <Absolute path to output freq file>

samtool="/isilon/Apps/site_sw/prd/RHEL7.1_x86_64/samtools/1.3/samtools-1.3/bin/samtools"

for f in *.posdeduped.bam
do
    /isilon/Analysis/onco/prog/CM_gitclone/ctdna-freqgen/bam-snvfreq.pl \
    	$f /isilon/Analysis/onco/indexes/hg38/hg38.fa \
	/isilon/Analysis/onco/indexes/hg38/RUO_P1B_capture_targets.bed \
	1 30 1 1 $samtool $f".freq"
done
