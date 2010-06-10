package SLight::Core::IO;
################################################################################
# 
# SLight - Lightweight Content Manager System.
#
# Copyright (C) 2010 Bartłomiej /Natanael/ Syguła
#
# This is free software.
# It is licensed, and can be distributed under the same terms as Perl itself.
#
# More information on: http://slight-cms.org/
# 
################################################################################
use strict; use warnings; # {{{
use base 'Exporter';
our @EXPORT_OK = qw(
    find_files
    slurp_pipe
    unique_id
);

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use File::Slurp qw( read_dir );
# }}}

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
        if (-d $start_path . $file) {
            push @files_filtered, find_files($start_path . $file .q{/}, $name_mask);
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

# vim: fdm=marker
1;
