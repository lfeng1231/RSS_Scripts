#!/usr/bin/perl

use warnings;
use strict;

my $path = `pwd`;
chomp $path;

my $lane = $ARGV[0];
my $panel = $ARGV[1];
my $pa;

if ($panel eq "p1")
{
    $pa = "/isilon/Analysis/onco/indexes/hg38/RUO_P1B_capture_targets.bed";
}
elsif ($panel eq "p2")
{
    $pa = "/isilon/Analysis/onco/indexes/hg38/RUO_P2B_capture_targets.bed";
}
elsif ($panel eq "p3")
{
    $pa = "/isilon/Analysis/onco/indexes/hg38/RUO_P3B_capture_targets.bed";
}
else
{
    print "panel info wrong\n";
    $pa = "NA";
}

open(OUT, ">$path/lane_ontarget.txt") || die "Cannot open OUT: $!";

print OUT "$lane\n";

opendir(DIR,$path);
my @files = readdir(DIR);
closedir(DIR);
    
foreach my $name (sort {$a cmp $b} @files)
{
    if ($name =~ /^\w+/ and $name ne "demux" and $name !~ m/txt/ and $name !~ m/sh/)
    {
	my $bam = "$path/$name/bams/$name\.sorted\.bam";
	
	my $flagstat = $bam.".flagstat";
	system("date");
	system("/remote/RSU/sw/sambamba/v0.5.8/sambamba flagstat $bam > $flagstat");
	my $aln = `grep mapped $flagstat | grep '(' | grep -v mate | cut -d' ' -f 1`;
	
	my $ontarget = `/remote/RSU/sw/BEDTools/2.23.0/bin/bedtools intersect -bed -a $bam -b $pa | cut -f 4 | sort | uniq | wc -l | cut -d ' ' -f 1`;
	my $rate = sprintf("%.1f", $ontarget/$aln*100);
	print OUT "$lane\t$name\t$rate\n";
	print "$lane\t$name\t$rate\n";
    }
}
close OUT;
