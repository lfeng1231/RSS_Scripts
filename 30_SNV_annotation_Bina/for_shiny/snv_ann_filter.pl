#!/usr/bin/perl

use warnings;
use strict;

##################################################################
# SNV post filtering for each shiny run
# Usage: In the run folder (e.g. 20161013_A233_Ashla_BeadWash2AA):
#         > perl snv_ann_filter.pl
##################################################################

my $panel1= "/isilon/Analysis/onco/prog/built_packages/snv-post-filtering/resources_files_from_Bina/RUO_P1B_exon_targets_hg38_06202016_consolidated.bed";
my $panel2 = "/isilon/Analysis/onco/prog/built_packages/snv-post-filtering/resources_files_from_Bina/RUO_P2B_exon_targets_hg38_09282016_consolidated.bed";
my $panel3 = "/isilon/Analysis/onco/prog/built_packages/snv-post-filtering/resources_files_from_Bina/RUO_P3B_exon_targets_hg38_09282016_consolidated.bed";

my $cross_con = "/isilon/Analysis/onco/prog/built_packages/ctdna-crosscon/crosscon-flagger.py";
my $snv_filter = "/isilon/Analysis/onco/prog/built_packages/snv-post-filtering/SNV_PostFiltering.sh";

#Parse CSV files and extract lane, sample, panel inforamtion
my $dir =`pwd`;
chomp $dir;
my $csv = `basename $dir/*.csv`;
chomp $csv;

open(IN, "$dir/$csv") || die "Cannot open IN: $!";
my $n = 0;
my %lanes;
while( my $record=<IN> )
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
	my @line = split(",", $record);
	my $lane = $line[0];
	my $sample = $line[1];
	my $panel;
	if ($line[11] =~ /P1B/)
	{
	    $panel = "P1";
	}
	elsif ($line[11] =~ /P2B/)
	{
	    $panel = "P2";
	}
	elsif ($line[11] =~ /P3B/)
	{
	    $panel = "P3";
	}
	else
	{
	    print "panel info wrong\n";
	}
	my $info = "$sample==$panel";
	if (length $lanes{$lane})
	{
	    $lanes{$lane} = $lanes{$lane}."\t".$info;
	}
	else
	{
	    $lanes{$lane} = $info;
	}
    }
}
close IN;

#create corss contamination flagged vcf files for each lane
foreach my $lane(sort {$a cmp $b} keys %lanes)
{
    my %info;
    my @samp = split("\t", $lanes{$lane});
    my $dir1 = "$dir/$lane/analysis";
    
    #create crosscon directory and run crosscon script here
    system("rm -rf $dir1/crosscon");
    system("mkdir -p $dir1/crosscon");
    
    foreach my $s (sort {$a cmp $b} @samp)
    {
	if ($s =~ /^(\w.*)\=\=(\w.*)$/)
	{
	    my $sample = $1;
	    my $panel = $2;
	    $info{$sample} = $panel;
	    my $f = "$dir1/$sample/snv/${sample}.vcf";
	    
	    if (-e $f)
	    {
		system("ln -s $f $dir1/crosscon");
	    }
	}
    }

    #run ctdna-crosscon
    opendir(DIR1,"$dir1/crosscon");
    my @vcf = readdir(DIR1);
    closedir(DIR1);
    
    my $input="";
    foreach my $v (sort {$a cmp $b} @vcf)
    {
	if ($v =~ /vcf/)
	{
	    if ($input =~ /\w/)
	    {
		$input = $input." $dir1/crosscon/".$v;
	    }
	    else
	    {
		$input = "$dir1/crosscon/".$v;
	    }
	}
    }
    
    system("$cross_con -infiles $input -minnumsample 1 -minbgaf 0.30 -maxaf 0.02 -expcont 0");

    #run snv post filtering script
    opendir(DIR2,"$dir1/crosscon");
    my @crossvcf = readdir(DIR2);
    closedir(DIR2);
    
    foreach my $cv (sort {$a cmp $b} @crossvcf)
    {
	if ($cv =~ /(\S+)\.crosscon\.vcf/)
	{
	    my $ss = $1;
	    my $pa;
	    if (exists $info{$ss})
	    {
		if ( $info{$ss} eq "P1")
		{
		    $pa = $panel1;
		}
		elsif ($info{$ss} eq "P2")
		{
		    $pa= $panel2;
		}
		elsif ($info{$ss} eq "P3")
		{
		    $pa= $panel3;
		}
		else
		{
		    print "panel info wrong\n";
		}

		my $dir2 = "$dir1/$ss/snv";
		system("cp $dir1/crosscon/$cv $dir2");
		print "\n\n********* $lane $ss **********\n\n";

		chdir("$dir2") or die "$!";
		system("$snv_filter $pa $ss");
	    }
	    else
	    {
		print "panel info not found\n";
	    }
	}
    }
    system("rm -rf $dir1/crosscon");
}
