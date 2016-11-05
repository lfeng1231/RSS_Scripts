
fastqc="/isilon/Analysis/scratch/fengl6/NimbleGen_SeqCap_workflow/sw/fastqc_v0.11.3/fastqc"

$fastqc --nogroup --extract -o fastqc Undetermined_S0_R1_subsampled_TAAGCTCC.fastq Undetermined_S0_R2_subsampled_TAAGCTCC.fastq | echo "FASTQC done" > fastqc/.fastqc.txt
