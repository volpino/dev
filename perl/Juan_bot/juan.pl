#!/usr/bin/perl -w
#       juan.pl
#
#       Copyright 2008 Unknown <fox@MachI>
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.
#
#
#Author: Federico aka fox
#Date: june 2008
#     _
#    | |_   _  __ _ _ __
# _  | | | | |/ _` | '_ \
#| |_| | |_| | (_| | | | |
# \___/ \__,_|\__,_|_| |_|
#
#Features:
#
#
# :D Questo bot ha preso ispirazione dal mitico svampo e da costrutto :D
# developed for blacklight's irc chan :3

#da inserire: sistema archiviazione dati decente,votazioni utenti, print info funzionamento, *archivio immagini*, traduci, *l33t e lamer mode*, roulette russa, whois, meteo, *youtube WTF?!*, completare features, *news*, *frasi aggiuntive rutta e muori*, *siti affiliati*, lastfm gruppo blacklight, *bestemmie (amen)*, *accoglienza per fox,blacklight&co*, trivial?!?, *fortune*, *risposte tipo: ciao, a dopo, ecc...*, *chuck norris*

use Juan::Main;
use Juan::Core;
use Juan::Other;
use Net::IRC;

use strict;
use warnings;

print
"Juan - IRC bot developed by fox (fox91[at]anche[dot]no)
I hope you like it :D
-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n";


my $bot = Juan::Main->new(
	name 		=> 'Juan',
	server		=> 'localhost',
	port		=> '6667',
	debug 		=> 1,
	log 		=> 1,
	lamer 		=> 0,
	leet 		=> 0,
	web_wtf 	=> 1,
	conn 		=> undef,
	event 		=> undef
);

my $irc = new Net::IRC;
my $conn = $irc->newconn(
   	Server      => $bot->{server},
   	Port        => $bot->{port},
   	Nick        => $bot->{name},
   	Ircname     => 'Juan sin Tierra',
   	Username    => 'Juan'
);
die "I can't connect" unless ($conn);

$bot->set_conn($conn);
$bot->joina('#bot');

$conn->add_handler('public', \&on_public);
$conn->add_handler('msg', \&on_msg);
$conn->add_handler('join', \&on_join);
$conn->add_handler('part', \&on_part);
$irc->start();


sub on_public {
    my ($conn, $event) = @_;
    $bot->set_event($event);
    my $text = $event->{args}[0];
	my $nick = $event->{nick};
    #check_messaggi
    #$conn->privmsg($conn->{channel}, $bot->get_messaggi($nick)) if (!($bot->get_messaggi($nick) eq "0"));
	my $output = $bot->apply_modes($bot->main);
	$conn->privmsg($conn->{channel}, $output) if (($output) && (!($output eq "0")));
}


sub on_msg {
    my ($conn, $event) = @_;
    $bot->set_event($event);
    my $text = $event->{args}[0];
	my $nick = $event->{nick};
	my $output = $bot->apply_modes($bot->main);
    $conn->privmsg($event->{nick},  $output) if (($output) && (!($output eq "0")));
}

sub on_join {
    my ($conn, $event) = @_;
    $bot->set_event($event);
    my $nick = $event->{nick};
    $conn->privmsg($conn->{channel}, $bot->apply_modes($bot->saluti_on_join($nick))) if (!($nick eq $bot->{name}));
}

sub on_part {
    my ($conn, $event) = @_;
    $bot->set_event($event);
    my $nick = $event->{nick};
    my $text = $event->{args}[0];
    $conn->privmsg($conn->{channel}, $bot->get_element_random("._. $nick e' morto ._.", "$nick R.I.P.", "bye $nick"));
	$bot->save_data($nick, "log_accessi", $conn->{channel});
}
