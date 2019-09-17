#!/usr/bin/perl

## loading obogaf::parser and useful Perl module
use strict;
use warnings;
use obogaf::parser; 

## elapased time 
use Time::HiRes qw(time);
my $start= time;

## recursively create directories ([-p] mkdir option in perl does not work)
use File::Path qw(make_path); 

## create folder where storing example I/O files
use File::Path qw(make_path);
my $basedir= "../example/HPOdata/";
make_path($basedir) unless(-d $basedir);

## note: if case you want to store data in your home, use File::HomeDir
# use File::HomeDir qw(home);
# my $basedir = File::HomeDir->my_home."/data/";
# mkdir $basedir unless(-e $basedir);
 
## declare variables 
my ($res, $stat, $parentIndex, $childIndex, $geneindex, $classindex); 

## ~~ HPO OBO ~~ ## 
## download HPO obo file
my $obofile= $basedir."hpo.obo";
my $hpobo= qx{wget --output-document=$obofile http://purl.obolibrary.org/obo/hp.obo};
print "HPO obo file downloaded: done\n\n";

## extract edges from HPO obo file
my $hpores= obogaf::parser::build_edges($obofile);
my $hpoedges= $basedir."hpo-edges.txt"; ## hpo edges file declared here 
open OUT, "> $hpoedges"; 
print OUT "${$hpores}"; ## scalar dereferencing
close OUT;
print "build HPO edges: done\n\n";

## make stats on HPO 
($parentIndex, $childIndex)= (0,1);
$res= obogaf::parser::make_stat($hpoedges, $parentIndex, $childIndex);
print "$res";
print "\nHPO stats: done\n\n";

## ~~ HPO ANNOTATION ~~ ## 
## download HPO annotations 
my $hpofile= $basedir."hpo.ann.txt"; ## hpo annotation file declared here
my $hpoann= qx{wget --output-document=$hpofile http://compbio.charite.de/jenkins/job/hpo.annotations.monthly/lastStableBuild/artifact/annotation/ALL_SOURCES_ALL_FREQUENCIES_genes_to_phenotype.txt};

## extract HPO annotations 
($geneindex, $classindex)= (1,3);
($res, $stat)= obogaf::parser::gene2biofun($hpofile, $geneindex, $classindex);
my $hpout= $basedir."hpo.gene2pheno.txt";
open OUT, "> $hpout";
foreach my $k (sort{$a cmp $b} keys %$res) { print OUT "$k $$res{$k}\n";} ## dereferencing
close OUT;
print "${$stat}\n";
print "build HPO annotations: done\n\n";

## ~~ MAP HPO TERMS BETWEEN RELEASE ~~ ## 
## download old HPO annotation file
my $hpofileOld= $basedir."hpo.ann.old.txt"; ## goa annotation file declared here
my $hpold= qx{wget --output-document=$hpofileOld http://compbio.charite.de/jenkins/job/hpo.annotations.monthly/139/artifact/annotation/ALL_SOURCES_ALL_FREQUENCIES_genes_to_phenotype.txt};

## map HPO terms between release
($res, $stat)= obogaf::parser::map_OBOterm_between_release($obofile, $hpofileOld, 3);
my $mapfile= $basedir."hpo.ann.mapped.txt";
open OUT, "> $mapfile"; 
print OUT "${$res}";
close OUT;
print "${$stat}";

## ~~ ELAPSED TIME ~~ ## 
print "\n\n";
my $span= time - $start;
$span= sprintf("%.4f", $span);
printf "Elapased Time:\t$span\n";

exit;


