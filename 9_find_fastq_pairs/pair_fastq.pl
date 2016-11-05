#!/usr/bin/perl

use warnings;
use strict;

my $r1 = $ARGV[0];
my $r2 = $ARGV[1];
my $pr1 = "paired_".$r1;
my $pr2 = "paired_".$r2;

my %read2;
my $n = 0;
my $seq = "";
my $head = "";
my $c = 0;
open(IN1, $r2) || die "Cannot open IN: $!";
while( my $record=<IN1> )
{
    $n++;
    chomp $record;
    
    if ($n == 1)
    {
        $seq = "$record\n";
	$head = "$record";
    }
    elsif ($n == 2)
    {
        $seq = $seq."$record\n";
    }
    elsif ($n == 3)
    {
        $seq = $seq."$record\n";
    }
    elsif ($n == 4)
    {
	$c++;
        $seq = $seq."$record";
	$read2{$head} = $seq;
	$n = 0;
        $seq = "";
	$head = "";
    }
}
close IN1;

my $m = 0;
my $seq1 = "";
my $head1 = "";
my $a = 0;
my $b = 0;
open(IN2, $r1) || die "Cannot open IN: $!";
open(OUT1, ">$pr1") || die "Cannot open OUT: $!";
open(OUT2, ">$pr2") || die "Cannot open OUT: $!";

while( my $record=<IN2> )
{
    $m++;
    chomp $record;
    
    if ($m == 1)
    {
        $seq1 = "$record\n";
        $head1 = "$record";
    }
    elsif ($m == 2)
    {
        $seq1 = $seq1."$record\n";
    }
    elsif ($m == 3)
    {
        $seq1 = $seq1."$record\n";
    }
    elsif ($m == 4)
    {
        $seq1 = $seq1."$record";
        
	if ($head1 =~ /(\S+)(\s+)1(\:N\S+)/)
	{
	    my $head2 = $1.$2."2".$3;
	    
	    if (exists $read2{$head2})
	    {
		$a++;
		print OUT1 "$seq1\n";
		print OUT2 "$read2{$head2}\n";
	    }
	    else
	    {
		$b++;
	    }
	}
	
        $m = 0;
        $seq1 = "";
        $head1 = "";
    }
}
close IN2;
close OUT1;
close OUT2;

my $d = $c - $a;

print "read pairs: $a\n";
print "unpaired reads in R1: $b\n";
print "unpaired reads in R2: $d\n";
