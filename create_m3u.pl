#!/usr/bin/env perl
# Creates m3u playlist file for music in the current working directory.

use warnings;
use strict;

use Cwd;
use File::Find::Rule;

# Current working directory.
my $cwd = cwd();

# Relative working directory.
my $rel_wd = (split /\//, $cwd)[-1];

# m3u file location with name of directory as m3u file name.
my $m3u = $cwd . "/" . $rel_wd . ".m3u";

# find music files in current directory
my @files = File::Find::Rule
    ->file()
    ->name(qr/\.(mp3|ogg|flac)$/) 
    ->maxdepth("1")
    ->in(".");

# sort the music files we found.
my @sorted_files = sort @files;

# if we have sorted file
if (@sorted_files) {
    # open the m3u file for writing
    # TODO return, don't die.
    open (FILE, ">", $m3u) || die "Could not open file $m3u"; 
    # go through each music file
    foreach my $file (@sorted_files){
        # print its name into the m3u file
        print FILE "$file\n";
    }
    # close the m3u file
    close FILE;
}
