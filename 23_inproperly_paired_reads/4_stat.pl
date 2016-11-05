#!/usr/bin/perl

use warnings;
use strict;

my %read;
open(IN, "out_compare.txt") || die "Cannot open IN: $!";

my $n = 0;
my $a = 0;
my $b = 0;
my $c = 0;
my $d = 0;
my $e = 0;
my $f = 0;
my $g = 0;
my $h = 0;

while( my $record=<IN> )
{
    $n++;
    chomp $record;
    
    if ($n ==1)
    {
	next;
    }
    else
    {
	my @line = split("\t", $record);
	my $count = @line;
	my $s1;
	my $s2;
	if ($count == 9)
	{
	    $s1 = $line[3];
	    $s2 = $line[7];
	}
	else
	{
	    $s1 = $line[3];
	    $s2 = "NA";
	}
	
	my $item = "$s1$s2";
	
	if ($item eq "++")
	{
	    $a++;
	}
	elsif ($item eq "+-")
	{
	    $b++;
	}
	elsif ($item eq "-+")
	{
	    $c++;
	}
	elsif ($item eq "--")
	{
	    $d++;
	}
	elsif ($item eq "+NA")
	{
	    $e++;
	}
	elsif ($item eq "-NA")
	{
	    $f++;
	}
	elsif ($item eq "NA+")
	{
	    $g++;
	}
	elsif ($item eq "NA-")
	{
	    $h++;
	}
	
    }
}
close IN;

my $all = $a+$b+$c+$d+$e+$f+$g+$h;

my $pa = sprintf("%.1f", $a/$all*100);
my $pb = sprintf("%.1f", $b/$all*100);
my $pc = sprintf("%.1f", $c/$all*100);
my $pd = sprintf("%.1f", $d/$all*100);
my $pe = sprintf("%.1f", $e/$all*100);
my $pf = sprintf("%.1f", $f/$all*100);
my $pg = sprintf("%.1f", $g/$all*100);
my $ph = sprintf("%.1f", $h/$all*100);

print "++\t$a\t$pa%\n";
print "+-\t$b\t$pb%\n";
print "-+\t$c\t$pc%\n";
print "--\t$d\t$pd%\n";
print "+NA\t$e\t$pe%\n";
print "-NA\t$f\t$pf%\n";
print "NA+\t$g\t$pg%\n";
print "NA-\t$h\t$ph%\n";
