#!/usr/bin/perl

use warnings;
use strict;

my $number = $ARGV[0];
my $read_pair = $number/2;
my $level = int($number/1000000);
my $folder = "subsample"."_"."$level"."M";

my $dir = `pwd`;
chomp $dir;
my $subdir = "$dir/$folder";
system("rm -rf $subdir");
system("mkdir $subdir");

opendir(DIR,$dir);
my @files = readdir(DIR);
closedir(DIR);

my $n = 0;
my $allsub_R1 = "";
my $allsub_R2 = "";

open(OUT, ">$subdir/sample_reads_count.txt") || die "Cannot open OUT: $!";

foreach my $name (@files)
{
    if ($name =~ /(\S+)\_R1\_(\S+)\.fastq/)
    {
	$n++;
	my $sample = "sample$n";
	my $p1 = $1;
	my $p2 = $2;
	my $r1 = $name;
	my $r2 = $p1."_R2_".$p2.".fastq";
	my $sr1 = $p1."_R1_".$p2."_subsample.fastq";
	my $sr2 = $p1."_R2_".$p2."_subsample.fastq";
	my $sr1_gz = $sr1.".gz";
	my $sr2_gz = $sr2.".gz";
	
	$allsub_R1 = $allsub_R1." "."$subdir/$sr1_gz";
	$allsub_R2 = $allsub_R2." "."$subdir/$sr2_gz";
	
	my $seed = `echo \$RANDOM`;
	chomp $seed;
	
	my $count = `wc -l $dir/$r1 | cut -d ' ' -f 1`;
        my $count2 = $count/2;
        print OUT "$r1\t$count2\n";
	
	system("echo");
	system("echo $sample subsampling begin");
	system("date");
	system("/remote/RSU/sw/seqtk/06222015/seqtk sample -s $seed $dir/$r1 $read_pair > $subdir/$sr1");
	system("/remote/RSU/sw/seqtk/06222015/seqtk sample -s $seed $dir/$r2 $read_pair > $subdir/$sr2");
	system("date");
	system("echo $sample subsampling finished");
	system("echo $sample gzip begin");
	system("date");
	system("/isilon/Analysis/onco/prog/built_packages/pigz-2.3.3/pigz --fast -c $subdir/$sr1 > $subdir/$sr1_gz");
	system("/isilon/Analysis/onco/prog/built_packages/pigz-2.3.3/pigz --fast -c $subdir/$sr2 > $subdir/$sr2_gz");
	system("date");
	system("echo $sample gzip finished");
    }
}

system("echo");
system("echo concatenate all files begin");
system("date");
system("cat $allsub_R1 > $subdir/Undetermined_S0_R1_subsampled.fastq.gz");
system("cat $allsub_R2 > $subdir/Undetermined_S0_R2_subsampled.fastq.gz");
system("date");
system("echo concatenate all files finished");
system("echo");

system("rm $allsub_R1");
system("rm $allsub_R2");
system("rm $subdir/*.fastq");
system("echo directory cleaned up");
system("echo");
