my $path = '/Users/marioceron/Documents/katzlab/duplications/orthomcl-release5/Encephalitozoon_cuniculi_E3/BlastReports/';

my $dirBlast = opendir(BLAST_REPS, $path);
my @dirBlast = readdir BLAST_REPS;

foreach my $blast (@dirBlast){
	if ($blast =~ /\.out/) {
		my $chr = $blast;
		$chr =~ s/\.out$//; 
		$blast = open(BLAST, $path.$blast) or die "I cannot open the file $path$blast\n";
		my @blast = <BLAST>;
		
		my $index = 0;
		my @queries = ();
		my @positions = ();
		
		foreach my $line (@blast){
			$index += 1;
			
			if ($line =~ /^Query=/){
				my $query = $line;
				$query =~ s/^.*_cds_//;
				$query =~ s/_[0-9]+\s\[gene.*\n$//;
				
				push(@queries, $query);
				push(@positions, $index - 1);
			}
		} 
		
		my $index_b = 0;
		
		foreach my $query (@queries){

			$index_b += 1;
			my $record_start = $positions[$index_b - 1];
			my $record_end;

			if ($index_b < $positions[$index_b]){
				$record_end = $positions[$index_b];	
			} else {
				$record_end = scalar @blast;
			}			
			
			my @record = @blast[$record_start..$record_end];
			
			foreach my $line (@record) {
				if ($line =~ /^  [a-z]{4}/) {
					$line =~ s/\n$//;
					$line =~ s/(^\s+)|(\s+$)//g;
					$line =~ s/\s\|\s/\|/g;
					$line =~ s/\|\s+/\|no description\|/g;
					$line =~ s/\s{2,}/\|/g;
					$line =~ s/\s{2,}|\|/\t/g;
					my @values = split("\t", $line);
										
					my $sps = $values[0];
					my $access = $values[1];
					my $og = $values[2];
					my $description = $values[3];
					my $score = $values[4];
					my $e_val = $values[5];
					
					if ($e_val < 1e-15) {
						print "$chr\t$query\t$sps\t$access\t$og\t";  
						print "$description\t$score\t$e_val\n";
					}
				}	
			}
		}
	}
}
