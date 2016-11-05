date
samtools view -h -F 2 Repeatability_cfDNA_P2B_Lot1_R3.sorted.bam |samtools view -h -F 4 - |samtools view -h -F 256 - | samtools view -h -f 64 -|samtools view -F 16 - > notpaired_R1_plus.sam
samtools view -h -F 2 Repeatability_cfDNA_P2B_Lot1_R3.sorted.bam |samtools view -h -F 4 - |samtools view -h -F 256 - | samtools view -h -f 64 -|samtools view -f 16 - > notpaired_R1_minus.sam
samtools view -h -F 2 Repeatability_cfDNA_P2B_Lot1_R3.sorted.bam |samtools view -h -F 4 - |samtools view -h -F 256 - | samtools view -h -f 128 -|samtools view -F 16 - > notpaired_R2_plus.sam
samtools view -h -F 2 Repeatability_cfDNA_P2B_Lot1_R3.sorted.bam |samtools view -h -F 4 - |samtools view -h -F 256 - | samtools view -h -f 128 -|samtools view -f 16 - > notpaired_R2_minus.sam
date
samtools view -h -F 2 Repeatability_cfDNA_P2B_Lot1_R3.sorted.bam | samtools view -h -F 4 - |samtools view -h -F 256 - | samtools view -f 64 - |cut -f9 > R1_not_properly_paired_fraglen.txt
samtools view -h -f 2 Repeatability_cfDNA_P2B_Lot1_R3.sorted.bam | samtools view -f 64 - |cut -f9 > R1_properly_paired_fraglen.txt
