#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;

my $host = 'militantone';
my $sock = IO::Socket::INET->new(PeerAddr => $host,
                                 PeerPort => '6600',
                                 Proto    => 'tcp'
);
my $string = '';
if ($sock) {
    print $sock "currentsong\n";
    while (<$sock>) {
        if ($_ =~ /^Artist: (.*)/) { $string .= $1 . " - "; }
        if ($_ =~ /^Title: (.*)/) { $string .= $1; }
        if (!($_ =~ /^OK MPD/)) {
            last if ($_ = /^OK/);
        }
    }
}
close ($sock) if ($sock);
if (!($string)) {
    $string = getlogin || 'fox';
}
print $string, "\n";
