#!/usr/bin/perl
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
use strict; use warnings; use utf8; # {{{
use FindBin qw{ $Bin };
use lib $Bin .q{/../../lib/};

use SLight::Test::Validator;
# }}}

my @tests = (
    {
        name => 'Optional data',
        data => {
            foo => q{This is foo},
        },
        meta => {
            foo => { type=>'Text' }, # This will pass
            bar => { type=>'Text' }, # This will fail
            baz => { type=>'Text', optional=>1 }, # This will pass (is optional)
        },
    },
    {
        name   => 'Too much characters',
        data   => { foo => qq{Foo Bar Baz} },
        meta   => { foo => { type=>'Text', max_length=>3 } },
    },
    {
        name   => 'This will pass',
        data   => { foo => qq{Foo Bar Baz} },
        meta   => { foo => { type=>'Text' } },
        expect => 'undef',
    },
);

SLight::Test::Validator::run_tests(
    tests  => \@tests,
);

# vim: fdm=marker
