package Juan::Main;

use strict;
use warnings;
use base qw(Juan::Core Juan::Other);

sub new {
	my $this = shift;
	my $classe = ref($this) || $this;
	# Things to pass to the hash -> 
	# name => bot's name
	# server => server address
	# port => server's port
	# debug => debug level [0/1]
	# log => log the text in the channel [0/1]
	# lamer => lamer mode
	# leet => leet mode
	# web_wtf => web_wtf mode
	# conn => $conn   |__ objects from Net::Irc
	# event => $event |
	my %hash = @_;
	my $self = bless \%hash, $classe;
	return $self;
}	

sub set_conn {
	my $self = shift;
	$self->{conn} = shift if (@_);
	return $self;
}

sub set_event {
	my $self = shift;
	$self->{event} = shift if (@_);
	return $self;
}

sub main {
	my $self = shift;
	my $text = $self->{event}->{args}[0];
	my $nick = $self->{event}->{nick};
	print $self->get_messaggi($nick);
	#return $self->get_messaggi($nick) if (!($self->get_messaggi($nick) eq "0")); #check messaggi
	#vede se è chiamato in causa
    if ($text =~ /^juan(:|,) (.*)/i) {
        my $cmd = $2;
        if ($cmd =~ /^striscia/i) {
            return $self->striscia_rossa;
        }
        elsif ($cmd =~ /^ricorda (.*)/i) {
			$self->ricorda($1);
			return 0;
        }
        #per Smith a cui piacciono tanto le immagini di 4chan
        elsif ($cmd =~ /^images add (.+)/i) {
			$self->archive($1, "images", $nick);
			return 0;
        }
        elsif ($cmd =~ /^images/i) {
			foreach my $link ($self->archive_list("images")) {$self->{conn}->privmsg($self->{event}->{nick}, $link)};
			return 0;
        }
        #siti affiliati e links vari
        elsif ($cmd =~ /^links add (.+)/i) {
			$self->archive($1, "links", $nick);
			return 0;
        }
        elsif ($cmd =~ /^links/i) {
			foreach my $link ($self->archive_list("links")) {$self->{conn}->privmsg($self->{event}->{nick}, $link)};
			return 0;
        }
        #rutta, muore, scoreggia
        elsif ($cmd =~ /^rutta/i) {
        	return $self->get_element_random("burp :)", "burppp!! ...ops...", "ROAR!!", "burp!!...Digerito!" );
        }
        elsif (($cmd =~ /^muori/i) || ($cmd =~ /^taci/i)) {
            return $self->get_element_random(":(( Juan muore :((", "Sono immortale...bwuahuahauah", "Juan R.I.P");
        }
        elsif ($cmd =~ /^scoreggia/i) {
            return $self->get_element_random("proooot!!...ops!", "proooot!....e fu cosi' che tutto il chan mori' per la puzza", "prottt! :DDD");
        }
        #about
        elsif ($cmd =~ /^about/i) {
            return  $nick . ": This bot has been written by fox - fox91 at anche dot no  - It's called Juan because when I was choosing the bot name I was listening to Ska-P music (Juan sin tierra) - June/July 2008";
        }
        #features
        elsif (($cmd =~ /^features/i) || ($cmd =~ /^comandi/i) || $cmd =~ /^help/i) {
            return  $nick . ": inserire features!!! :D";
        }
        #hai visto?
        elsif ($cmd =~ /^hai visto (.+)\?/i) {
 			return $nick . ": " . $self->hai_visto($1);
        }
        #chuck norris facts
        elsif (($cmd =~ /^chuck/i) || ($cmd =~ /^facts/i)) {
            return $nick . " " . $self->chuck;
        }
        #news
        elsif (($cmd =~ /^news (.+)/i) || ($cmd =~ /^news/i)) {
            return $nick . ": " . $self->news($1);
        }
        #fortunes (of course you need the fortune game installed)
        elsif ($cmd =~ /^fortune/i) {
			return $nick . ": " . $self->fortune;
        }
        #modes .-.
        elsif ($cmd =~ /^mode (.+) (.+)/i) {
			return $self->modes($1, $2);
        }
        #converte il testo passato in l33t
        elsif ($cmd =~ /^leet (.*)/i) {
            return $nick . ": " . $self->leet($1);
        }
        #converte il testo in lAmEr TeXt
        elsif ($cmd =~ /^lamer (.)/i) {
            return $nick . ": " . $self->lamah($1);
        }
        #roulette russa
        elsif ($cmd =~ /^roulette classifica (.+)/i) {
			return $self->roulette_classifica_nick($1);
		}
        elsif (($cmd =~ /roulette/i) && ($cmd =~ /classifica/i)) {
			foreach my $classifica ($self->roulette_classifica) {$self->{conn}->privmsg($self->{event}->{nick}, $classifica)};
			return 0;
		}
        elsif ($cmd =~ /^roulette/i) {
			return $self->roulette($nick);
		}
        elsif ($cmd =~ /^appena vedi (.+) digli (.*)/i) {
			return $self->save_data($1, "messaggi", $2 . ", " . $nick);
		}
        else {
            #se non viene inserito nessun comando piglia una frase a tema dal file di ricorda
            return $nick . ": " . $self->get_ricorda($cmd) if ($self->get_ricorda($cmd));
            }
    }
    
    #funzioni che rendono il bot (poco) umano
	return $self->humanoid if (!($self->humanoid eq "0"));
	
	#vede se c'è un url e in caso fa un url_wtf
	return $self->url if (($self->{web_wtf}) && $self->url);
	
	if ($text =~ /^juan(:|,)/i) {
    	#spara frasi a cazzo se non sa cosa dire lol
    	return $nick . ": " . $self->get_element_random("No entiendo!!", "Si??","lo0o0o0ol","Stavate parlando di meee?!", "I'm only a bot, maricon!", "._. fottiti ._.", "Coomeeee?", "sono solo un bot -.-'" );
    }
}

1;
