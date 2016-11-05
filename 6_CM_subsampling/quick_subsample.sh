read_pair=5000000
reads=10M
R1=Undetermined_S0_R1_subsampled.fastq.gz
R2=Undetermined_S0_R2_subsampled.fastq.gz

seed=`echo \$RANDOM`
base1=`basename $R1 .gz`
base2=`basename $R2 .gz`
sr1=subsampled_${reads}_$base1
sr2=subsampled_${reads}_$base2
sr1_gz=${sr1}".gz"
sr2_gz=${sr2}".gz"
date
/remote/RSU/sw/seqtk/06222015/seqtk sample -s $seed $R1 $read_pair > $sr1_gz
/remote/RSU/sw/seqtk/06222015/seqtk sample -s $seed $R2 $read_pair > $sr2_gz
echo "subsampling done"
date

