#!/usr/bin/perl
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

use strict;
use warnings;
use Gtk2 '-init';
use XKCD::Core;

print q {
    XKCD viewer :3
    Version ~ 0.1
    Author  ~ fox

};

#scritto per blackcode che mi ha dato l'idea chidendo
#come si chiama quel cazzo di sito coi fumetti. LOL
#
#Sep/Oct 2008

#Window and his elements
our $mainwindow = Gtk2::Window->new('toplevel');
$mainwindow->set_title("XKCD Viewer :3");
$mainwindow->set_default_size(850,650);
$mainwindow->set_border_width(10);

my $box = Gtk2::VBox->new(0,8);

$mainwindow->add($box);

my $menubar = Gtk2::MenuBar->new;
my $menufile= Gtk2::Menu->new;

my $saveas = Gtk2::ImageMenuItem->new_with_label("Save As..." );
$saveas->set_image(Gtk2::Image->new_from_stock('gtk-save-as', 'menu'));
$menufile->append($saveas);

my $quit = Gtk2::ImageMenuItem->new_with_label("Quit");
$quit->set_image(Gtk2::Image->new_from_stock('gtk-quit', 'menu'));
$menufile->append($quit);

my $file = Gtk2::MenuItem->new_with_label("File");
$file->set_submenu($menufile);
$menubar->append($file);

my $menuedit = Gtk2::Menu->new;

my $search = Gtk2::ImageMenuItem->new_with_label("Search image on XKCD");
$search->set_image(Gtk2::Image->new_from_stock('gtk-network', 'menu'));
$menuedit->append($search);

my $getlink = Gtk2::ImageMenuItem->new_with_label("Get direct link to image...");
$getlink->set_image(Gtk2::Image->new_from_stock('gtk-network', 'menu'));
$menuedit->append($getlink);

my $inslink = Gtk2::ImageMenuItem->new_with_label("Insert your own image link/id...");
$inslink->set_image(Gtk2::Image->new_from_stock('gtk-network', 'menu'));
$menuedit->append($inslink);

my $edit = Gtk2::MenuItem->new_with_label("Edit") ;
$edit->set_submenu($menuedit);
$menubar->append($edit) ;

my $menu2 = Gtk2::Menu->new;
my $about = Gtk2::ImageMenuItem->new_with_label("About");
$about->set_image(Gtk2::Image->new_from_stock('gtk-about', 'menu'));

$menu2->append($about);

my $menuabout = Gtk2::MenuItem->new_with_label("?") ;

$menuabout->set_submenu($menu2);
$menubar->append($menuabout) ;

$box->pack_start($menubar,0,1,0);

our $linklabel = Gtk2::Label->new;
$linklabel->set_selectable(1);
$linklabel->can_focus(0);
$box->pack_start($linklabel, 0,1,0);

our $image = Gtk2::Image->new;
my $imageeventbox = Gtk2::EventBox->new;
$imageeventbox->add($image);
our $tooltip = Gtk2::Tooltips->new;

my $scrwin = Gtk2::ScrolledWindow->new;
$scrwin->set_policy('automatic', 'automatic');
$scrwin->add_with_viewport($imageeventbox);

$box->pack_start($scrwin, 1,1,0);

my $button_table = Gtk2::Table->new(1,5,0);
$button_table->set_col_spacings(40);
$box->pack_start($button_table, 0,1,0);

my $first=Gtk2::Button->new("|<");
$button_table->attach_defaults($first,0,1,0,1);

my $prev=Gtk2::Button->new("Prev");
$button_table->attach_defaults($prev,1,2,0,1);

my $rnd=Gtk2::Button->new("Random");
$button_table->attach_defaults($rnd,2,3,0,1);

my $next=Gtk2::Button->new("Next");
$button_table->attach_defaults($next,3,4,0,1);

my $last=Gtk2::Button->new(">|");
$button_table->attach_defaults($last,4,5,0,1);

our $progressbar = Gtk2::ProgressBar->new;
$box->pack_start($progressbar, 0,1,0);

our $xkcd = XKCD::Core->new($progressbar, undef);
$mainwindow->set_default_icon(Gtk2::Gdk::Pixbuf->new_from_file($xkcd->GetFavicon)) if ($xkcd->GetFavicon);

#Handlers
$mainwindow->signal_connect('delete_event' => sub {Gtk2->main_quit;});
$mainwindow->signal_connect('destroy' => sub {Gtk2->main_quit;} );
$box->signal_connect('key-press-event' => \&key_bindings);
$saveas->signal_connect("activate" ,\&on_save,$mainwindow);
$search->signal_connect("activate" ,\&on_search,$mainwindow);
$quit->signal_connect("activate" ,\&delete_event,$mainwindow);
$about->signal_connect("activate" ,\&on_about,$mainwindow);
$getlink->signal_connect("activate" ,\&on_getlink,$mainwindow);
$inslink->signal_connect("activate" ,\&on_inslink,$mainwindow);
$imageeventbox->signal_connect ("button-press-event", \&on_rightclick, $mainwindow );
$prev->signal_connect("clicked" ,\&on_prev, $image);
$next->signal_connect("clicked" ,\&on_next, $image);
$rnd->signal_connect("clicked" ,\&on_rand, $image);
$last->signal_connect("clicked" ,\&on_last, $image);
$first->signal_connect("clicked" ,\&on_first, $image);

$mainwindow->show_all();
set_image();
alert_update();
Gtk2->main;

#############
#SUBROUTINES#
#############

sub key_bindings {
    use Gtk2::Gdk::Keysyms;
    my ($widget, $event) = @_;
    if (($event->keyval == $Gtk2::Gdk::Keysyms{k}) || ($event->keyval == $Gtk2::Gdk::Keysyms{Right})) {
        on_next();
        return 1;
    }
    if ($event->keyval == $Gtk2::Gdk::Keysyms{r}) {
        on_rand();
        return 1;
    }
    if (($event->keyval == $Gtk2::Gdk::Keysyms{j}) || ($event->keyval == $Gtk2::Gdk::Keysyms{Left})) {
        on_prev();
        return 1;
    }
    if ($event->keyval == $Gtk2::Gdk::Keysyms{Q}) {
        delete_event();
        return 1;
    }
    return 0;
}

sub set_image {
    if ($xkcd->SaveImage(undef, $progressbar)) {
        if ($xkcd->file) {
            $image->set_from_file($xkcd->file);
            update_win();
        }
        else {
            $image->clear;
        }
    }
    else {
        my $dialog = Gtk2::MessageDialog->new ($mainwindow,
                                               'destroy-with-parent',
                                               'error',
                                               'close',
                                               'Connection error!');
        my $label = Gtk2::Label->new ("Can't connect to XKCD.com!\nIs your Internet connection working?!");
        $dialog->get_content_area ()->add ($label);
        $dialog->signal_connect (response => sub { Gtk2->main_quit });
        $dialog->show_all;
    }
}

sub update_win {
    $linklabel->set_label("http://xkcd.com/" . $xkcd->number . "/  -   " . $xkcd->title);
    $mainwindow->set_title("XKCD Viewer :3 - " . $xkcd->title);
    $tooltip->set_tip ($image, $xkcd->description);
}

sub copy_to_clipboard {
    my $string = shift || return;
    my $clipboard = Gtk2::Clipboard->get(Gtk2::Gdk->SELECTION_PRIMARY);
    $clipboard->set_text($string);
    $clipboard = Gtk2::Clipboard->get(Gtk2::Gdk->SELECTION_CLIPBOARD);
    $clipboard->set_text($string);
}

sub alert_update {
    my ($sec, $min, $hr, $day, $month, $year, $weekday, $dayofyr, $junk_yuk) = localtime(time);
    if (($weekday == 1) || ($weekday == 3) || ($weekday == 5)) {
        my $dialog = Gtk2::MessageDialog->new ($mainwindow,
                                               'modal',
                                               'info',
                                               'close',
                                               'Update day!');
        my $label = Gtk2::Label->new ("There's a new comic available :D");
        $dialog->get_content_area ()->add ($label);
        $dialog->signal_connect (response => sub { $_[0]->destroy });
        $dialog->show_all;
        return 1;
    }
    else {
        return 0;
    }
}

###########
#CALLBACKS#
###########

sub on_save {
    my $dialog = Gtk2::FileChooserDialog->new('Save as',undef,'save',
                                              'gtk-ok', 'ok',
                                              'gtk-cancel', 'cancel');
    my $response = $dialog->run();
    if ($response eq 'ok') {
        my $save_as = $dialog->get_filename();
        open (IN, "<" . $xkcd->file);
        my @file = <IN>;
        close (IN);
        open (SAVE , ">" . $save_as);
        print SAVE @file;
        close (SAVE);
    }
    $dialog->destroy();
}

sub on_about {
    my $window = Gtk2::AboutDialog->new;
    $window->set_copyright("This software is distributed under the terms of the GPL v.3\nCopyleft 2008 /fox/");
    $window->set_program_name('XKCD Viewer');
    $window->set_version('0.1');
    $window->set_logo(Gtk2::Gdk::Pixbuf->new_from_file($xkcd->GetLogo($progressbar))) if ($xkcd->GetLogo($progressbar));
    my $about = "Written in Perl-Gtk2\n";
    $about   .= "Author ~ fox\n\n";
    $about   .= "If you find bugs or you want to insult me \nwrite at fox91[at]anche[dot]no\n";
    $about   .= "Please use my PGP key (ID: B0087658)\n\n";
    $about   .= "All xkcd.com stuff like comics,logo,etc is property of xkcd.com\n(Creative Commons License, for more\ninformations visit the website)\n";
    $about   .= "Thank you, Randall! Your works are wonderful :D\n\n";

    my @motd = ("Big brother is watching you!",
                "... there is this thing called the GPL, which we \ndisagree with ... nobody can ever improve the software.\n (Bill Gates, April 2008)",
                "Free as in freedom, not beer. (RSM)",
                "I'm a l33t h4x0r",
                "<!-- You should't be able to read this -->",
                "Your skill in reading has improved by 1 point",
                "1 + 1 = 10",
                "21 is only the half of the truth",
                "/* no comment */",
                ": (){ :|:& }; :",
                "An infinite number of monkeys typing into GNU emacs \nwould never make a good program.\n (Linus Torvalds)",
                "/(bb|[^b]{2})/",
                "2 + 2 = 5",
                "Anonymous doesn't forgive and doesn't forget",
                "There's no place like 127.0.0.1 :>",
                "Il Gaggo e' figo, tu no.", #come dimenticare il Gaggo?
                "meh.",
                "E' in un giorno di pioggia che ti ho conosciuta,\ne il vento dell'ovest rideva gentile...\n (Modena City Ramblers)",
                "Vorrei sapere a che cosa e' servito, vivere, amare,\nsoffrire, spendere tutti i tuoi giorni passati se\ncosi' presto hai dovuto partire.\n (Guccini)",
                "La revolucion no se lleva en la boca para vivir de ella,\nse lleva en el corazon para morir por ella.\n (Che Guevara)",
                "E se sei persa in qualche fredda terra straniera ti mando\nuna ninnananna per sentirti piu' vicina.\n (Modena City Ramblers)",
                "Fratello non temere, che corro al mio dovere,\ntrionfi la giustizia proletaria!.\nTrionfi la giustizia proletaria. Trionfi la giustizia proletaria.\n (Guccini)"
             );
    $about .= "\"" . $motd[int(rand(scalar(@motd)))] . "\"\n";
    $window->set_comments($about);
    $window->signal_connect (response => sub { $_[0]->destroy });
    $window->show_all;
}

sub on_rightclick {
    my ($widget, $event) = @_;
    return 0 unless $event->button == 3;
    my $menu = Gtk2::Menu->new;
    my $saveas = Gtk2::ImageMenuItem->new_with_label("Save As..." );
    $saveas->set_image(Gtk2::Image->new_from_stock('gtk-save-as', 'menu'));
    $menu->append($saveas);
    my $getlink = Gtk2::ImageMenuItem->new_with_label("Get direct link to image...");
    $getlink->set_image(Gtk2::Image->new_from_stock('gtk-network', 'menu'));
    $menu->append($getlink);
    my $copylink = Gtk2::ImageMenuItem->new_with_label("Copy link");
    $copylink->set_image(Gtk2::Image->new_from_stock('gtk-copy', 'menu'));
    $menu->append($copylink);
    my $copydirect = Gtk2::ImageMenuItem->new_with_label("Copy direct link to image");
    $copydirect->set_image(Gtk2::Image->new_from_stock('gtk-copy', 'menu'));
    $menu->append($copydirect);

    $saveas->show;
    $getlink->show;
    $inslink->show;
    $copylink->show;
    $copydirect->show;

    $menu->popup(undef, undef, undef, undef, $event->button, $event->time);
    $saveas->signal_connect("activate" ,\&on_save,$mainwindow);
    $getlink->signal_connect("activate" ,\&on_getlink,$mainwindow);
    $copylink->signal_connect(activate => sub {copy_to_clipboard("http://xkcd.com/" . $xkcd->number . "/")});
    $copydirect->signal_connect(activate => sub {copy_to_clipboard($xkcd->link)});
}

sub on_prev {
    my ($button, $image) = @_;
    $xkcd->GetPrev;
    set_image();
}
sub on_next {
    my ($button, $image) = @_;
    $xkcd->GetNext;
    set_image();
}
sub on_rand {
    my ($button, $image) = @_;
    $xkcd->GetRandom($progressbar);
    set_image();
}

sub on_last {
    my ($button, $image) = @_;
    $xkcd->SetNumber($xkcd->total);
    set_image();
}

sub on_first {
    my ($button, $image) = @_;
    $xkcd->SetNumber(1);
    set_image();
}

sub on_search {
    use Gtk2::SimpleList;
    my $window = Gtk2::Window->new('toplevel');
    $window->set_title("Search");
    $window->set_default_size(520,420);
    $window->set_border_width(15);
    my $label = Gtk2::Label->new("Search on XKCD.com\n");
    our $linkentry = Gtk2::Entry->new;
    my $okay = Gtk2::Button->new_from_stock('gtk-ok');
    my $resultslabel = Gtk2::Label->new("Search results: \n");
    our $list = Gtk2::SimpleList->new(
        'Comic name'  => 'text',
        'Link'       => 'text'
    );
    $list->set_column_editable(0, 0);
    my $scrwin = Gtk2::ScrolledWindow->new;
    $scrwin->set_policy('automatic', 'automatic');
    $scrwin->add_with_viewport($list);

    our $searchbar = Gtk2::ProgressBar->new;

    my $hbox = Gtk2::HBox->new;
    $hbox->pack_start($linkentry, 0,0,15);
    $hbox->pack_start($okay, 0,0,5);

    my $box = Gtk2::VBox->new(0,10);
    $box->pack_start($label, 0,1,0);
    $box->pack_start($hbox, 0,1,15);
    $box->pack_start($resultslabel, 0,1,0);
    $box->pack_start($scrwin, 1,1,0);
    $box->pack_start($searchbar, 0,1,0);

    $window->add($box);
    $window->show_all;
    $okay->signal_connect("clicked", sub {
        my ($button, $linkentry) = @_;
        my %results;
        %results = $xkcd->Search($linkentry->get_text, $searchbar);
        @{$list->{data}} = ();
        if (%results) {
            my @keys = keys %results;
            foreach my $key (@keys) {
                push (@{$list->{data}}, [$key, "http://xkcd.com/" . $results{$key} . "/"]);
            }
        }
        else {
            return 1;
        }
    }, $linkentry);

    $list->signal_connect (row_activated => sub {
        my $selection = ($list->get_selected_indices)[0];
        my @row = @{(@{$list->{data}})[$selection]};
        $row[1] =~ /http:\/\/xkcd.com\/(\d{1,3})\//;
        $xkcd->SetNumber($1);
        set_image();
    });
}

sub on_getlink {
    my $dialog = Gtk2::MessageDialog->new ($mainwindow,
                                           'modal',
                                           'info',
                                           'ok',
                                           'Here you are :)');
    my $link = Gtk2::Entry->new;
    $link->append_text($xkcd->link);
    $link->set_editable(0);
    $dialog->get_content_area()->add ($link);
    $dialog->signal_connect (response => sub { $_[0]->destroy });
    $dialog->show_all;
}

sub on_inslink {
    my $window = Gtk2::Window->new('toplevel');
    $window->set_title("Insert link");
    $window->set_default_size(320,140);
    $window->set_border_width(30);
    my $label = Gtk2::Label->new("Insert an XKCD image link/number\nExample: 1 or http://xkcd.com/1/\n");
    our $linkentry = Gtk2::Entry->new;
    my $okay = Gtk2::Button->new_from_stock('gtk-ok');
    my $table = Gtk2::Table->new(3,1);
    $table->attach_defaults($label, 0,1,0,1);
    $table->attach_defaults($linkentry, 0,1,1,2);
    my $vbox = Gtk2::VBox->new;
    $vbox->pack_start($okay, 0,1,7);
    $table->attach_defaults($vbox, 0,1,2,3);
    $window->add($table);
    $table->show;
    $label->show;
    $linkentry->show;
    $okay->show;
    $vbox->show;
    $window->show;
    $okay->signal_connect("clicked", sub {
        my ($button, $window) = @_;
        if ($linkentry->get_text =~ /[http:\/\/]?[xkcd.com\/]?(\d{1,3})[\/]?/i) {
            my $number = $1;
            if ($number <= $xkcd->total) {
                $xkcd->SetNumber($number) ;
            }
        }
        set_image();
        Gtk2::Widget::hide_on_delete($window);
    }, $window);
}


0;
__END__

=head1 NAME

XKCD viewer - Simple GTK front-end for xkcd.com

=head1 DESCRIPTION

Using this program you can easily enjoy xkcd comics by
Randall Munroe without any browser, simply using this
graphical front-end.

Features:

  * xkcd.com like buttons (prev, next, random, ...)
  * search function
  * get direct links easily
  * copy links to clipboard
  * save comics on your pc
  * insert your own comic id / url
  * tooltip with comic description (browser like)
  * key bindings
  * alert when there are new comics


=head1 Key Bindings

  Keys                      Action
------------------------------------------
  Right-arrow               Next comic
  k                         Next comic
  Left-arrow                Previous comic
  j                         Previous comic
  r                         Random comic
  Q                         Quit


=head1 COPYRIGHT

This program is free software and is distributed
under the terms of the GPL v.3

Copyleft 2008 fox

=head1 AUTHOR

fox <fox91[at]anche[dot]no>
If you find bugs please write me! :D

=cut
