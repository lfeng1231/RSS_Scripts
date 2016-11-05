#!/usr/bin/env perl

use warnings;
use strict;

#create file names
my $dir = $ARGV[0];
my $s2b = $ARGV[1];
my $R1 = $ARGV[2];
my $non_PhiX_R1 = $ARGV[3];

#1. collect SID for all reads in the original fastq file without PhiX
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

	if ($record =~ /(\S+)\s+.*/)
	{
	    my $head = $1;
	    $seq{$head} = $index;
	}
    }
}
close IN1;
	
#2. create %SID36 for 36 SIDs
my %SID36;
open(IN2, "/isilon/Analysis/onco/barcodes/sample_barcodes_36_adapter_v2-1.txt") || die "Cannot open IN: $!";
while( my $record=<IN2> )
{
    chomp $record;
    $record =~ s/\r|\n//g;
    my @line = split("\t", $record);
    my $idx = $line[0];
    my $sid = $line[1];
    $SID36{$sid} = $idx;
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

    $SIDuse{$index} = 1;
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
    if ( exists $SID36{$id} )
    {
	my $idx = $SID36{$id};
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
my $puse_all = sprintf("%.3f", $c1/($c1+$c2+$c3)*100);
my $pnonuse = sprintf("%.3f", $c2/($c1+$c2+$c3)*100);
my $puse_36 = sprintf("%.3f", $c1/($c1+$c2)*100);
my $punex = sprintf("%.3f", $c3/($c1+$c2+$c3)*100);

print OUT2 "Number used expected SID\t$c1\n";
print OUT2 "Number non-used expected SID\t$c2\n";
print OUT2 "Number unexpected SID\t$c3\n";    
print OUT2 "% used expected SID\t$puse_all\n";
print OUT2 "% non-used expected SID\t$pnonuse\n";
print OUT2 "% unexpected SID\t$punex\n";
print OUT2 "% used SID in all expected SID\t$puse_36\n";
close OUT2;


#6. plot SID distribution
system("cp /home/users/fengl6/my_scripts/4_barcode_profile/barcode_profile_v2.1/3_combined_SID_profile/barcode_distribution.R $dir/barcode_distribution.R");
system("R CMD BATCH $dir/barcode_distribution.R");
system("rm $dir/barcode_distribution.R");
system("rm $dir/barcode_distribution.Rout");
