#!/usr/bin/perl

use warnings;
use strict;

open(IN1, "whitelist_final_P2_excluded_20160607_snpEFF_noShift.txt") || die "Cannot open IN: $!";

my %tag;
my $n = 0;
while( my $record=<IN1> )
{
    $n++;
    chomp $record;
    $record =~ s/\r|\n//g;
    
    if ($n ==1)
    {
	next;
    }
    else
    {
	my @line = split("\t", $record);
	my $gene = $line[5];
	my $change = $line[8];
	my $id = "$gene--$change";
	my $item = "$line[18]\t$line[19]\t$line[21]\t$line[22]";
	$tag{$id} = $item;
    }
}
close IN1;

open(IN2, "whitelist_P1.bed") || die "Cannot open IN: $!";
open(OUT, ">whitelist_final_P1_excluded_20160620.bed") || die "Cannot open OUT: $!";

while( my $record=<IN2> )
{
    chomp $record;
    $record =~ s/\r|\n//g;
    my @line = split("\t", $record);
    my $gene = $line[5];
    my $change = $line[8];
    if ($change =~ /(\S+)/)
    {
	$change = $1;
	my $id = "$gene--$change";
	
	if (exists $tag{$id})
	{
	    print OUT "$record\t$tag{$id}\n";
	}
	else
	{
	print "TAG not found\n$record\n\n";
	}
    }
}
close IN2;
close OUT;


    
