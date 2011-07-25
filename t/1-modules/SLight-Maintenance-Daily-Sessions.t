#!/usr/bin/perl
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
use FindBin qw{ $Bin };
use lib $Bin .'/../../lib/';

use SLight::Test::Site;

use English qw( -no_match_vars );
use File::Slurp qw( write_file read_dir );
use Test::More;
# }}}

plan tests =>
    + 1 # Perform typical cleanup run (one deleted, one left).
    + 1 # Check actual results
;

my $test_site = SLight::Test::Site::prepare_empty(
    test_dir => $Bin .q{/../},
);

use SLight::Maintenance::Daily::Sessions;

write_file($test_site .q{/sessions/Fresh_Session.json}, "[]");
write_file($test_site .q{/sessions/Stale_Session.json}, "[]");

utime time, time - 8 * 24 * 3600, $test_site .q{/sessions/Stale_Session.json};

is(SLight::Maintenance::Daily::Sessions::run(), undef, 'run()');

my @files = read_dir($test_site .q{/sessions/});
is_deeply(
    \@files,
    [
        q{Fresh_Session.json},
    ],
    'results'
);

# vim: fdm=marker
1;
