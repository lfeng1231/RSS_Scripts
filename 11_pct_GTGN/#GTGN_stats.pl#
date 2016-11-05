#!/usr/bin/perl

use warnings;
use strict;

my $r1_gz = $ARGV[0];

my $r1;
my $base;
my $r;
if ($r1_gz =~ /(\S+)\.fastq.gz/)
{
    $base = $1;
    $r1 = $1.".fastq";
    if ($base =~ /_1_/ or $base =~ /_R1_/ or $base =~ /_R1\./)
    {
	$r = "R1";
    }
    elsif ($base =~ /_2_/ or $base =~ /_R2_/ or $base =~ /_R2\./)
    {
	$r = "R2";
    }
    else
    {
	$r = "$base";
    }
}
else
{
    print "fastq format error\n";
}

#unzip
system("date");
system("gunzip -c $r1_gz > $r1");
system("date");


my $out = "stats_GTGN_".$r.".txt";

open(IN, $r1) || die "Cannot open IN: $!";
open(OUT, ">$out") || die "Cannot open OUT: $!";


my $n = 0;
my $a = 0;
my $b = 0;
my $c = 0;
my $flag = 0;
my $seq ="";
while( my $record=<IN> )
{
    $n++;
    chomp $record;
    
    if ($n == 1)
    {
	$a++;
	$seq = "$record\n";
    }
    elsif ($n == 2)
    {
	$seq = $seq."$record\n";
	my $punc = substr($record, 2, 2);
	if ($punc eq "GT" or $punc eq "GN")
	{
	    $b++;
	    $flag = 1;
	}
	else
	{
	    $c++;
	    $flag = 2;
	}
    }
    
    elsif ($n == 3)
    {
        $seq = $seq."$record\n";
    }
    elsif ($n == 4)
    {
	$seq = $seq."$record\n";
	
	$n = 0;
	$seq = "";
	$flag = 0;
    }
}
close IN;

my $ratio = $b/$a*100;
my $pct = sprintf("%.1f", $ratio);
print OUT "Total reads in $r\t$a\n";
print OUT "GT/GN reads in $r\t$b\n";
print OUT "non-GT/GN reads in $r\t$c\n";
print OUT "%GT/GN in $r\t$pct\n";
close OUT;
