#!/usr/bin/perl

use warnings;
use strict;

my $sample = $ARGV[0];
my $vcf = $ARGV[1];
my $truth = $ARGV[2];
my $out1 = $ARGV[3];
my $out2 = $ARGV[4];
my $out3 = $ARGV[5];
my $out4 = $ARGV[6];

my $eaf;
my $aa;
if ($sample =~ /^(\S+)_panel/)
{
    $aa = $1;
    $eaf = $1/100;
}
else
{
    $eaf = "NA";
}

my $ss = "horizon_$sample";

#my $vcf = "/isilon/Analysis/onco/v1_analyses/20160529_A169_Cindy_feasibility_LOD/LOD_pool_03_SNV_cfDNAspike_P2B/analysis/LOD_pool_03_SNV_0.25_panel2_rep1/snv-new/horizon_0.25_panel2_rep1.vcf";
#my $truth = "/home/users/fengl6/my_scripts/16_sensitivity/EEP_32CancerSNVmix_May5_2016.truth.hg38.txt";
#my $out1 = "/isilon/Analysis/onco/v1_analyses/20160529_A169_Cindy_feasibility_LOD/LOD_pool_03_SNV_cfDNAspike_P2B/analysis/LOD_pool_03_SNV_0.25_panel2_rep1/snv-new/horizon_0.25_panel2_rep1.TP.txt";
#my $out2 = "/isilon/Analysis/onco/v1_analyses/20160529_A169_Cindy_feasibility_LOD/LOD_pool_03_SNV_cfDNAspike_P2B/analysis/LOD_pool_03_SNV_0.25_panel2_rep1/snv-new/horizon_0.25_panel2_rep1.FN.txt";
#my $out3 = "/isilon/Analysis/onco/v1_analyses/20160529_A169_Cindy_feasibility_LOD/LOD_pool_03_SNV_cfDNAspike_P2B/analysis/LOD_pool_03_SNV_0.25_panel2_rep1/snv-new/horizon_0.25_panel2_rep1.variants_table.txt";
#my $out4 = "/isilon/Analysis/onco/v1_analyses/20160529_A169_Cindy_feasibility_LOD/LOD_pool_03_SNV_cfDNAspike_P2B/analysis/LOD_pool_03_SNV_0.25_panel2_rep1/snv-new/horizon_0.25_panel2_rep1.sensitivity.txt";


my %true;
my $k = 0;
my $b = 0;
open(IN, $truth) || die "Cannot open IN: $!";
while( my $record=<IN> )
{
    $k++;
    if ($k ==1)
    {
	next;
    }
    else
    {
	$b++;
	chomp $record;
        $record =~ s/\r|\n//g;
        my @line = split("\t", $record);
	
        my $id = "$line[0]-$line[1]-$line[3]-$line[4]";
	my $item = "$line[6]\t$line[7]\t$line[5]";
	$true{$id} = $item;
    }
}
close IN;

open(IN2, $vcf) || die "Cannot open IN: $!";

open(OUT1, ">$out1") || die "Cannot open OUT: $!";
print OUT1 "SAMPLE\tCHR\tPOS\tREF\tALT\tEAF\tDEPTH\tMAF\tGENE\tCHANGE\tCOSMIC\n";

open(OUT2, ">$out2") || die "Cannot open OUT: $!";
print OUT2 "SAMPLE\tCHR\tPOS\tREF\tALT\tEAF\tDEPTH\tMAF\tGENE\tCHANGE\tCOSMIC\n";

open(OUT3, ">$out3") || die "Cannot open OUT: $!";
print OUT3 "SAMPLE\tCHR\tPOS\tREF\tALT\tDEPTH\tMAF\tTYPE\n";

open(OUT4, ">$out4") || die "Cannot open OUT: $!";

my $s = 0;
my %tp;
while( my $record=<IN2> )
{
    chomp $record;
    if ($record =~ /^#/)
    {
	next;
    }
    else
    {
	$record =~ s/\r|\n//g;
	my @line = split("\t", $record);
	
	my $chr = $line[0];
	my $pos = $line[1];
	my $ref = $line[3];
	my $alt = $line[4];
	my $info = $line[7];
	my $dep;
	my $raf;
	my $type;
	    
	my @list = split(";", $info);

	my $d = $list[0];
	my $af = $list[4];
	my $t = $list[5];

	if ($d =~ /DP=(\d+)/)
	{
	    $dep = $1;
	}
	else
	{
	    print "DP not found\n$record\n";
	}

	if ($af =~ /AF=(\S+)/)
	{
	    $raf = $1;
	}
	else
	{
	    print "AF not found\n$record\n";
	}

	if ($t =~ /WHITELIST/)
	{
	    $type = "whitelist";
	}
	else
	{
	    $type = "adaptive";
	}

	print OUT3 "$ss\t$chr\t$pos\t$ref\t$alt\t$dep\t$raf\t$type\n";
	
	
	my $id = "$chr-$pos-$ref-$alt";
	if (exists $true{$id})
	{
	    $tp{$id} = 1;	    
	    $s++;
	    print OUT1 "$ss\t$chr\t$pos\t$ref\t$alt\t$eaf\t$dep\t$raf\t$true{$id}\n";
	}
    }
}
close IN2;
close OUT1;
close OUT3;

my $sens = sprintf("%.3f",($s/$b)*100);
print "$sample\t$aa\t$sens\t$s\t$b\n";
print OUT4 "$sens\n";
close OUT4;


open(IN3, $truth) || die "Cannot open IN: $!";
my $j = 0;
while( my $record=<IN3> )
{
    $j++;
    if ($j ==1)
    {
	next;
    }
    else
    {
	chomp $record;
	$record =~ s/\r|\n//g;
	my @line = split("\t", $record);
    
	my $chr = $line[0];
	my $pos = $line[1];
	my $ref = $line[3];
	my $alt = $line[4];
	my $dep = "NA";
	my $raf = "NA";
	my $gene = $line[6];
	my $cos = $line[5];
	my $codon = $line[7];
	my $id = "$chr-$pos-$ref-$alt";

	if (exists $tp{$id})
	{
	    next;
	}
	else
	{
	    print OUT2 "$ss\t$chr\t$pos\t$ref\t$alt\t$eaf\t$dep\t$raf\t$gene\t$codon\t$cos\n";
	}
    }
}
close IN3;
close OUT2;
