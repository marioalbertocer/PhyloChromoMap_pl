my $summary = open(SUMMARY, "/Users/marioceron/Documents/katzlab/duplications/orthomcl-release5/Saccharomyces_cerevisiae/summary.txt") or die "can't open summary";
my $out = open(OUT, ">>/Users/marioceron/Documents/katzlab/duplications/orthomcl-release5/Saccharomyces_cerevisiae/bestOGsXseq_out.txt") or die "can't open out";
my @summary = <SUMMARY>;

# Here we have a subrutine that would be useful latter
# It creates an array with unique elements from another array

sub uniq {
	my %seen;
	return grep {!$seen{$_}++} @_;
}

# here we build a list like "chromosome	sequence"

my @list = ();

foreach my $line (@summary) {
	@line = split("\t", $line);
	push(@list, "$line[0]\t$line[1]");
}

my @list = uniq(@list); 	# Creating categories. The same "chromosome	sequence" can be many times in the 
							# report from parseBLASTut.rb because a sequence can blast more than one OG 
							# and more than one sps. 

foreach my $line (@list) {
	my @info = split("\t", $line);
	my $chr = $info[0]; 		
	my $seq = $info[1];
	
	my $pickedEval = 1;
	my $pickedOG = "";
	my $og = "";
	
	foreach my $line2 (@summary){  # for each category (chr seq) read the report again
		
		if ($line2 =~ $seq) {
			$line2 =~ s/\n$//;
			my @values = split("\t", $line2);
			my $e_val = $values[-1];  # from each blast result per category collect eval 
			$og = $values[4];  # ... and og
			
			# in the next step we compare the eval of the results per category (except
			# the ones that has no_group instead of a regular OG. Then, we pick the 
			# lowest. 
				
			if ($og !~ 'no_group'){
				if ($e_val < $pickedEval) {
					$pickedEval = $e_val;
					$pickedOG = $og;					
				}
			}
		}
	}

	if ($pickedEval == 1){
		$pickedEval = "NA";
	}
	
	if ($pickedOG eq "") {
		$pickedOG = $og;
	}
	
	print "$chr\t$seq\t$pickedOG\t$pickedEval\n";
	print OUT "$chr\t$seq\t$pickedOG\t$pickedEval\n";
}

	