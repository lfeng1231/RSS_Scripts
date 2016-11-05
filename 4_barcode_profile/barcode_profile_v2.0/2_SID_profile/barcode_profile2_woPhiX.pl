#!/usr/bin/env perl

use warnings;
use strict;

#create file names
my $dir =`pwd`;
chomp $dir;
my $s2b = "/isilon/Analysis/onco/cappmed_analyses/20160106_A110_Jon_DGopt/Test4/sample2barcode.txt";
my $R1 = "/isilon/Data/external_data/elim/20160105/modified/test4/modified_Test4_lane5_Undetermined_L005_R1_001.fastq";
my $non_PhiX_R1 = "/isilon/Analysis/onco/cappmed_analyses/20160106_A110_Jon_DGopt/Test4/barcode_profile3/non-phiX_R1.fastq";

my $position = 1; #0 if barcode is on left side of sequence tag; 1 if on right
my $bases = 4; #size of SID


#1. collect SID for all reads in the original fastq file with PhiX
open(IN1, $R1) || die "Cannot open IN: $!";
my $n1 = -1;
my %seq;
while( my $record=<IN1> )
{
    $n1++;
    chomp $record;
    $record =~ s/\r|\n//g;

    if($n1 % 4 == 0)
    {
        my @vars = split(":", $record);
        my $index = $vars[@vars-1];

        if($position == 1)
        {
            $position = length($index)-$bases;
        }
        my $sid = substr($index,$position,$bases);
	if ($record =~ /(\S+)\s+.*/)
	{
	    my $head = $1;
	    $seq{$head} = $sid;
	}
    }
}
close IN1;
	
#2. create %SID24 for 24 SIDs
my %SID24;
open(IN2, "/isilon/Analysis/onco/barcodes/sample_barcodes_24_adapter_v2.txt") || die "Cannot open IN: $!";
while( my $record=<IN2> )
{
    chomp $record;
    $record =~ s/\r|\n//g;
    my @line = split("\t", $record);
    my $idx = $line[0];
    my $sid = $line[1];
    $SID24{$sid} = $idx;
}
close IN2;


#3. put used SID in this experiment in %SIDuse
my %SIDuse;
open(IN3, $s2b) || die "Cannot open IN: $!";
while( my $record=<IN3> )
{
    chomp $record;
    $record =~ s/\r|\n//g;
    my @line = split("\t", $record);
    my $index = $line[1];

    my $pos = length($index)-$bases;
    my $sid = substr($index,$pos,$bases);

    $SIDuse{$sid} = 1;
}
close IN3;


#4. barcode count for non-phiX R1
my $R1_profile = "SID_counts.txt";
my $R1_stat = "SID_stats.txt";

open(IN4, $non_PhiX_R1) || die "Cannot open IN: $!";

my $m1 = -1;
my %barcode;
while( my $record=<IN4> )
{
    $m1++;
    chomp $record;
    $record =~ s/\r|\n//g;
    
    if($m1 % 4 == 0)
    {
	if ($record =~ /(\S+)\/1$/)
	{
	    my $head = $1;
	
	    if (exists $seq{$head})
	    {
		my $sid = $seq{$head};
		
		if (exists $barcode{$sid})
		{
		    $barcode{$sid}++;
		}
		else
		{
		    $barcode{$sid} = 1;
		}
	    }
	}
	else
	{
	    print "no match \n";
	}
    }
}
close IN4;

#5. print out barcode profile
my (%unex, %ex);
my $c1 = 0;
my $c2 = 0;
my $c3 = 0;
foreach my $id (keys %barcode)
{
    my $count = $barcode{$id};
    if ( exists $SID24{$id} )
    {
	my $idx = $SID24{$id};
	if (exists $SIDuse{$id})
	{
	    $c1 = $c1+$count;
	    my $item = "$id\t$idx\texpected_used\t$count";
	    $ex{$idx} = $item;
	}
	else
	{
	    $c2 = $c2+$count;
	    my $item = "$id\t$idx\texpected_not_used\t$count";
	    $ex{$idx} = $item;
	}
    }
    else
    {
	$c3 = $c3+$count;
	my $idx = "NA";
	    my $item = "$id\t$idx\tunexpected\t$count";
	$unex{$item} = $count;
    }
}
    

open(OUT1, ">$dir/$R1_profile") || die "Cannot open OUT: $!";
foreach my $key (sort { $a <=> $b} keys %ex) 
{
    print OUT1 "$ex{$key}\n";
}
    
foreach my $key (sort { $unex{$b} <=> $unex{$a}} keys %unex) 
{
    print OUT1 "$key\n";
}
close OUT1;
    
open(OUT2, ">$dir/$R1_stat") || die "Cannot open OUT: $!";
my $puse_all = sprintf("%.1f", $c1/($c1+$c2+$c3)*100);
my $pnonuse = sprintf("%.1f", $c2/($c1+$c2+$c3)*100);
my $puse_24 = sprintf("%.1f", $c1/($c1+$c2)*100);
my $punex = sprintf("%.1f", $c3/($c1+$c2+$c3)*100);
    
print OUT2 "% used SID\t$puse_all\n";
print OUT2 "% non-used SID\t$pnonuse\n";
print OUT2 "% unexpected SID\t$punex\n";
print OUT2 "% used SID within 24SID\t$puse_24\n";
close OUT2;


#6. plot SID distribution
system("cp /home/users/fengl6/bin/barcode_distribution.R $dir/barcode_distribution.R");
system("R CMD BATCH $dir/barcode_distribution.R");
system("rm $dir/barcode_distribution.R");
system("rm $dir/barcode_distribution.Rout");
