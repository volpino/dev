package Juan::Other;
use strict;
use warnings;
use Carp;

sub joina {
	my $self = shift;
	my $conn = $self->{conn};
	my $chan = shift || return 0;
	$chan =~ /^#(.+)/ || return "Chan non valido";
	$conn->{channel} = $chan;
	$conn->join($conn->{channel});
	$conn->privmsg($conn->{channel}, $self->apply_modes($self->get_element_random("Ciao!! xDDD", "We we we!! :)))", "Holaaaa!", ":D Ehila' :D")));
	$conn->{connected} = 1;
	return 0;
}


sub humanoid {
	my $self = shift;
	my $text = $self->{event}->{args}[0];
	my $nick = $self->{event}->{nick};
	#stato d'animo in modo che funzioni anche una cosa tipo "come va Juan?"
    if ((($text =~ /come va/i) || ($text =~ /tutto ok\?/i) || ($text =~ /bene\?/i)) && ($text =~ /Juan/i)) {
    	return $nick . ": " . $self->get_element_random("eh dai va...", "tutto ok :D grazie", ":DDDD", "bene dai...pero' perche' non sfruttate un cinesino per lavorare gratis con orari indecienti?!? SCIOPERO",":D bene :D");
	}
	if (($text =~ /Juan/i) && ($text =~ /ti piace (.*)/i)) {
    	return $nick . ": " . $1 . "? Carino ma c'è di meglio...";
	}
    #saluti!
    if ($text =~ /ciao a tutti/i) {
    	return "ciao " . $nick . "!!";
    }
    if ($text =~ /^hola/i) {
    	return "hola a te " . $nick;
    }
    if ($text =~ /^lol/i) {
    	return $self->get_element_random("lol", "l0o0o0ol", "asd", "rotolol", "sbrodolol", "skol");
	}
    if ($text =~ /a dopo/i) {
    	return $self->get_element_random($nick . ": te ne vai di gia'?", $nick . ": ci si vede piu' tardi!", $nick . ": bye!", "Dove vai " . $nick . "!?");
    }
    #bestemmie
    if ((($text =~ /dio/i) && (($text =~ /porco/i) || ($text =~ /cane/i))) || (($text =~ /madonna/i) &&  ($text =~ /puttan/i))) {
    	return $self->get_element_random($nick . ": Amen!", $nick . ": God bless you");
    }
    #che palle
    if ($text =~ /^che palle/i) {
    	return $self->get_element_random("Dai " . $nick . " che sei una lagna!", $nick  . ": gioca un po con me se sei stufo xD");
    }
    return 0;
}

sub saluti_on_join {
	my $self = shift;
	my $nick = shift;
	my $output;
    $output = "Ciao caro admin!! :DDD" if ($nick eq "blacklight");
    $output = "Toh...un Gaggo :))" if ($nick eq "Gaggo");
    $output = "We volpe!" if ($nick =~ /fox/i);
    $output = ":O OMG! E' Dio! :O" if (($nick =~ /god/i) || ($nick =~ /goc/i));
    $output = ":-* miky :-*" if (($nick eq "BlackCode") || ($nick eq "nop"));
    if (!($nick =~ /juan/i)) {
		if ($output) {return $output;}
		else {return $self->get_element_random("Ciao " . $nick . "!!", "Su le mani per " . $nick . "!", "We " . $nick, "Ehila' " . $nick);}
	}
	return 0;
}

sub apply_modes {
	my $self = shift;
	my $out = shift;
	$out = $self->leet($out) if ($self->{leet});
	$out = $self->lamah($out) if ($self->{lamer});
	return $out;
}

sub get_element_random {
	my $self = shift;
	my @data = @_;
	return $data[int(rand(scalar(@data)))];
}

sub clean_html {
	my $self = shift;
    my $string = shift || return 0;
    $string =~ s/&egrave;/e'/ig;
    $string =~ s/&agrave;/a'/ig;
    $string =~ s/&raquo;/"/ig;
    $string =~ s/&laquo;/"/ig;
    $string =~ s/&Egrave;/e'/ig;
    $string =~ s/&ograve;/o'/ig;
    $string =~ s/&rsquo;/'/ig;
    $string =~ s/&igrave;/i'/ig;
    $string =~ s/<(.*)>/ /ig;
    $string =~ s/&lt;(.*)&gt;>/ /ig;
    $string =~ s/&amp;/&/ig;
    return $string;
}

sub get_data {
	my $self = shift;
	my $nick = shift || return 0;
	my $file = shift || return 0;
	open(LOG_OUT, "<logs/" . $file);
	while (<LOG_OUT>) {
		if ($_ =~ /^$nick, (.*)/) {
			return $1;
		}
	}
	return 0;
}

sub save_data {
	my $self = shift;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year+=1900;
    $mon+=1;
    my $nick = shift || return 0;
    my $file = shift || return 0;
    my $reg_data = shift || " ";
    open(LOG_OUT, "<logs/" . $file);
	my @data = <LOG_OUT>;
    close(LOG_OUT);
    for (my $i = 0; $i < scalar(@data); $i++) {
   		if ($data[$i] =~ /^$nick, /) {
   			splice (@data, $i, 1);
   		}
   	}
   	push (@data, $nick . ", "  . $reg_data . ", "  . $mday . "/" . $mon . "/" . $year . "\@" . $hour . ":" . $min . "\n");
   	open(LOG_IN, ">logs/" . $file);
   	foreach my $riga (@data) { print LOG_IN $riga }
   	close(LOG_IN);	
   	return 0;
}

sub kill_data {
	my $self = shift;
	my $del_data = shift;
	my $file = shift;	
	open(KILL_OUT, "<logs/" . $file);
	my @data = <KILL_OUT>;
    close(KILL_OUT);
    for (my $i = 0; $i < scalar(@data); $i++) {
   		if ($data[$i] eq $del_data) {
   			splice (@data, $i, 1);
   		}
   	}
   	open(KILL_IN, ">logs/" . $file);
   	if (@data) {
   		foreach my $riga (@data) { print KILL_IN $riga }
	}
   	close(KILL_IN);
   	return 0;
}

1;

