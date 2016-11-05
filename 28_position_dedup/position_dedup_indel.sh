date
samtool="/isilon/Apps/site_sw/prd/RHEL7.1_x86_64/samtools/1.3/samtools-1.3/bin/samtools"
panel="/isilon/Analysis/onco/indexes/hg38/RUO_P2B_capture_targets.bed"
for f in *.bam
do
    bname=`basename $f`
    posbam=${bname%%.bam}.posdeduped.bam
    
    #1. create postion dedup bam
    $samtool rmdup $f $posbam
    echo -e $f
    echo -e "position dedup bam done"
    
    #2. index position dedup bam
    $samtool index $posbam
    echo -e "bam index done"
    
    #3. create position dedup freq file
    /isilon/Analysis/onco/prog/CM_gitclone/ctdna-freqgen/bam-indelfreq.pl \
	$posbam /isilon/Analysis/onco/indexes/hg38/hg38.fa \
	$panel \
	1 30 $samtool $posbam".indel.freq"
    echo -e "freq file done"
done
date
