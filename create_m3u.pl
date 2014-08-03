#!/usr/bin/env perl
# Creates m3u playlist file for music in the current working directory.

use warnings;
use strict;
use File::Find::Rule;

# Directory to start working in.
my $TOPDIR;

# Check for proper arguments (directory)
sub getArgs {
    # Do we have an argument?
    if (! $ARGV[0]) {
        return 0;
    }

    # Save the Argument
    $TOPDIR = $ARGV[0];
    # Does it exist and is it a directory?
    if (-e $TOPDIR && -d $TOPDIR) {
        return 1;
    }

    # I guess not.
    print "ERROR: $TOPDIR doesn't exist or isn't a directory!\n";
    return 0;
}

# Usage message.
sub usage {
    print " $0 will recursively trawl through a directory, making\n";
    print " playlist (m3u) files for every directory containing music.\n";
    print "\n";
    print "\tUsage: $0 <directory>\n";
    print "\t<directory>    The directory containing your music files.\n";
}

# Find all directories within our $TOPDIR
# ARGS String directory
# returns array of subdirs
sub findSubDirs {
    my $TOPDIR = shift;
    my @subdirs = File::Find::Rule
        ->directory()
        ->in("$TOPDIR");
    return @subdirs;
}

# Find out if there is an existing playlist file in given directory.
# ARGS String directory
sub isExistingM3U {
    my $dir = shift;
    if (File::Find::Rule
        ->file()
        ->name(qr/\.m3u$/) 
        ->maxdepth("1")
        ->in("$dir")) {
        return 1;
    }
    return 0;
}

# Find all music files and actually create the playlist file.
# ARGS string directory
sub createPlaylists {
    my $TOPDIR = shift;
    my @dirs = findSubDirs($TOPDIR);

    # let's go through each directory
    foreach my $cwd (@dirs) {

        # If there is an m3u file alread, NEXT!
        if (&isExistingM3U($cwd)) {
            next;
        }

        # Relative working directory.
        #my $rel_wd = (split /\//, $cwd)[-1];

    }
}

=start comment
use Cwd;

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

=end comment
=cut

sub main {

    if (! &getArgs()) {
        &usage();
        return 0;
    }

    # DEBUG CODE
    &createPlaylists($TOPDIR);

    return 1;
}

&main();
