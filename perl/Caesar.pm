package Caesar;

use strict;

sub new {
	my $this = shift;
	my $classe = ref($this) || $this;
	# Things to pass to the hash -> key and string
	# Example: my $obj = Caesar->new(key => 13, string => 'string');
	my %hash = @_;
	
	my $self = bless \%hash, $classe;
	return $self;
}

sub set_key {
	my $self = shift;
	if (@_) { $self->{key} = shift }
	return $self->{key};
}

sub set_string {
	my $self = shift;
	if (@_) { $self->{string} = shift }
	return $self->{string};
}

sub encode {
	my $self = shift;
	my @alpha = ('a'..'z');
	$self->{string} = lc($self->{string});
	my @letters = split ('', $self->{string});
	for (my $i = 0; $i < scalar(@letters); $i++) {
		for (my $j = 0; $j < 26; $j++) {
			if ($alpha[$j] eq $letters[$i]) {
				my $shift = $j + $self->{key};
				if ($shift => 26) { $letters[$i] = $alpha[$shift - 26]; }
				else { $letters[$i] = $alpha[$shift]; }
				last;
			}
		}
	}
	$self->{string} = join('', @letters);
	return $self->{string};
}

1;
