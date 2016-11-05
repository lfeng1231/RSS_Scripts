#!/usr/bin/perl

use warnings;
use strict;

my $dir = `pwd`;
chomp $dir;
my $dir2 = "$dir/frag_out";
system("rm -rf $dir2");
mkdir $dir2;

my $hg38 = "/isilon/Analysis/onco/indexes/hg38/hg38.fa";

open(IN1, "MSKK_plasma_somatic_mutation.txt") || die "Cannot open IN: $!";

my $n = 0;
while( my $record=<IN1> )
{
    $n++;
    if ($n ==1)
    {
	next;
    }
    else
    {
	chomp $record;
	my @key = split("\t", $record);
	
	my $chr = $key[0];
	my $pos = $key[1];
	my $ref = $key[2];
	my $alt = $key[3];
	my $sample = $key[4];
	my $eaf = $key[5];
	my $gene = $key[7];
	my $aa = $key[6];
	my $bam = "$dir/bams/"."MSKK_PLASMA_".$sample.".sorted.bam";
	my $outname = "$chr"."_$pos"."_$ref"."_$alt"."_$gene"."_$aa"."_plasma$sample"."_FragLen.txt";
	my $sam = "$chr"."_$pos"."_plasma$sample.sam";
	
	system("samtools view -u -f 2 $bam $chr:$pos-$pos | samtools calmd -e - $hg38 > $dir2/$sam");
	
	open(IN, "$dir2/$sam") || die "Cannot open IN: $!";
	open(OUT, ">$dir2/$outname") || die "Cannot open OUT: $!";
	print OUT "Read\tAllele\tFrag_Len\tType\n";
	my $j = 0;
	my $k = 0;
	my $l = 0;
	while( my $record=<IN> )
	{
	    chomp $record;
	    
	    if ($record =~ /^\@/)
	    {
		next;
	    }
	    else
	    {
		my @line = split("\t", $record);
		my $read = $line[0];
		my $rstart = $line[3];
		my $frag = abs($line[8]);
		my $seq = $line[9];
		my $s = $pos-$rstart;
		my $allele = substr($seq,$s,1);
		
		if ($allele eq "=")
		{
		    $j++;
		    print OUT "$read\t$ref\t$frag\treference\n";
		}
		elsif ($allele eq $alt)
		{
		    $k++;
		    print OUT "$read\t$allele\t$frag\tmutation\n";
		}
		else
		{
		    $l++;
		}
	    }
	}
	close IN;
	close OUT;
	my $af = sprintf("%.3f", $k/($j+$k+$l)*100);
	print "reference\t$j\n";
	print "mutation\t$k\n";
	print "AF\t$af\t$eaf\n\n";
	system("rm $dir2/$sam");
    }
}
close IN1;
