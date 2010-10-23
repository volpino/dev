use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'XKCD_viewer',
    VERSION      => '0.1',
    AUTHOR       => 'fox <fox91@anche.no>',
    PREREQ_PM    => {
        'Gtk2' => 0,
        'Gtk2::SimpleList' => 0,
        'LWP::UserAgent' => 0,
        'Gtk2::Gdk::Keysyms' => 0
    },
    EXE_FILES => [ 'script/xkcd_viewer.pl' ],
);
