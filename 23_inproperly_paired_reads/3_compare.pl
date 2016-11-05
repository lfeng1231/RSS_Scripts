#!/usr/bin/perl

use warnings;
use strict;

my %read;
open(IN1, "notpaired_R1_plus.sam") || die "Cannot open IN: $!";
open(OUT, ">out_compare.txt") || die "Cannot open OUT: $!";
print OUT "Read\tR1_chr\tR1_start\tR1_strand\tR1_FragLen\tR2_chr\tR2_start\tR2_strand\tR2_FragLen\n";

while( my $record=<IN1> )
{
    chomp $record;
    
    if ($record =~ /^\@/)
    {
	next;
    }
    else
    {
	my @line = split("\t", $record);
	my $rname = $line[0];
	my $chr = $line[2];
	my $start = $line[3];
	my $strand = "+";
	my $frag = $line[8];
	my $item = "$rname\t$chr\t$start\t$strand\t$frag";
	$read{$rname} = $item;
    }
}
close IN1;

open(IN2, "notpaired_R1_minus.sam") || die "Cannot open IN: $!";

while( my $record=<IN2> )
{
    chomp $record;
    
    if ($record =~ /^\@/)
    {
	next;
    }
    else
    {
	my @line = split("\t", $record);
	my $rname = $line[0];
	my $chr = $line[2];
	my $start = $line[3];
	my $strand = "-";
	my $frag = $line[8];
	my $item = "$rname\t$chr\t$start\t$strand\t$frag";
	$read{$rname} =$item;
    }
}
close IN2;


open(IN3, "notpaired_R2_plus.sam") || die "Cannot open IN: $!";

while( my $record=<IN3> )
{
    chomp $record;
    
    if ($record =~ /^\@/)
    {
	next;
    }
    else
    {
	my @line = split("\t", $record);
	my $rname = $line[0];
	my $chr = $line[2];
	my $start = $line[3];
	my $strand = "+";
	my $frag = $line[8];
	my $item = "$chr\t$start\t$strand\t$frag";
	
	if (exists $read{$rname})
	{
	    $read{$rname} = "$read{$rname}\t$item";
	}
	else
	{
	    $read{$rname} ="$rname\tNA\tNA\tNA\tNA\t$item";
	}
    }
}
close IN3;

open(IN4, "notpaired_R2_minus.sam") || die "Cannot open IN: $!";

while( my $record=<IN4> )
{
    chomp $record;

    if ($record =~ /^\@/)
    {
	next;
    }
    else
    {
	my @line = split("\t", $record);
	my $rname = $line[0];
	my $chr = $line[2];
	my $start = $line[3];
	my $strand = "-";
	my $frag = $line[8];
	my $item = "$chr\t$start\t$strand\t$frag";

	if (exists $read{$rname})
	{
	    $read{$rname} = "$read{$rname}\t$item";
	}
	else
	{
	    $read{$rname} ="$rname\tNA\tNA\tNA\tNA\t$item";
	}
    }
}
close IN4;

foreach my $key (keys %read)
{
    print OUT "$read{$key}\n";
}
close OUT;
