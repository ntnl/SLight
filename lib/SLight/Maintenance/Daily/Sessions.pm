package SLight::Maintenance::Daily::Sessions;
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

our $VERSION = 0.0.5;

use SLight::Core::Config;

use Cwd qw( getcwd );
use Carp::Assert::More qw( assert_defined );
use File::Slurp qw( read_dir );
use Params::Validate qw( :all );
# }}}

sub run { # {{{
    SLight::Core::Config::initialize( getcwd() );

    my $sessions_dir = SLight::Core::Config::get_option('data_root') . q{sessions/};

    my @files = read_dir($sessions_dir);

    my $deleted = 0;
    my $skipped = 0;

    foreach my $file (@files) {
        if (-M $sessions_dir . $file > 7) {
            unlink $sessions_dir . $file;

            $deleted++;
        }
        else {
            $skipped++;
        }
    }

    printf "Processed: D: %4d S: %4d   %7d Total\n", $deleted, $skipped, $deleted + $skipped;

    return;
} # }}}

# vim: fdm=marker
1;
