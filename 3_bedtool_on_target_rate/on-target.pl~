#!/usr/bin/perl

use warnings;
use strict;

my $path = "/remote/Overflow/DataAnalysis/Oncology_TE/CM_TEstudy_Nov2015/TE1/analysis/tumor-nondeduped";
opendir (DIR, $path) or die "Can not open DIR/n";

my @filelist = readdir DIR;

open(OUT, ">/remote/Overflow/DataAnalysis/Oncology_TE/CM_TEstudy_Nov2015/TE1/analysis/analysis/RNG_on-target_rate.txt") || die "Cannot open OUT: $!";

foreach my $file (@filelist) 
{
    if ($file =~ /(\S+)\.sorted\.bam$/)
    {
	my $sample =$1;
	my $ontarget = `/remote/RSU/sw/BEDTools/2.23.0/bin/bedtools intersect -bed -u -abam $path/$file -b /remote/DataAnalysis/Oncology_TE/cm_elim_09112015/data/seqcap_targets_cappmed_pipeline.bed | wc -l`;
	my $ext = `/remote/RSU/sw/BEDTools/2.23.0/bin/bedtools intersect -bed -u -abam $path/$file -b /remote/Overflow/DataAnalysis/Oncology_TE/CM_TEstudy_Nov2015/output_metrics/seqcap_targets_cappmed_pipeline_ext100.bed | wc -l`;
	my $mapped = `/remote/RSU/sw/samtools/1.2/bin/samtools view -c -F 4 $path/$file`;
	my $rate = sprintf("%.3f", $ontarget/$mapped);
	my $rate_ext = sprintf("%.3f", $ext/$mapped);

	print OUT "$sample\t$rate\t$rate_ext\n";
    }
}
close OUT;
