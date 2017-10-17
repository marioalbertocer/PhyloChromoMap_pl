# This script creates the intervals of 1000 kb for the chromosome maps. 
# Then it places the OGs and loci in their interval. Beware that the output
# can have more than one OG/seq per interval. So, it's necesary to inspect 
# those few cases by hand. The script 'mapInfoHelper' would be very useful
# for performimg that task. 

# Input: 
# - criteriaANDcounts_out.txt from 'treesCriteria_counts'
# - folder with genomic sequences
# - folder with CDSs

my $folder = "Saccharomyces_cerevisiae/";
my $path = "/Users/marioceron/Documents/katzlab/duplications/orthomcl-release5/";
my $out = open(OUT, ">>". $path . $folder . "mapInfo.txt") or die "I cannot open OUT";
my $toMap = open(TOMAP, $path . $folder . "criteriaANDcounts_out.txt") or die "I cannot open TOMAP";
my @toMap = <TOMAP>;
 
my $chrDir = opendir(CHRDIR, $path . $folder . "genome/") or die "I cannot open the dir CHRDIR\n";
my @chrDir = readdir CHRDIR;

# for each chromosome... 
foreach my $chrFile (@chrDir) {

 	# Here we create the intervals from the genome sequences
 	# it takes the sequences, calculate lenght and do intervals each
 	# 1000 kb up to the length of the chromosome.
 	
 	if ($chrFile =~ ".fasta") {
  		my @intervals = ();
 		my $chr = $chrFile;
 		$chr =~ s/\..*$//;
 		my $chrSeq_File = open(CHRSEQ, $path . $folder . "genome/" . $chr . ".fasta") or die "I cannot open CHRSEQ\n";
 		my @chrSeq = <CHRSEQ>;
 		@chrSeq = grep {!/>/} @chrSeq; # for deleting lines containing tags
 		my $chrSeq = join("", @chrSeq);
 		$chrSeq =~ s/\n//g;
 		my $chrLen = length($chrSeq);

 		my $m = 1000; # length of the intervals
 		my $position = 1;
 		push (@intervals, $position);

 		while ($position <= $chrLen) {
 			$position = $position + $m;
 			push(@intervals, $position)
 		}

 		# At this point the intervals are already done and saved in a array. Now we are going 
 		# to read the coding sequences. In future lines we will use them for grabbing the loci from the tags. 
 		my $cdsFile = open(CDSFILE, $path . $folder . "seqs/" . $chr . ".txt") or die "I cannot open CDSFILE\n";
 		my @cdsFile = <CDSFILE>;

 		# Now we need the data that we are going to map in the intervals. So, we take the info from 'criteriaANDcounts_out'
 		my @toMap_loci = ();
 		foreach my $line (@toMap) {
 			chomp $line;
 			if ($line =~ $chr) {		# As we are working per chromosome (see first loop above). Then we need to filter the lines 
 										# that containg that chromosome
 		
 				if ($line !~ "no_group") {	# We just need OGs, no 'no_groups'
 					my @values = split("\t", $line);
 					my $seq = $values[1];
 					my $og = $values[2];
 					my $criterion = $values[5];
 					my @counts = @values[6..13];
 					my $counts = join("\t", @counts); 			

 					if ($criterion =~ "yes") {	# only consider OGs that meet our criterion
 						foreach my $line2 (@cdsFile) {
 							if ($line2 =~ $seq) {
 							
 								# Here we take the locus of every sequence for placing it on the intervals					
 								my @line2 = split(" ", $line2);
 								my $loci = $line2[-1];
 								$loci =~ s/^.*=//;
 								$loci =~ s/[A-z]//g;
 								$loci =~ s/\(|\)|\[|\]//g;
 								$loci =~ s/\.\./,/g;
 								my @loci = split(",", $loci); 							
 							
 								# Now we have all loci of the seqs rgat 
 								my @loci_sorted = ();
								foreach my $locus (@loci) {
 									push (@loci_sorted, $locus);
								} 							
 								@loci_sorted = sort {$a <=> $b}	@loci_sorted;
 								push (@toMap_loci, "locus:" . $loci_sorted[0] . "-" . $loci_sorted[-1] . "\t" . "seqID:" . $seq . "\t" . "OG:" . $og . "\t" . "counts:" . $counts);	
 							}
 						}	 					
 					}	
 				} 			
 			}	
 		}

		foreach my $interval (@intervals) {
 			@neighbors = ();

			foreach my $toMap_locus (@toMap_loci) {
				my $locus = $toMap_locus;
 				$locus =~ s/\t.*$//;
 				$locus =~ s/locus://;
 				$locus =~ s/-.*$//;
 				
 				if ($locus >= $interval) {
 					if ($locus < ($interval + 1000)) {
 						push (@neighbors, $toMap_locus);
 					}
 				}			
			}		

 			if (@neighbors == ()) {
 				print $chr . "\t" . $interval . "\n";
 				print OUT $chr . "\t" . $interval . "\n";
 			} else {
 				my $neighbors = join("\t", @neighbors);
 				print $chr . "\t" . $interval . "\t" . $neighbors . "\n";
 				print OUT $chr . "\t" . $interval . "\t" . $neighbors . "\n"; 				
 			}
		}
 	}
}