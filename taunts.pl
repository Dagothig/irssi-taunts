#!/usr/bin/irssi
#
# Age of Empires-style taunt messages support.

use strict;
use vars qw($VERSION %IRSSI);
$VERSION = '0.00';
%IRSSI = (
    authors => 'dagothig',
    name => 'taunts',
    description => 'Age of Empires-style taunt messages support.',
    license => 'Public Domain'
);

use Irssi;

my @dir_files = ();
my $dir_path = -1;

sub check_taunts_list {
    my $new_dir_path = Irssi::settings_get_str("taunts_dir");
    if ($new_dir_path eq $dir_path) {
        return @dir_files;
    }

    $dir_path = $new_dir_path;
    if (opendir(my $dir, $dir_path)) {
        @dir_files = readdir($dir);
        closedir($dir);
    } else {
        print('Cannot load taunts from directory "' . $dir_path . '"');
        @dir_files = qw();
    }
    return @dir_files;
}

sub taunt {
    my ($server, $text) = @_;
    my $taunt = find_taunt($text);
    system('(play ' . '"' . $taunt . '" > /dev/null 2>&1) &') if defined($taunt);
}

sub find_taunt {
    my ($text) = @_;
    if ($text =~ /[1-9][0-9]*/) {
        my $pattern = '^0?' . $text . ' .*$';
        my @taunts = check_taunts_list();
        my @results = grep(/$pattern/, @taunts);
        foreach (@results) {
            return $dir_path . $_;
        }
    }
    return undef;
}

Irssi::signal_add_last("message public", "taunt");
Irssi::signal_add_last("message private", "taunt");
Irssi::signal_add_last("message own_public", "taunt");
Irssi::signal_add_last("message own_private", "taunt");
Irssi::settings_add_str("misc", "taunts_dir", "./");
