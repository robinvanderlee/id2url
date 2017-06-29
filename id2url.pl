#!/usr/bin/env perl
##############################
## Robin van der Lee        ##
## @robinvanderlee          ##
##############################
my $VERSION = "1.1";
my $platform = $^O;

use warnings;
use strict;

# defaults
my $idFile = "";
my @presetUrls = ();
my @customUrls = ();
my $everyOther = 1;
my $batchSize = "all";
my $sleepSec = 0;
my $reverseOpen = 0;
my $unique = 0;
my $verbose = 0;
my $openUrlsAsIs = 0;
my $splitChar = "\n"; # by default splits the identifiers on all whitespace
my $lFlagProvided = 0;
my $singleIdentifier = "";

# initialize
&processCommandLineOptions;
my @urls = constructUrlArray();
my $numUrls = scalar @urls;
&verifyInput;

if($lFlagProvided){
  print "Paste your list of identifiers and proceed using ^D (ctrl+D):\n";
}

# get list of identifiers
my @idList = ();

if($singleIdentifier eq ""){
  @idList = &getIdlist;
} else {
  push(@idList, $singleIdentifier);
}

my $batchCounter = 0;
my $index = 0;
my $total = scalar @idList / $everyOther;
$total = int($total + 0.5); # round to nearest integer

# warn if many URLs will be opened
if($batchSize eq "all" && $total > 25){
  print "Opening $total identifiers in $numUrls URL(s)... Are you sure you want to continue? (press any key to do so)\n";

  #<>; # can't use <> because of ARGV association
  open USERIN, '<', '/dev/tty';
  <USERIN>;
  close USERIN;
}

# loop over all provided identifiers
foreach my $id (@idList){

  # open identifier it is the Xth in a row (by default: open all)
	if(($index % $everyOther) == 0){
		
    # clean up the provided identifier
    chomp $id;
		$id =~ s/^\s*//g; # trim whitespace at start
    $id =~ s/\s*$//g; # trim whitespace at end
		
    foreach(@urls){
      # construct the URL to be opened
      my $currentUrl = $_;
      $currentUrl =~ s/%s/$id/; # replace the %s placeholder in the URL string with the input identifier
      
      if($openUrlsAsIs == 1){
        $currentUrl = $id;
      }

      # construct the command to be run
      my $cmd = "";
      if ($platform eq 'darwin')  {
        ## bugged since OS X Yosemite:
        # "LSOpenURLsWithRole() failed with error -1712 for the URL $currentUrl"
        $cmd = "open \"$currentUrl\"";

        ## fix for OS X Yosemite
        # Fix 1
        # $cmd = "\"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome\" \"$currentUrl\" &> /dev/null"; # slow
        # Fix 2
        my $sleepFix = 0.1;
        $sleepSec = $sleepFix if $sleepSec < $sleepFix;

      } # Mac OS X
      elsif ($platform eq 'linux')   { $cmd = "x-www-browser \"$currentUrl\""; } # Linux
      elsif ($platform eq 'MSWin32') { $cmd = "start $currentUrl";             } # Win95..Win7
      else { die "Unknown OS. Cannot build the command for opening URLs from the command line.\n"; }

      # print informatie depending on verbosity level
      if($verbose == 2){
        print "$currentUrl\n";
      } 
    	
      # run the command
      if (defined $cmd) {
        `$cmd`;
      } else {
        die "Cannot locate default browser";
      }

      # wait a while if requested
      select(undef, undef, undef, $sleepSec); #sleep $sleepSec; # sleep doesn't work for intervals shorter than 1 second
    }

    # print informatie depending on verbosity level
    if($verbose == 1){
      print "$id\n";
    } elsif($verbose == 2){
      print "\n";
    } else {
      print ".";  
    } 

    # update count
		$batchCounter++;
		if($batchSize ne "all"){
			if(($batchCounter % $batchSize) == 0){

        my $left = $total - $batchCounter;
				if($left <= $batchSize){
          print " $batchCounter of $total identifiers opened, press any key to open the last $left\n";
        } else {
          print " $batchCounter of $total identifiers opened, press any key to open the next $batchSize\n";
        }

				#<>; # can't use <> because of ARGV association
				open USERIN, '<', '/dev/tty';
				<USERIN>;
				close USERIN;
			}
		}
	}

	$index++;
}

# finish
print "\n$batchCounter identifiers openend in $numUrls URL(s) -- Finished!\n";
exit 0;



###############
## functions ##
###############
sub getIdlist {
  my @idList;

  while(<>){
    chomp;
    push(@idList,split $splitChar); # split the line by the provided expression ($splitChar) and push all elements in the ID array
  }

  if($reverseOpen == 1){
    @idList = reverse @idList;
  }

  if($unique == 1){
    my %seen;
    my @unique = grep { not $seen{$_} ++ } @idList; # keep original order
    @idList = @unique;
  }

  return @idList;
}

sub loadUrls {
  my %urlHash = ( 1 => "http://www.uniprot.org/uniprot/%s",
                  2 => "http://www.ncbi.nlm.nih.gov/gene/%s",
                  3 => "http://www.ensembl.org/Homo_sapiens/Gene/Summary?g=%s",
                  4 => "http://www.ncbi.nlm.nih.gov/nuccore/%s",
                  5 => "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&cmd=search&term=%s",
                  6 => "http://genome.ucsc.edu/cgi-bin/hgTracks?hgHubConnect.destUrl=..%2Fcgi-bin%2FhgTracks&clade=mammal&org=Human&db=hg19&position=%s",
                  7 => "https://www.google.com/search?q=%s",
                  8 => "http://www.uniprot.org/uniprot/?query=organism%3Ahuman+%s",
                  9 => "http://www.ncbi.nlm.nih.gov/gene?term=%s%20AND%209606%5BTaxonomy%20ID%5D",
                  10 => "http://www.genecards.org/cgi-bin/carddisp.pl?gene=%s",
                  11 => "http://pfam.sanger.ac.uk/family/%s",
                  12 => "http://www.omim.org/entry/%s",
                  13 => "http://www.ebi.ac.uk/QuickGO/GTerm?id=%s",
                  14 => "http://www.rcsb.org/pdb/explore/explore.do?structureId=%s",
                  15 => "http://www.yeastgenome.org/cgi-bin/locus.fpl?locus=%s",
                  16 => "http://www.ncbi.nlm.nih.gov/projects/SNP/snp_ref.cgi?rs=%s",
                  17 => "http://www.ensembl.org/Homo_sapiens/Variation/Mappings?db=core;r=2:163123551-163124551;v=%s;vdb=variation;vf=1561949",
                  18 => "http://en.wikipedia.org/wiki/%s",
                  19 => "http://www.innatedb.ca/getGeneCard.do?id=%s");
  return %urlHash;
}

sub processCommandLineOptions {
    # foreach(@ARGV){ print "$_\n" }
    &showUsageAndExit unless @ARGV; # no arguments at all, not even a file name?
    
    while(defined ($_ = shift @ARGV)) {
        if ($_ eq '-h' || $_ eq '--help') {
            &showUsageAndExit;
        } elsif ($_ eq '-o') {
            $everyOther = shift @ARGV;
        } elsif ($_ eq '-b') {
            $batchSize = shift @ARGV;
        } elsif ($_ eq '-u') {
            @customUrls = split(/\,/, shift @ARGV);
        } elsif ($_ eq '-p') {
            @presetUrls = split(/\,/, shift @ARGV);
        } elsif ($_ eq '-s') {
            $sleepSec = shift @ARGV;
        } elsif ($_ eq '-l') {
            $lFlagProvided = 1;
        } elsif ($_ eq '-i') {
            $singleIdentifier = shift @ARGV;
        } elsif ($_ eq '-r') {
            $reverseOpen = 1;
        } elsif ($_ eq '-unq') {
            $unique = 1;
        } elsif ($_ eq '-e') {
            $splitChar = shift @ARGV;
        } elsif ($_ eq '-v') {
            $verbose = shift @ARGV;
        } elsif ($_ eq '-f') {
            $openUrlsAsIs = 1;
        } elsif ($_ =~ '-\w+') {
          print STDERR "ERROR -- Unknown option flag: $_\n";
          &showUsageAndExit;
        } else {
            $idFile = $_;
            $lFlagProvided = 0;

            unless(-e $idFile){
              print STDERR "ERROR -- file does not exist: $idFile\n";
              &showUsageAndExit;
            }
            
            unshift(@ARGV, $_); # put the last argument back so that it can be read by <>
            last;
        }
    }

    if($idFile eq "" && $lFlagProvided == 0 && -t STDIN && $singleIdentifier eq ""){
      print STDERR "ERROR -- no file or -l flag provided\n";
      &showUsageAndExit;
    }
}

sub constructUrlArray {
  my %urlHash = loadUrls();

  # array for storing all URLs
  my @urls = ();

  # first loop over all provided preset URLs and add them
  foreach my $presetUrl (@presetUrls){
    if( exists $urlHash{$presetUrl} ){
      push( @urls, $urlHash{$presetUrl} );
    } else {
      print STDERR "ERROR -- Preset URL(s) (-p) not valid: $presetUrl\n";
      &showUsageAndExit;
    }
  }

  # then loop over all provided custom URLs (if any) and add them
  if(scalar @customUrls != 0){
    foreach my $customUrl (@customUrls){
      push( @urls, $customUrl );
    }
  }

  # if not -p or -u flags were provided, push in the default url
  if(scalar @urls == 0){
    push( @urls, $urlHash{1});
  }

  return @urls;
}

sub verifyInput {
    unless (($everyOther =~ m/^\d*$/)  and  ($everyOther != 0)) {
        print STDERR "ERROR -- everyOther (-o) must be numeric and > 0\n";
        &showUsageAndExit;
    }
    unless (($sleepSec =~ m/^\d*\.?\d*$/)  and  ($sleepSec >= 0)) {
        print STDERR "ERROR -- sleepSec (-s) must be numeric and at least 0\n";
        &showUsageAndExit;
    }
    unless ( (($batchSize =~ m/^\d*$/)  and  ($batchSize != 0)) or ($batchSize eq "all") ) {
        print STDERR "ERROR -- batchSize (-b) must be numeric and > 0, or \"all\"\n";
        &showUsageAndExit;
    }
    unless ( $verbose =~ m/^[012]$/ ) {
        print STDERR "ERROR -- verbose (-v) must be 0, 1, or 2: $verbose\n";
        &showUsageAndExit;
    }

    foreach my $url (@urls){
      unless ($url =~ /\%s/ ) {
        print STDERR "ERROR -- URL (-u) is missing the '%s'-tag: $url\n";
        &showUsageAndExit;
      }
      unless ( $url =~ m/^https?\:\/\/[\w\.]+\.[a-zA-Z]{2,3}.*$/ ) {
        print STDERR "ERROR -- URL (-u) not valid: $url\n";
        &showUsageAndExit;
      }
    }
}

sub showUsageAndExit {
    my $usage = qq{
###################################
## Robin van der Lee             ##
## robin.vanderlee\@radboudumc.nl ##
###################################
  v$VERSION

Usage: $0 [options] <file with identifiers>
Open a set of web pages for a list of identifiers or other search terms, which can be supplied as a file, or entered by pasting under the -l flag.

    Examples:
      - ./id2url.pl uniprot_identifiers.txt
      - cut -f 2 biomart_with_entrez_idenfiers.txt | sort | perl id2url.pl -p 2
      - ./id2url.pl -b 5 -o 2 -v 1 -l
      - perl id2url.pl -u \"http:\/\/www.ncbi.nlm.nih.gov\/pubmed?cmd=search&term=%s%20immunity\"
          pubmed_identifiers_search_with_immunity.txt
      - ./id2url.pl -l -p 2,7,10 -u \"http://www.genome.jp/dbget-bin/www_bget?hsa:%s\"
    
    By default, identifiers should be on different lines (separated by a newline, \\n).

    General options. Default values in square brackets []:
               -h        Display this usage help information

               -l        Asks for a list of identifiers on the command line rather 
                           than reading in from a file; execute script with ^D (ctrl+D)
                           after pasting the identifiers
               -i <id>   Open the (single) identifier that is supplied as argument
               
               -v <x>    Verbosity [0]:
                           0 print only dots
                           1 print identifiers
                           2 print full URLs

               -e <expr> Split expression for identifiers [newline (\"\\n\")]
               -b <x>    Batchsize, open <x> URLs at a time [all]
               -o <x>    Go to the URL of every other <x> identifiers [1]
               -s <x>    Sleep time (<x> seconds) before opening next URL, can 
                           be a floating point number [0]
               -r        Open identifier URLs in reversed order
               -unq      Only open unique identfiers from the entered list

    URL options. Multiple URLs, separated by \"\,\", can be supplied using both the -u and -p flags:
               -u <url>  Custom URL, %s will be replaced by the identifier - 
                           e.g. \"http:\/\/www.uniprot.org\/uniprot\/%s\"
               -p <x>    Preset URLs, <x>:
                           1 UniProt [default]
                           2 Entrez human (9606)
                           3 Ensembl
                           4 RefSeq
                           5 PudMed
                           6 UCSC Genome Browser
                           7 Google (careful, might cause temporary ban!)
                           8 UniProt human search
                           9 Entrez human (9606) search
                           10 GeneCards
                           11 Pfam
                           12 OMIM
                           13 QuickGO
                           14 PDB
                           15 Saccharomyces Genome Database
                           16 dbSNP
                           17 Ensembl variation
                           18 Wikipedia
                           19 InnateDB

    Other options.
               -f        Open a set of pasted string (URLs) in the browser as is (i.e. without any
                           identifier inserted)

};
	print "$usage";
	exit;
}
