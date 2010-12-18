#!/usr/bin/perl
################################################################################
# 
# SLight - Lightweight Content Management System.
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
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use Test::More;
use Test::Exception;
use utf8;
# }}}

use SLight::Test::Handler qw( run_handler_tests );

my @tests = (
    {
        # Just a test for test - probably should be moved to separate file! (FIXME)
        'name'     => 'callback test',
        'callback' => sub { return 'OK'; },
        'expect'   => 'scalar',
    }
);

run_handler_tests(
    tests => \@tests,
    
    strip_dates => 1,
);

# vim: fdm=marker
