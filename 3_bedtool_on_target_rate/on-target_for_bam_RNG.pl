#!/usr/bin/perl

use warnings;
use strict;

my $path = "/remote/RSU/home/fengl6/RNG-bam";
opendir (DIR, $path) or die "Can not open DIR/n";
my @filelist = readdir DIR;

open(OUT, ">$path/RNG_on-target_rate.txt") || die "Cannot open OUT: $!";
foreach my $file (@filelist) 
{
    if ($file =~ /(\S+)\_sorted\.bam/)
    {
	my $sample =$1;
	my $ontarget = `/remote/RSU/sw/BEDTools/2.23.0/bin/bedtools intersect -bed -u -abam $path/$file -b /remote/RSU/home/fengl6/RNG-bam/seqcap_targets.bed | wc -l`;
	my $mapped = `/remote/RSU/sw/samtools/1.2/bin/samtools view -c -F 4 $path/$file`;
	my $rate = sprintf("%.3f", $ontarget/$mapped);
	
	print OUT "$sample\t$rate\n";
    }
}
close OUT;
