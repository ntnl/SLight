package SLight::Core::IO;
################################################################################
# 
# SLight - Lightweight Content Management System.
#
# Copyright (C) 2010-2011 Bartłomiej /Natanael/ Syguła
#
# This is free software.
# It is licensed, and can be distributed under the same terms as Perl itself.
#
# More information on: http://slight-cms.org/
# 
################################################################################
use strict; use warnings; # {{{
use base 'Exporter';

use Carp::Assert::More qw( assert_defined );
use Data::UUID;
use English qw( -no_match_vars );
use File::Slurp qw( read_dir );
use YAML::Syck qw( DumpFile );
# }}}

our $VERSION = '0.0.5';

our @EXPORT_OK = qw(
    find_files
    slurp_pipe
    unique_id
    safe_save_YAML
);

# Look for files in given path, and 'bellow' it.
# Parameters:
#   start_path : string (path to a directory) or list of them
#   name       : string (regular expression) or list of them
#   type       : string: 'files', 'dirs' or 'both' (default)
sub find_files { # {{{
    my ( $start_path, $name_mask ) = @_;
    
    # Input data validation and support for lists in parameters.
    if (ref $start_path eq 'ARRAY') {
        my @files;
        foreach my $path (@{$start_path}) {
            push @files, find_files($path, $name_mask);
        }
        return @files;
    }

    # If we are here - then the path is not an array any more.
    # We can iterate on name masks now...
    if (ref $name_mask eq 'ARRAY') {
        my @files;
        foreach my $mask (@{$name_mask}) {
            push @files, find_files($start_path, $mask);
        }
        return @files;
    }
    
    # If we are here - then both path and name mask are strings.
    # Start path should also end with '/' so it's more easy to append to it.
    $start_path =~ s{/?$}{/}s;

    my @files_filtered;

    my @files_all = read_dir($start_path);
    
    foreach my $file (@files_all) {
        if (not $name_mask or $file =~ qr{$name_mask}s) {
            push @files_filtered, $start_path . $file;
        }

        # Recure into the directory..
        my $dir_path = $start_path . $file .q{/};
        if (-d $dir_path) {
            push @files_filtered, find_files($dir_path, $name_mask);
        }
    }

    return @files_filtered;
} # }}}

# Read and return everything what comes from a program.
sub slurp_pipe { # {{{
    my ( $command ) = @_;

    my $file_h;
    my $status = open $file_h, q{-|}, $command;
    
    assert_defined($status, "Opened: " . $command);
    
    local $INPUT_RECORD_SEPARATOR = undef;

    my $contents = <$file_h>;

    close $file_h;

    return $contents;
} # }}}

my $uuid_generator;

# Return unique ID, using Data::UUID module.
sub unique_id { # {{{
    if (not $uuid_generator) {
        $uuid_generator = Data::UUID->new();
    }

	return $uuid_generator->to_string($uuid_generator->create());
} # }}}

# Safe write to YAML-based data files.
# Implements:
#   - atomic file write
#   - file locking
# Parameters:
#   path : where to write - full path
#   data : data to write
sub safe_save_YAML { # {{{
    my ( $filename, $data ) = @_;

    my $tmp_file_name = $filename ."-new-". $PID;

    # Make sure, that we are the only ones writing to that file.
    my $lockfile_handle;
    assert_defined(
        ( open $lockfile_handle, '>>', $filename .'-lock'), ## no critic qw(RequireCheckedOpen)
        "Unable to open lock file ($filename-lock)!"
    );
    flock $lockfile_handle, 2;

    # Dump data to the temporarly file.
    # If something bad happens - original file remains intact.
    assert_defined( DumpFile($tmp_file_name, $data), "Unable to write to: $tmp_file_name\n");

    my $write_ok = 0;
    if (-s $tmp_file_name > 0) {
        # This operation should be atomic, so we avoid any 'Race condition'.
        $write_ok = rename $tmp_file_name, $filename;
    }
    # At this point we can allow anyone to work on the file.
    flock $lockfile_handle, 8;
    close $lockfile_handle;

    assert_defined($write_ok, "Detected problem when saving to: '$tmp_file_name' or while swapping files!");

    return 1;
} # }}}

# vim: fdm=marker
1;
