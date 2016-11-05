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

#extract unmapped paired reads
date
/remote/RSU/sw/samtools/1.2/bin/samtools view -@ 24 -b -f 77 $BAM_SORT > $BAM_UNMAPPED_R1
/remote/RSU/sw/samtools/1.2/bin/samtools view -@ 24 -b -f 141 $BAM_SORT > $BAM_UNMAPPED_R2
echo extract unmapped done

#extract fastq files
date
/remote/RSU/sw/samtools/1.2/bin/samtools bam2fq $BAM_UNMAPPED_R1 > $NONPHIX_R1
/remote/RSU/sw/samtools/1.2/bin/samtools bam2fq $BAM_UNMAPPED_R2 > $NONPHIX_R2
echo extract non-PhiX fastq done
date
#qsub -q normal.q -pe smp 24 -V -j y -cwd remove_phiX.sh
