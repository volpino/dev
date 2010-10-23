#!/usr/bin/perl

print q{
_________________________________________________________________________
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>|
 
    ImageShacker.pl - CLI script to upload images on ImageShack.us
    Version: 0.1 (September 2008)
    Author ~ fox (fox91 at anche dot no)
_________________________________________________________________________
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>|

}; 

use LWP::UserAgent;
use Getopt::Std;
use strict;
use warnings;

my %options=();
getopts("e:tr:h",\%options);

my $file = shift;
die usage() if ($options{h} || !($file) || !(-e $file));
if ($file) {
    my $filesize = -s $file;
    die usage() if ($filesize > 1604321.28) && !(CheckFile($file));
}

my $resize = 0;
$resize = 1 if ($options{r});
my @sizes = (
          "100x75",
          "150x112",
          "320x240",
          "640x480",
          "800x600",
          "1024x768",
          "1280x1024",
          "1600x1200",
          "resample");
if ($options{r}) {
    my $tmp = 0;   
    foreach my $size (@sizes) {
        $tmp = 1 if ($size eq $options{r});
    }
    die usage() unless ($tmp);
}
if ($options{e}) {
    die usage() if (!(CheckEmail($options{e})));
}
my $link = UploadImage(
        'file'   => $file,
        'email'  => $options{e},
        'resize' => $resize,
        'size'   => $options{r},
        'rembar' => $options{t}
);
print $link, "\n";

sub UploadImage {
    my $ua = LWP::UserAgent->new;
    my %hash = @_;
    print "\t[+] Uploading...Please Wait\n";
    my $response = $ua->post(
                'http://load.imageshack.us/',
                [
                    'fileupload' => [$hash{'file'}],
                    'email'      => $hash{'email'},
                    'optimage'   => $hash{'resize'},
                    'optsize'    => $hash{'size'}, 
                    'rembar'     => $hash{'rembar'}
                ],
                'Content_Type' => 'form-data',
                );
	if ($response->is_success) {
		my $content=  $response->content;
		if ($content =~ /(http:\/\/img\d{1,4}.imageshack.us\/img\d{1,4}\/\d{1,9}\/\w+\.jpg)/) {
            my $link = $1;
            my $thumb = $link;
            $thumb =~ /(.+).jpg/;
		    return "\t[+] Link  ~ " . $link . "\n\t[+] Thumb ~ " . $1 . ".th.jpg\n";
        }
        else {
            open(LOG, '>' . '/tmp/imageshacker.log');
            print LOG $content;
            close(LOG);
            return <<ERROR_EXT
    [-] Error while extracting link!
    The webpage has been saved in /tmp/imageshacker.log
    Please mail me at fox91 at anche dot no so I'll try to fix it
ERROR_EXT
        }
	}
	else {
		return '[-] Error while uploading! Status: ' . $response->status_line, "\n";
	}
}

sub CheckEmail {
    my $email = shift;
    return 1 if ($email =~ /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}/);
    return 0;
}
sub CheckFile {
    my $file = shift;
    return 1 if ($file =~ /[a-zA-Z0-9\._\/]+[.jpg|.jpeg|.png|.gif|.bmp|.tif|.tiff]/);
    return 0;
}
sub usage {
    return <<USAGE

    Usage: ./imageshacker.pl [OPTIONS] [FILE]
      Options:
        -e <email>     send your email address
        -t             Remove size/resolution from thumbnail
        -r <size>      resize your image
                       available sizes: 100x75     (avatar)
                                        150x112    (thumbnail)
                                        320x240    (web & emails)
                                        640x480    (boards)
                                        800x600    (15" monitor)
                                        1024x768   (17" monitor)
                                        1280x1024  (19" monitor)
                                        1600x1200  (21" monitor)
                                        resample   (optimize)
        
    Allowed only jpg,jpeg,png,gif,bmp,tif,tiff files < 1.53MB.

USAGE
}
