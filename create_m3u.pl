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
    print "$0 will recursively trawl through a directory, making\n";
    print "playlist (m3u) files for every directory containing music.\n";
    print "\n";
    print "Usage: $0 <directory>\n";
    print "\tdirectory    The directory containing your music files.\n";
}

# Find all directories within our $TOPDIR
# ARGS String directory
# returns array of subdirs
sub findSubDirs {
    my $TOPDIR = shift;
    my @subdirs = File::Find::Rule
        ->directory()
        ->in("$TOPDIR");
    if (!length(@subdirs)) {
            return 0;
    }
    return @subdirs;
}

# Find out if there is an existing playlist file in given directory.
# ARGS String directory
# returns 1 if m3u was found, 0 if it was not.
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

# Find out which music files there are in a directory.
# ARGS String directory
# Returns array of sorted music files.
sub findMusic {
    my $dir = shift;
    # find music files in current directory
    my @files = File::Find::Rule
        ->file()
        ->name(qr/\.(mp3|ogg|flac|m4a|wma)$/) 
        ->maxdepth("1")
        ->in("$dir");
    # sort the music files we found.
    my @sorted_files = sort @files;
    # If we didn't find any, return 0
    if (!length(@sorted_files)) {
            return 0;
    }
    return @sorted_files;
}

# Actually create the playlist file.
# ARGS string directory
sub createPlaylists {
    my $TOPDIR = shift;

    # find subdirs of $TOPDIR
    my @dirs = findSubDirs($TOPDIR);

    # let's go through each directory
    foreach my $cwd (@dirs) {

        # If there is an m3u file alread, NEXT!
        if (&isExistingM3U($cwd)) {
            next;
        }

        # Relative working directory.
        my $rel_wd = (split /\//, $cwd)[-1];
        
        # m3u file location with name of directory as m3u file name.
        my $m3u = $cwd . "/" . $rel_wd . ".m3u";

        # find the music files.
        my @files = &findMusic($cwd);

        # if there are music files.
        if (@files) {
            # open the m3u file for writing
            unless (open (FILE, ">", $m3u)) {
                print "ERROR: Could not open file $m3u"; 
                next;
            }

            # go through each music file
            foreach my $file (@files){
                # We only want the relative path.
                my $rel_file = (split /\//, $file)[-1];

                # print its name into the m3u file
                print FILE "$rel_file\n";
            }

            # close the m3u file
            close FILE;
            
            # success
            print "Created $m3u\n";
        }

    }
}

sub main {
    # get and test args
    if (! &getArgs()) {
        &usage();
        return 0;
    }

    # the meat and potatoes
    &createPlaylists($TOPDIR);
}

exit(&main() ? 0 : 1);
