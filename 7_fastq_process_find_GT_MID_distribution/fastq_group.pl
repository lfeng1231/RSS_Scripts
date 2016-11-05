#!/usr/bin/perl

use warnings;
use strict;

my $r1 = $ARGV[0];
my $base;
if ($r1 =~ /(\S+)\.fastq/)
{
    $base = $1;
}
else
{
    print "fastq format error\n";
}

my $out1 = $base."_withGTGN.fastq";
my $out2 = $base."_withoutGTGN.fastq";

open(IN, $r1) || die "Cannot open IN: $!";

open(OUT1, ">$out1") || die "Cannot open OUT: $!";
open(OUT2, ">$out2") || die "Cannot open OUT: $!";

my $n = 0;
my $flag = 0;
my $seq ="";
while( my $record=<IN> )
{
    $n++;
    chomp $record;
    
    if ($n == 1)
    {
	$seq = "$record\n";
    }
    elsif ($n == 2)
    {
	$seq = $seq."$record\n";
	my $punc = substr($record, 2, 2);
	if ($punc eq "GT" or $punc eq "GN")
	{
	    $flag = 1;
	}
	else
	{
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
	if ($flag == 1)
	{
	    print OUT1 $seq;
	    print "$seq\n\n\n";
	}
	elsif ($flag == 2)
	{
	    print OUT2 $seq;
	}
	else
	{
	    print "flag setting problem\n";
	}
	$n = 0;
	$seq = "";
	$flag = 0;
    }
}
close IN;
close OUT1;
close OUT2;
	
