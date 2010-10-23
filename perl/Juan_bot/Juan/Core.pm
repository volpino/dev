package Juan::Core;
use strict;
use warnings;
use Carp;

#funzione striscia rossa
sub striscia_rossa {
	my $self = shift;
    use LWP::UserAgent;
    my $ua = LWP::UserAgent->new;
    my $response = $ua->get('http://www.unita.it/strisciarossa.asp');
    my $content = $response->content;
    $content =~ /<div class="testo_riquadro"><b>(.+?)<\/b>/ims;
    my $striscia = $1;
    $content =~ /<\/b><br>(.+?)<br>/ims;
    my $autore_striscia = $1;
    return $self->clean_html($striscia) . " " . $self->clean_html($autore_striscia);
}

sub ricorda {
	my $self = shift;
	my $text = shift || return 0;
	open(OUT, ">>logs/ricorda");
    print OUT $text, "\n";
    close(OUT);
    return 0;
}

sub get_ricorda {
	my $self = shift;
	my $string = shift || return 0;
	my @frasi;
	$string =~ s/\?/ /i;
	open(IN, "<logs/ricorda");
    while (<IN>) {
    	if ($_ =~ /$string/i) {
    	push (@frasi, $_);
    	}
    }
    close(IN);
    if (@frasi) {
    	return $self->get_element_random(@frasi);
    }
    return 0;
}

sub archive {
	my $self = shift;
	my $link = shift || return 0;
	my $type = shift || return 0;
	my $nick = shift || return 0;
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year+=1900;
    $mon+=1;
    #controllo sfigatissimo
    if ($link =~ /^http:\/\//i) {
    	open(ARCHIVE_OUT, ">>logs/image_archive") if ($type eq "images");
    	open(ARCHIVE_OUT, ">>logs/links") if ($type eq "links");
        print ARCHIVE_OUT $link . "  -  by " . $nick . " on " . $mday . "/" . $mon . "/" . $year . "\n";
        close(ARCHIVE_OUT);
    }
    return 0;
}

sub archive_list {
	my $self = shift;
	my @list;
	my $type = shift || return 0;
	open(ARCHIVE_IN, "<logs/image_archive") if ($type eq "images");
	open(ARCHIVE_IN, "<logs/links") if ($type eq "links");
    while (<ARCHIVE_IN>) {
    	push (@list, $_);
    }
    close(ARCHIVE_IN);
    return @list;
}

sub hai_visto {
	my $self = shift;
	my $nick = shift || return 0;
	my $data = $self->get_data($nick, "log_accessi");
    return "no, non ho visto " . $nick unless $data;
    my @raw_data = split (", " , $data);
    return "l'ultima volta che ho visto " . $nick  . " è stata il " . $raw_data[1] . " sul chan " . $raw_data[0] if @raw_data;	
}

sub fortune {
	my $self = shift;
	my $out = `fortune`;
    $out =~ s/\n/ /g;
    return $out;	
}

sub modes {
	my $self = shift;
	my $name = shift || return 0;
	my $mode = shift || return 0;
	$mode = 1 if (($mode eq "on") || ($mode eq "yes"));
	$mode = 0 if (($mode eq "off") || ($mode eq "no"));
	#7337 mode
	if (($name eq "leet") || ($name eq "l33t") || ($name eq "7337")) {
    	$self->{leet} = 1 if ($mode);
    	$self->{leet} = 0 if (!$mode);
    	return "l33t mode = " . $self->{leet};
    }
    #lamer mode
    if (($name eq "lamer") || ($name eq "lamah")) {
    	$self->{lamer} = 1 if ($mode);
    	$self->{lamer} = 0 if (!$mode);
    	return "lamer mode = " . $self->{lamer};
    }
    if ($name eq "web_wtf") {
    	$self->{web_wtf} = 1 if ($mode);
    	$self->{web_wtf} = 0 if (!$mode);
    	return "web_wtf mode = " . $self->{web_wtf};
    }
    return 0;
}

#funzione che recupera il titolo di una pagina se viene mandato in chat un url
#(abbastanza utile per vedere in anticipo se vale la pena di visitarlo)
sub url {
	my $self = shift;
	my $text = $self->{event}->{args}[0];
	my @tmp;
    my $url;
    if ($text =~ /http:\/\//i) {
        if ($text =~ /^http:\/\//i) {
            $url = $text;
            @tmp = split (" ", $url);
            $url = $tmp[0];
        }
        if ($text =~ /(.*)http:\/\/(.*)/i) {
            $url = $2;
            @tmp = split (" ", $url);
            $url = "http://" . $tmp[0];
        }
        return $self->web_wtf($url) if (($url) && ($self->web_wtf($url)));
    }
    return 0;
}

sub web_wtf { #I'm too lazy!!
	my $self = shift;
    use LWP::UserAgent;
    my $page = shift;
    my $ua = LWP::UserAgent->new;
    my $response = $ua->get($page);
    my $content = $response->content;

    #metto tutto su una riga nel caso il title fosse su piu righe
    $content =~ s/\n/ /ig;
    $content =~ /<title>(.*)<\/title>/;
    if ($1) {
   		return "$page --> $1";
   	}
}


#prende i facts del mitico chuck da welovechucknorris
sub chuck {
	my $self = shift;
    use LWP::UserAgent;
    my $page = "http://welovechucknorris.blogspot.com/";
    my $ua = LWP::UserAgent->new;
    my $response = $ua->get($page);
    my $content = $response->content;
    my @lines = split("\n", $content);
    my @facts;
    foreach my $line (@lines) {
        if ($line =~ /<span style="font-weight: bold;">(.+?)<\/span> <span style="font-size:78%;">/) {
            push (@facts, $self->clean_html($1));
        }
    }
    return $self->get_element_random(@facts);
}

#news
sub news {
	my $self = shift;
    use LWP::UserAgent;
	use XML::RSS::Parser;
	my $fonte = shift;
	my $err = "Fonti disponibili: Blacklight (powered by Secunia), Slashdot, Autistici.org, Adnkronos (Ign), Repubblica, TuxFeed, ZioBudda";
	my $page;
	return $err if (!$fonte);
	$page = "http://rss.slashdot.org/Slashdot/slashdot" if ($fonte =~ /^slashdot/i);
	$page = "http://www.adnkronos.com/RSS/RSS_Ultimora.xml" if (($fonte =~ /^adnkronos/i) || ($fonte =~ /^ign/i));
	$page = "http://secunia.com/information_partner/anonymous/o.rss" if (($fonte =~ /blacklight/i) || ($fonte =~ /secunia/i));
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
	my $res = $self->clean_html($feed_title . ": " . $title . " --> " . $self->tiny_url($url));
    return $res;
}

#funzione che rimpicciolisce gli url grazie a tinyurl
sub tiny_url {
	my $self = shift;
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

#funzione roulette russa
sub roulette {
	my $self = shift;
    my $n = int(rand(5));
    my $vita;
    my @punti;
    my $msg;
    my $nick = shift;
    if ($n==1) { $vita = 0 }
    else { $vita = 1 }
    my $raw_data = $self->get_data($nick, "roulette");
    if ($raw_data) {
    	@punti = split (", ", $raw_data);
    }
    else {
    	@punti = (0, 0);
    }
   	if ($vita) {
   		$punti[0]++;
   		$msg = $nick . ": sei vivo :)";
   	}
    if (!$vita) {
    	$punti[1]++;
    	$msg = $nick . ": BANG! ... ci si vede all'inferno!";
    }
	$self->save_data($nick, "roulette", $punti[0] . ", " . $punti[1]);
	return $msg;
}

sub roulette_classifica {
	my $self = shift;
	open(ROULETTE, "<logs/roulette");
	my @righe = <ROULETTE>;
	close (ROULETTE);
	my @classifica;
	my @data;
	foreach my $riga (@righe) {
    	@data = split (", ", $riga);
    	push (@classifica, $data[0] . ": " . $data[1] . " volte in vita e " . $data[2] . " volte morto - " . (100 - int($data[2]/$data[1]*100)) . "%");
	}
	return @classifica;
}

sub roulette_classifica_nick {
	my $self = shift;
	my $nick = shift;
	my $raw_data = $self->get_data($nick, "roulette") || return 0;
	my @data = split (", ", $raw_data);
	return $nick . ": " . $data[0] . " volte in vita e " . $data[1] . " volte morto - " . (100 - int($data[1]/$data[0]*100)) . "%";	
}

#DA FARE!!!!
sub leet {
	my $self = shift;
    my $string = lc(shift);
    my $leet_char;
    #per ogni lettera sostituisco con un carattere 7337 a caso
    $leet_char = get_element_random("4", "\/\\","\@", "\/-\\");
    $string =~ s/a/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("8", "13", "I3", "|3", "|:", "!3", "(3", ")3", "]3");
    $string =~ s/b/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("[", "<", "(", "{");
    $string =~ s/c/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random(")", "|O", "])", "[)", "I>", "|>", "T)", "|)");
    $string =~ s/d/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("3", "[-");
    $string =~ s/e/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random(")", "])", "[)", "I>", "|>", "T)", "|)");
    $string =~ s/f/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/g/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("/-/", "[-]", "]-[", ")-(", "(-)", ":-:", "|~|", "|-|", "]~[", "}{", "}-{");
    $string =~ s/h/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("1", "!", "|", "]");
    $string =~ s/i/$leet_char/ if (int(rand(2)) == 1);
	$leet_char = get_element_random("_|", "_/", "</", "(/");
    $string =~ s/j/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("X", "|<", "|{");
    $string =~ s/k/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/l/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/m/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/n/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/o/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/p/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/q/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/r/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/s/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/t/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/u/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/v/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/w/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/x/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/y/$leet_char/ if (int(rand(2)) == 1);
    $leet_char = get_element_random("6", "9", "(_-", "C-");
    $string =~ s/z/$leet_char/ if (int(rand(2)) == 1);
    return $string;
}

sub lamah {
	my $self = shift;
    my $string = shift;
    my @chars = split("", $string);
    for (my $i = 0; $i < (scalar(@chars)); $i += 2) {
        $chars[$i] = uc($chars[$i]);
        $chars[$i - 1] = lc($chars[$i - 1]) unless ($i == 0);
    }
    $string = join("", @chars);
    return $string;
}


sub get_messaggi {
	my $self = shift;
	my $nick = shift;
	my $raw_data = $self->get_data($nick, "messaggi");
	if ($raw_data) {
		my @data = split (", " , $raw_data);
		$self->kill_data($nick . ", " . $raw_data . "\n", "messaggi");
		return $nick . ": " . $data[1] . " ti ha lasciato questo messaggio: '" . $data[0] . "' il " . $data[2] if (@data);
	}
}

1;
