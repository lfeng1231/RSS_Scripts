#!/usr/bin/perl

use warnings;
use strict;

my $sample = $ARGV[0];
my $file = $ARGV[1];
my $out = $ARGV[2];
my $file2 = $ARGV[3];

my $g;
my $t;
my $g1all;
my $g1true;
my $g2all;
my $g2true;
my $g3all;
my $g3true;
my $g4all;
my $g4true;
my $g5all;
my $g5true;

open(IN, $file) || die "Cannot open IN: $!";
open(OUT, ">$out") || die "Cannot open OUT: $!";
print OUT "Sample\tOverall\tAF=0.05%\tAF=0.25%\tAF=2.5%\t2.5%<AF<=6%\t40%<=AF<=60%\twhite_FP\tmax_FP_%AF\n";

my $n = 0;
while( my $record=<IN> )
{
    $n++;
    if ($n ==1)
    {
	next;
    }
    else
    {
	$g++;
	chomp $record;
	$record =~ s/\r|\n//g;
	my @line = split("\t", $record);
	
	my $af = $line[5];
	my $flag = $line[8];
	if ($flag eq "TRUE")
	{
	    $t++;
	}
	
	if ($af eq "NA")
	{
	    $af = 0;
	}
	
	if ($af == 0.0005)
	{
	    $g1all++;
	    if ($flag eq "TRUE")
	    {
		$g1true++;
	    }
	}

	elsif ($af == 0.0025)
	{
	    $g2all++;
	    if ($flag eq "TRUE")
	    {
		$g2true++;
	    }
	}
	
	elsif ($af == 0.025)
	{
	    $g3all++;
	    if ($flag eq "TRUE")
	    {
		$g3true++;
	    }
	}
	
	elsif ($af > 0.025 and $af <= 0.06)
	{
	    $g4all++;
	    if ($flag eq "TRUE")
	    {
		$g4true++;
	    }
	}
	elsif ($af >= 0.4 and $af <= 0.6)
        {
            $g5all++;
            if ($flag eq "TRUE")
            {
                $g5true++;
	    }
        }
    }
}
close IN;

my $s1 = sprintf("%.3f", $g1true/$g1all*100);
my $s2 = sprintf("%.3f", $g2true/$g2all*100);
my $s3 = sprintf("%.3f", $g3true/$g3all*100);
my $s4 = sprintf("%.3f", $g4true/$g4all*100);
my $s5 = sprintf("%.3f", $g5true/$g5all*100);
my $s6 = sprintf("%.3f", $t/$g*100);

open(IN2, $file2) || die "Cannot open IN: $!";

my $m = 0;
my $fp = 0;
my $max = 0;
while( my $record=<IN2> )
{
    $m++;
    if ($m ==1)
    {
        next;
    }
    else
    {
        chomp $record;
        $record =~ s/\r|\n//g;
        my @line = split("\t", $record);
	my $ref = $line[2];
	my $alt = $line[3];
	my $af = $line[7];
	my $len1 = length $ref;
	my $len2 = length $alt;
	
	if ($len1==1 and $len2==1)
	{
	    $fp++;
	    
	    if ($af >$max)
	    {
		$max = $af;
	    }
	}
    }
}
close IN2;

my $maf=sprintf("%.5f", $max*100);
print OUT "$sample\t$s6\t$s1\t$s2\t$s3\t$s4\t$s5\t$fp\t$maf\n";
print "$sample\t$s6\t$s1\t$s2\t$s3\t$s4\t$s5\t$fp\t$maf\n";
