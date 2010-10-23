#!/usr/bin/perl -w
#Author: fox
#
# Bot scritto alla cazzo per vedere chi e' online sul chan del
# Trento H4ckl4b JJ1

# File tipo generato dal bot:
# -------------------------------------------
# Utenti online ora: user1, user2, user3
# Utenti visti oggi: user1@orajoin-oraout, user2...

use Net::IRC;
use Data::Dumper;
use strict;
use warnings;
use Carp;

my $chan = '#jj1';
our $logfile = 'militantone.log';
our $chanlog = $chan . '.log';
our @online;
our %seen;
our %messages;

print q {
	
	~ Militantone IRC bot by fox ~
		
};

my $irc = new Net::IRC;
#Connection settings
my $conn = $irc->newconn(
	Server 		=> 'irc.freenode.net',
	Port		=> '6667',
	Nick		=> 'Militantone',
	Ircname		=> 'jjone',
	Username	=> 'jjone'
);
die "I can't connect" unless ($conn);

#joina #jj1
$conn->{channel} = $chan;
$conn->join($conn->{channel});

#saluta il chan :)
my @saludos = ("Ciao!", "We we we!! :)", "Holaaaa!", ":D Ehila' :D");
$conn->privmsg($conn->{channel}, $saludos[int(rand(scalar(@saludos)))]);
$conn->{connected} = 1;
print "[+] Connected\n";

sub on_public {
	my ($conn, $event) = @_;
	my $text = $event->{args}[0];
    my $nick = $event->{nick};
    my $output;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    open (CHANLOG, ">>" . $chanlog);
    print CHANLOG "[" . $hour . ":" . $min . "] < " . $nick . " >" . "  " . $text . "\n";
    close (CHANLOG);
    #check messaggi
    foreach my $key (keys(%messages)) {
        if (($key eq $nick) && ($messages{$key})) {
            $output = $nick . ": ho un messaggio per te: " . $messages{$key};
            $messages{$key} = undef;
        }
    }
    #vede se e' stato chiamato in causa da qualcuno
	if ($text =~ /^Militantone[:|,] (.*)/i) {
        my $cmd = $1;
        if ($cmd =~ /^striscia/i) {
        	$conn->privmsg($conn->{channel}, striscia_rossa());
        }
        elsif ($cmd =~ /^ricorda (.*)/i) {
            open(OUT, ">>ricorda");
            print OUT $1, "\n";
            close(OUT);
        }
        #rutta, muore, scoreggia
        elsif ($cmd =~ /^rutta/i) {
        	my @rutta = ("burp :)", "burppp!! ...ops...", "ROAR!!", "burp!!...Digerito!" );
            $output = $nick . ": " . $rutta[int(rand(scalar(@rutta)))];
        }
        elsif ($cmd =~ /^muori/i) {
        	my @muori = (":(( Militantone muore :((", "Sono immortale...bwuahuahauah", "Militantone R.I.P");
            $output = $nick . ": " . $muori[int(rand(scalar(@muori)))];
        }
        elsif ($cmd =~ /^scoreggia/i) {
        	my @scoreggia = ("proooot!!...ops!", "proooot!....e fu cosi' che tutto il chan mori' per la puzza", "prottt! :DDD");
            $output = $nick . ": " . $scoreggia[int(rand(scalar(@scoreggia)))];
        }
        #about
        elsif ($cmd =~ /^about/i) {
            $output =  $nick . ": Militantone - bot scritto da fox in un momento di follia || JJ1 Trento h4ckl4b";
        }
		#chuck norris facts
		elsif (($cmd =~ /^chuck/i) || ($cmd =~ /^facts/i)) {
			$output = $nick . ": " . chuck();
		}
		elsif (($cmd =~ /^news (.*)/i) || ($cmd =~ /^news/i)) {
            $output = $nick . ": " . news($1);
        }
        elsif ($cmd =~ /^tinyurl (((http[s]?:\/\/|www\.)(\w+\.)+\w{2,4}(\/(.+?)?)?)([ ]|$))/i) {
        	$output = $nick . ": " . tinyurl($1);	
        }
        elsif ($cmd =~ /^se vedi (\w+) digli (.*)/) {
        	%messages = (%messages, $1 => $nick . " | " . $2);
            $output = $nick . ": senz'altro :)";
        }
        else {
            #se non viene inserito nessun comando piglia una frase a tema da file di ricorda
            my @frasi;
            open(IN, "ricorda");
            $cmd =~ s/\?/ /i;
            while (<IN>) {
                if ($_ =~ /$cmd/) {
                    push (@frasi, $_);
                }
            }
            close(IN);
            if (@frasi) {
                $output = $nick . ":  " . $frasi[int(rand(scalar(@frasi)))];
            }
            if (!@frasi) {
                #spara frasi a cazzo se non sa cosa dire lol
                my @cazzate = ("No entiendo!!", "Si??","lo0o0o0ol","Stavate parlando di meee?!", "._. fottiti ._.", "Coomeeee?", "sono solo un bot -.-'" );
                $output = $nick . ": " . $cazzate[int(rand(scalar(@cazzate)))];
            }
        }
	}
	$conn->privmsg($conn->{channel}, $output) if ($output);
}

sub on_msg {
	my ($conn, $event) = @_;
	my $nick = $event->{nick};
	$conn->privmsg($conn->{channel}, $nick . " mi sta querando...e' proprio ghei ._.");

}

sub on_join {
	my ($conn, $event) = @_;
	$conn->names($chan);
	my $nick = $event->{nick};
	my @join = ("Ciao " . $nick . "!!", "Su le mani per " . $nick . "!", "We " . $nick, "Ehila'");
	$conn->privmsg($conn->{channel}, $join[int(rand(scalar(@join)))]) unless ($nick eq "Militantone");
}
	
sub on_part {
	my ($conn, $event) = @_;
	my $nick = $event->{nick};
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	#rifaccio il names
	$conn->names;
   	#lo metto in %seen
   	%seen = (%seen, $nick => $mday . "/" . $mon . "/" . $year . "\@" . $hour . ":" . $min);
   	save_to_file();
}

sub on_names {
    my ($conn, $event) = @_;
    @online = split (" ", $event->{args}[3]);
    save_to_file();
} 

$conn->add_handler('public', \&on_public);
$conn->add_handler('msg', \&on_msg);
$conn->add_handler('join', \&on_join);
$conn->add_handler('part', \&on_part);
$conn->add_global_handler('353', \&on_names);
$irc->start();


sub save_to_file {
	open(FILE, ">" . $logfile);
	print FILE "~ Chan " . $chan . "stats by Militantone ~\n";
	print FILE "Utenti online ora: " . join (', ',@online) . "\n";
	print FILE "Utenti visti oggi: " . join (', ',keys(%seen)) . "\n";
	print FILE "\n\nDettagli: \n";
	print FILE "---------------------------------------\n";
	my @keys = keys %seen;
    foreach my $key (@keys) {
    	print FILE $key . "\t||\t" . $seen{$key} . "\n";
    }
	close(FILE);
}

#funzione striscia rossa
sub striscia_rossa {
    use LWP::UserAgent;
    my $ua = LWP::UserAgent->new;
    my $response = $ua->get('http://www.unita.it/strisciarossa.asp');
    my $content = $response->content;
    $content =~ /<div class="testo_riquadro"><b>(.+?)<\/b>/ims;
    my $striscia = $1;
    $content =~ /<\/b><br>(.+?)<br>/ims;
    my $autore_striscia = $1;
    return clean_html($striscia), " " , clean_html($autore_striscia);
}

#funzione per pulire l'encoding HTML dall'output di striscia_rossa()
sub clean_html {
    my $string = shift;
    $string =~ s/&egrave;/e'/ig;
    $string =~ s/&agrave;/a'/ig;
    $string =~ s/&raquo;/"/ig;
    $string =~ s/&laquo;/"/ig;
    $string =~ s/&Egrave;/e'/ig;
    $string =~ s/&ograve;/o'/ig;
    $string =~ s/&rsquo;/'/ig;
    $string =~ s/&igrave;/i'/ig;
    return $string;
}

#prende i facts del mitico chuck da welovechucknorris
sub chuck {
	use LWP::UserAgent;
	my $page = "http://welovechucknorris.blogspot.com/";
    my $ua = LWP::UserAgent->new;
    my $response = $ua->get($page);
    my $content = $response->content;
    my @lines = split("\n", $content);
    my @facts;
    foreach my $line (@lines) { 
    	if ($line =~ /<span style="font-weight: bold;">(.+?)<\/span> <span style="font-size:78%;">/) {
    		push (@facts, $1);
    	}
	}
    return $facts[int(rand(scalar(@facts)))];	
}

#news
sub news {
    use LWP::UserAgent;
	use XML::RSS::Parser;
	my $fonte = shift;
	my $err = "Fonti disponibili: Slashdot, Autistici.org, Adnkronos (Ign), Repubblica, TuxFeed, ZioBudda";
	my $page;
	return $err if (!$fonte);
	$page = "http://rss.slashdot.org/Slashdot/slashdot" if ($fonte =~ /^slashdot/i);
	$page = "http://www.adnkronos.com/RSS/RSS_Ultimora.xml" if (($fonte =~ /^adnkronos/i) || ($fonte =~ /^ign/i));
	$page = "http://www.autistici.org/planet/rss20.xml" if ($fonte =~ /autistici/i);
	$page = "http://www.repubblica.it/rss/homepage/rss2.0.xml" if ($fonte =~ /repubblica/i);
	$page = "http://feeds.feedburner.com/Tuxfeed?format=xml" if ($fonte =~ /tuxfeed/i);
	$page = "http://feeds.feedburner.com/ziobudda/rss?format=xml" if (($fonte =~ /ziobudda/i) || ($fonte =~ /zio budda/i));
	return $err if (!$page);
	my $ua = LWP::UserAgent->new;
    my $response = $ua->get($page);
    my $content = $response->content;

    my $p = XML::RSS::Parser->new;
 	my $feed = $p->parse_file($page);
 	my @items = $feed->query('//item');
 	my $news = $items[int(rand($feed->item_count))];
 	my $title = $news->query('title')->text_content;
	my $feed_title = $feed->query('/channel/title')->text_content;
	my $url = $news->query('link')->text_content;
	my $res = clean_html($feed_title . ": " . $title . " --> " . tinyurl($url));
    return $res;
}

#funzione che rimpicciolisce gli url grazie a tinyurl
sub tinyurl {
	my $url = shift;
	use LWP::UserAgent;
  	my $ua = LWP::UserAgent->new;
  	my $req = HTTP::Request->new(POST => "http://tinyurl.com/create.php");
  	$req->content_type("application/x-www-form-urlencoded");
  	$req->content("url=" . $url . "&submit=Make+TinyURL%21&alias=");
  	my $response = $ua->request($req);
  	my $content = $response->content;
  	$content =~ /<blockquote><b>(.+?)<\/b><br><small>\[<a href="http:\/\/tinyurl.com/i;
  	return $1;
}
