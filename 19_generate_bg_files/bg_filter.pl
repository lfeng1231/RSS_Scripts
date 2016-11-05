#!/usr/bin/perl

use warnings;
use strict;

my $dir = "/isilon/Analysis/onco/v1_analyses/20160626_A176_Jorge_normal_cfDNA_P1P3_H75KCBGXY_H75FTBGXY/JMD_Normal_cfDNA_Pool2/analysis/generate_bg_P3/snv-bg";
my $bg_file= "$dir/snvbg.txt";

my %germ;
opendir(DIR,$dir);
my @files = readdir(DIR);
closedir(DIR);

open(OUT1, ">germline_SNV_all_samples.txt") || die "Cannot open OUT: $!";

foreach my $name (@files)
{
    if ($name =~ /Q30.txt/)
    {
	open(IN1, "$dir/$name") || die "Cannot open IN: $!";
	my $n = 0;
	while( my $record=<IN1> )
	{
	    $n++;
	    chomp $record;
	    
	    if ($n==1)
	    {
		next;
	    }
	    else
	    {
		my @line = split("\t", $record);
		my $chr = $line[0];
		my $pos = $line[1];
		
		my $dep = $line[2];
		my $depA = $line[6]+$line[7];
		my $depC = $line[8]+$line[9];
		my $depT = $line[10]+$line[11];
		my $depG = $line[12]+$line[13];
		
		if ($dep != 0)
		{
		    my $a = $depA/$dep;
		    my $c = $depC/$dep;
		    my $t = $depT/$dep;
		    my $g = $depG/$dep;

		    if ($a > 0.2)
		    {
			my $id = "$chr--$pos--A";
			print OUT1 "$id\t$name\t$a\n";
			$germ{$id} = 1;
		    }
		    if ($c > 0.2)
		    {
			my $id = "$chr--$pos--C";
			print OUT1 "$id\t$name\t$c\n";
			$germ{$id} = 1;
		    }
		    if ($t > 0.2)
		    {
			my $id = "$chr--$pos--T";
			print OUT1 "$id\t$name\t$t\n";
			$germ{$id} = 1;
		    }
		    if ($g > 0.2)
		    {
			my $id = "$chr--$pos--G";
			print OUT1 "$id\t$name\t$g\n";
			$germ{$id} = 1;
		    }
		}
	    }
	}
	close IN1;
    }
}
close OUT1;


open(IN2, "$bg_file") || die "Cannot open IN: $!";
open(OUT2, ">germline_positions.txt") || die "Cannot open OUT: $!";
open(OUT3, ">$dir/snvbg_filtered.txt") || die "Cannot open OUT: $!";

my $m = 0;
while( my $record=<IN2> )
{
    $m++;
    chomp $record;
    
    if ($m ==1)
    {
        print OUT2 "$record\n";
	print OUT3 "$record\n"; 
    }
    else
    {
        my @line = split("\t", $record);
	my $chr = $line[0];
	my $pos = $line[1];
	my $alt = $line[3];
	my $id = "$chr--$pos--$alt";
	
	if (exists $germ{$id})
	{
	    print OUT2 "$record\n";
	}
	else
	{
	    print OUT3 "$record\n";
	}
    }
}
close IN2;
close OUT2;
close OUT3;
