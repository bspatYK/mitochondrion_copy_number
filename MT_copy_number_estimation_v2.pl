#!/usr/bin/perl -w
use strict;
use warnings;

##scripts for MT copy number estimation;
##version: 2.0
##Author: boshiping@yikongenomics.com

my $sample                   = $ARGV[0];
my $outputfile               = $ARGV[1];
my $AS_reads                 = 0;
my $AS_dup_reads             = 0;
my $AS_ununiq_mapped_reads   = 0;
my $AS_rm_ununiq_dup_reads   = 0;
my $MT_reads                 = 0;
my $MT_dup_reads             = 0;
my $MT_ununiq_mapped_reads   = 0;
my $MT_rm_ununiq_dup_reads   = 0;


open OUT, ">$outputfile" or die "Cannot open output file!";

while(<STDIN>){
	chomp;
	my @line = split;
	if ($line[2] =~ /^(chr)?\d+$/)
	{
		$AS_reads++;
#		$AS_dup_reads++ if ($line[1] >= 1024 );
#		$AS_ununiq_mapped_reads++ if ($_ !~ /XT\:A\:U/ );
		$AS_rm_ununiq_dup_reads++ if ($line[1] < 1024 && $_ =~ /XT\:A\:U/);
	}elsif($line[2] =~ /^(chrM|MT)$/){
		$MT_reads++;
#		$MT_dup_reads++ if ($line[1] >= 1024 );
#		$MT_ununiq_mapped_reads++ if ($_ !~ /XT\:A\:U/ );
		$MT_rm_ununiq_dup_reads++ if ($line[1] < 1024 && $_ =~ /XT\:A\:U/);
		}
	}


#  autosome mapped reads/(autosome mappable region * 2) = relative amplification  efficiency * mitochondrion mapped reads/(mitochondrion mappable region * mitochondrion copy number)
#  => 
#  mitochondrion copy number =relative amplification  efficiency *  autosome mappable region * 2 *  mitochondrion mapped reads / mitochondrion mappable region * autosome mapped reads

my $AS_mappable_region_hg19 = 2684573005;
my $MT_mappable_region_hg19 = 16571;

my $MT_CN = int ($AS_mappable_region_hg19 * 2 * $MT_reads/($MT_mappable_region_hg19 * $AS_reads));
my $MT_CN_rm_ununiq_dup = int ($AS_mappable_region_hg19 * 2 * $MT_rm_ununiq_dup_reads/($MT_mappable_region_hg19 * $AS_rm_ununiq_dup_reads));

print OUT "\#Autosome_mappable_region_hg19: 2,684,573,005\n\#Mitochondrion_mappable_region_hg19: 16,571\n";
print OUT "\#Sample\tAutosome_mapped_reads\tMitochondrion_mapped_reads\tEstimated_MT_genome_copy_number\tAutosome_remove_ununiq_dup_mapped_reads\tMitochondrion_remove_ununiq_dup_mapped_reads\tEstimated_MT_genome_copy_number\(remove_ununiq_dup\)\n";
print OUT "$sample\t$AS_reads\t$MT_reads\t$MT_CN\t$AS_rm_ununiq_dup_reads\t$MT_rm_ununiq_dup_reads\t$MT_CN_rm_ununiq_dup\n";
close OUT or die "Cannot close output file!";
