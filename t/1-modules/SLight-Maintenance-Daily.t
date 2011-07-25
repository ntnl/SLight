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
    + 1 # Run main sub
;

my $test_site = SLight::Test::Site::prepare_empty(
    test_dir => $Bin .q{/../},
);

use SLight::Maintenance::Daily;

my $handler = SLight::Maintenance::Daily->new();

is(SLight::Maintenance::Daily->main(), 0, 'main()');

# vim: fdm=marker
1;
