#
#       Copyleft 2008 by /fox/
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License v.3 as published
#       by the Free Software Foundation;
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

package XKCD::Core;

use strict;
use warnings;
use LWP::UserAgent;
use Carp;

sub new {
    my $this = shift;
    my $classe = ref($this) || $this;
    # %hash contains XKCD current and total images number
    my $progressbar = shift;
    my %hash;
    my $self = bless \%hash, $classe;
    $self->GetTotal($progressbar);
    return $self;
}

sub GetTotal {
    my $self = shift;
    my $progressbar = shift;
    my $content = _GetData('http://xkcd.com', $progressbar) || return 0;
    $content =~ / http:\/\/xkcd.com\/(\d{1,3})\//;
    $self->{total} = $1;
    $self->{number} = $self->{total};
    return $self;
}

sub GetFavicon {
    my $self = shift;
    my $file = shift || "/tmp/xkcdicon.ico";
    return $file if ((-e $file) && (-s $file > 0));
    my $content = _GetData('http://xkcd.com/favicon.ico');
    if ($content) {
    	open (ICON, ">" . $file);
    	print ICON $content;
    	close (ICON);
    	return $file;
	}
}

sub GetLogo {
    my $self = shift;
    my $progressbar = shift;
    my $file = shift || "/tmp/xkcdlogo.png";
    return $file if ((-e $file) && (-s $file > 0));
    my $content = _GetData('http://xkcd.com/static/xkcdLogo.png', $progressbar);
    if ($content) {
    	open (ICON, ">" . $file);
    	print ICON $content;
    	close (ICON);
    	return $file;
	}
}

sub GetPrev {
    my $self = shift;
    $self->{number}-- unless ($self->{number} <= 1);
    return $self;
}

sub GetNext {
    my $self = shift;
    if (!($self->{total} == $self->{number})) {
        $self->{number}++;
    }
    return $self;
}

sub GetRandom {
    my $self = shift;
    my $progressbar = shift;
    my $content = _GetData('http://dynamic.xkcd.com/comic/random/', $progressbar);
    $content =~ / http:\/\/xkcd.com\/(\d{1,3})\//;
    $self->{number} = $1;
    return $self;
}

sub GetDirectLink {
    my $self = shift;
    my $progressbar = shift;
    return 0 if (!($self->{number}));
    my $content = _GetData("http://xkcd.com/" . $self->{number} . "/", $progressbar);
    $content =~ /(http:\/\/imgs.xkcd.com\/comics\/[A-Za-z0-9()_-]+.[png|jpg|gif]+)/;
    $self->{link} = $1;
    $content =~ /<img src="(http:\/\/imgs.xkcd.com\/comics\/[A-Za-z0-9()_-]+.[png|jpg|gif]+)" title="(.+?)" alt="(.+?)" \/>/;
    $self->{description} = $2;
    $self->{title} = $3;
    return $self;
}

sub SaveImage {
    my $self = shift;
    my $file = shift || "/tmp/xkcd" . $self->{number} if ($self->{number});
    my $progressbar = shift;
    $self->{file} = $file;
    if (($file) && (-e $file) && ($file =~ /xkcd\d{1,3}/)) {
        return $file;
    }
    $self->GetDirectLink || return 0;
    my $content = _GetData($self->{link}, $progressbar);
    open (FILE, '>' . $file);
    print FILE $content;
    close (FILE);
    return $self;
}

sub _GetData {
    my $ua = LWP::UserAgent->new;
    my $url = shift;
    my $progressbar = shift;
    my $expected_length;
    my $bytes_received = 0;
    my $fraction = 0;
    my $content = '';
    my $response = $ua->request(HTTP::Request->new(GET => $url),
    sub {
        my ( $chunk, $response ) = @_;
        if (!($response->is_success)) {
            carp $response->status_line;
            return 0;
        }
        $bytes_received += length($chunk);
        if (!($expected_length)) {
            $expected_length = $response->content_length || 0;
        }
        else {
            $fraction = $bytes_received / $expected_length;
        }
        if ($progressbar) {
            $progressbar->set_fraction($fraction);
            $progressbar->set_text(int($fraction * 100) . '%');
            Gtk2->main_iteration while Gtk2->events_pending;
        }
        $content .= $chunk;
    }
    );
    if ($progressbar) {
        $progressbar->set_fraction(0);
        $progressbar->set_text('');
    }
    return $content;
}

sub Search {
    my $self = shift;
    my $search = shift || return;
    my $progressbar = shift;
    my $num_pages = 1;

    my $content = _GetData("http://www.ohnorobot.com/index.pl?e=0;show=advanced;n=0;m=0;d=0;s=" . $search . ";p=" . $num_pages  . ";Search=Search;b=0;comic=56;t=0", $progressbar);
    my $page_regex = 'p=(\d{1,5})';
    my %results;
    my @pages;

    while ($content =~ /$page_regex/) {
        push (@pages, $1);
        $content =~ s/$page_regex/ /;
    }
    @pages = sort { $a <=> $b } @pages;
    $num_pages = pop @pages;
    my $fraction = 0;
    for (my $i = 1; $i<=$num_pages; $i++) {
        %results = (%results, _GetResults($search, $i));
        if ($progressbar) {
            $fraction = $i / $num_pages;
            $progressbar->set_fraction($fraction);
            $progressbar->set_text(int($fraction * 100) . '%');
            Gtk2->main_iteration while Gtk2->events_pending;
        }
    }

    if ($progressbar) {
        $progressbar->set_fraction(0);
        $progressbar->set_text('');
    }
    return %results;
}
sub _GetResults {
    my $search = shift || return;
    my $current_page = shift || 1;
    my $content = _GetData("http://www.ohnorobot.com/index.pl?e=0;show=advanced;n=0;m=0;d=0;s=" . $search . ";p=" . $current_page  . ";Search=Search;b=0;comic=56;t=0");
    my $search_regex = '<p><a class="searchlink" href="http:\/\/xkcd.com\/(\d{1,3})\/">(.+?)<\/a><\/p>';
    my %results;

    while ($content =~ /$search_regex/) {
        $results{_clean_html($2)} = $1;
        $content =~ s/$search_regex/ /;
    }
    return %results;
}

sub _clean_html {
    my $string = shift;
    $string =~ s/<b>//g;
    $string =~ s/<\/b>//g;
    $string =~ s/\&#39;/'/g;
    $string =~ s/^\s//;
    return $string;
}

sub file {
    my $self = shift;
    return $self->{file};
}
sub number {
    my $self = shift;
    return $self->{number};
}
sub total {
    my $self = shift;
    return $self->{total};
}
sub link {
    my $self = shift;
    $self->GetDirectLink;
    return $self->{link};
}
sub description {
    my $self = shift;
    $self->GetDirectLink;
    return $self->{description};
}
sub title {
    my $self = shift;
    $self->GetDirectLink;
    return $self->{title};
}

sub SetNumber {
    my $self = shift;
    if (@_) {
        my $new_num = shift;
        $self->{number} = $new_num if (($new_num =~ /\d{1,3}/) && ($new_num <= $self->{total}));
    }
    return $self;
}

1;

__END__


=head1 NAME

XKCD::Core - XKCD viewer's Core package.

=head1 SYNOPSIS

#Create the object.
   $xkcd->new($progressbar)

#Commands to move through comics.
   $xkcd->GetPrev
   $xkcd->GetNext
   $xkcd->Random($progressbar)

#Set your own comic Id.
   $xkcd->SetNumber($n)

#Search comic.
   %results = $xkcd->Search($string, $progressbar)

#Save image:
   $xkcd->SaveImage;

#Update methods:
   $xkcd->GetTotal #update total number of comics
   $xkcd->GetDirectLink #update direct link to current image

#Misc:
   $link = $xkcd->link #direct link
   $file = $xkcd->file #image file
   $number = $xkcd->number #current comic Id
   $description = $xkcd->description #current comic description
   $total = $xkcd->total #total number of comics on xkcd
   $file = $xkcd->GetLogo #get xkcd logo
   $file = $xkcd->GetFavicon #get xkcd favicon

NOTE: $progressbar must be a Gtk::ProgressBar object

=head1 DESCRIPTION

Using this module you can obtain informations from
http://xkcd.com.
You can get comic's:
  * images
  * direct link to image
  * descripton
  * title
  * id number

It supports a Gtk2::ProgressBar object while getting
data from the website

This module is part of XKCD viewer and is structured to
work with it.
In spite of it you can develop your own based on my package
without any problem. (see SYNOPSYS)

=head1 COPYRIGHT

This program is free software and is distributed
under the terms of the GPL v.3

Copyleft 2008 fox

=head1 AUTHOR

fox <fox91[at]anche[dot]no>
If you find bugs please write me! :D

=cut

