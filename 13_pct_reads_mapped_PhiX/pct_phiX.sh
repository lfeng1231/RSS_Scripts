R1_gz=Undetermined_S0_R1_001.fastq.gz
R2_gz=Undetermined_S0_R2_001.fastq.gz
R1=$(basename $R1_gz .gz)
R2=$(basename $R2_gz .gz)
BAM_PHIX=phix.bam
BAM_SORT=phix_sorted.bam
SORT_BASE=$(basename $BAM_SORT .bam)
BAM_UNMAPPED_R1=unmapped_R1.bam
BAM_UNMAPPED_R2=unmapped_R2.bam
NONPHIX_R1=non-phiX_R1.fastq
NONPHIX_R2=non-phiX_R2.fastq
SAMBAMBA=/remote/RSU/sw/sambamba/v0.5.8/sambamba

date
allreads=`zcat $R1_gz | echo \$((\`wc -l\`/2))`
echo -e "Total reads\t$allreads" >> stats_phix.txt

#unzip
date
gunzip -c $R1_gz > $R1
gunzip -c $R2_gz > $R2
echo unzip done

#BWA mem against phiX
date
/remote/RSU/sw/bwa/0.7.12/bwa mem -t 24 /isilon/Data/databases/Genomes/PhiX/NC_001422.1.fa $R1 $R2 | /remote/RSU/sw/samtools/1.2/bin/samtools view -Sb - > $BAM_PHIX
echo BWA mem done

#samtools sort and index
date
/remote/RSU/sw/samtools/1.2/bin/samtools sort -@ 24 $BAM_PHIX $SORT_BASE
/remote/RSU/sw/samtools/1.2/bin/samtools index $BAM_SORT
echo samtools sort done

#reads aligned to phiX
date
$SAMBAMBA flagstat -t 24 $BAM_SORT > $BAM_SORT"_SAMBAMBA_flagstat.txt"
phixreads=`grep mapped ${BAM_SORT}.flagstat | grep '(' | grep -v mate | cut -d' ' -f 1`
pct_phix=`expr "scale=2;$phixreads*100 / $allreads" | bc`
echo SAMBAMBA flagstat done
echo -e "Reads aligned to PhiX\t$phixreads" >> stats_phix.txt
echo -e "% PhiX reads\t$pct_phix" >> stats_phix.txt

#samtools flagstat
date
/remote/RSU/sw/samtools/1.2/bin/samtools flagstat $BAM_SORT > $BAM_SORT"_samtools_flagstat.txt"
echo Samtools flagstat done
date
