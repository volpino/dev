#!/usr/bin/perl

# Superscript di Gaggo per uppare immagini su tinypic.com
# Rimembra, il Gaggo è figo. Tu no.
#use Tk;
use Gtk2 '-init';
use LWP;
use HTTP::Cookies;

`scrot /tmp/screen_.jpg`;
$file="/tmp/screen_.jpg";

my $browser = LWP::UserAgent->new();
$browser->cookie_jar(new HTTP::Cookies);

my $response = $browser->get('http://it.tinypic.com/');
my $content;
if ($response->is_success) {
	$content = $response->content;  # or whatever
}
else {
	die $response->status_line;
}

$content =~ m{name="UPLOAD_IDENTIFIER".+?value="(\w+?)"}ms;
my $upload_identifier = $1;
$content =~ m{name="upk".+?value="(\w+?)"}ms;
my $upk = $1;

my $resp=0;
$resp = $browser->post(
    "http://s4.tinypic.com/upload.php",
    [
        UPLOAD_IDENTIFIER => $upload_identifier,
        upk => $upk,
        domain_lang => 'it',
        action => 'upload',
        MAX_FILE_SIZE => '200000000',
        the_file => [$file ,$file, "Content-Type" => "image/gif"],
	description => 'test',
	file_type => 'image',
	dimension => '1600'
    ],
    'Content_Type' => 'multipart/form-data'
);

my $risultato = $resp->content;
$risultato =~ m{<strong><a href="(.+?)" target="_blank">};
my $sito = $1;

$response = $browser->get($sito);
if ($response->is_success) {
	$content = $response->content;  # or whatever
}
else {
	die $response->status_line;
}

$content =~ m{"direct-url" value="(.+?)" size="39"};
$link = $1;

#GUI
my $mainwindow = Gtk2::Window->new('toplevel');                                                                                                            
$mainwindow->set_title("Screenshot :)");
$mainwindow->set_default_size(80,40);
$mainwindow->set_border_width(5);
my $box = Gtk2::HBox->new(0,8);
$mainwindow->add($box);

my $linkentry = Gtk2::Entry->new;
$linkentry->set_text($link);
my $copy_btn = Gtk2::Button->new_from_stock('gtk-copy');

$box->pack_start($linkentry, 0,0,15);                                                                                                                  
$box->pack_start($copy_btn, 0,0,5);

$mainwindow->signal_connect('delete_event' => sub {Gtk2->main_quit;});
$mainwindow->signal_connect('destroy' => sub {Gtk2->main_quit;} );
$copy_btn->signal_connect("clicked" ,\&copy_to_clipboard, $linkentry->get_text());
$mainwindow->show_all();
Gtk2->main;

sub copy_to_clipboard {
    my $button = shift;
    my $string = shift || return;
    print $string;
    my $clipboard = Gtk2::Clipboard->get(Gtk2::Gdk->SELECTION_PRIMARY); 
    $clipboard->set_text($string); 
    $clipboard = Gtk2::Clipboard->get(Gtk2::Gdk->SELECTION_CLIPBOARD); 
    $clipboard->set_text($string); 
}

sub key_bindings {
    use Gtk2::Gdk::Keysyms;
    my ($widget, $event) = @_;
    if ($event->keyval == $Gtk2::Gdk::Keysyms{q}) {
        Gtk2->main_quit();
    }
}

#my $mw = MainWindow->new(-background => "black");
#$mw->title("Screenshot :)");
#$mw->minsize (300,300);

#$mw->bind('<Control-c>' => \&exit);
#$mw->Entry(-textvariable => \$link,
#           -background => "black",
#           -foreground => "white",
#           )->pack(-anchor => "n");
unlink ("screen_.jpg");
#MainLoop;
