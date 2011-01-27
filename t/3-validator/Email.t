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
use strict; use warnings; use utf8; # {{{
use FindBin qw{ $Bin };
use lib $Bin .'/../../lib/';

use SLight::Test::Validator;
# }}}

my @tests = (
    {
        name   => 'Simple email. OK',
        data   => { email => 'foo@bar.baz' },
        meta   => { email => { type=>'Email' } },
        expect => 'undef',
    },
    {
        name   => 'User with dots. OK',
        data   => { email => 'foo.goo@bar.baz' },
        meta   => { email => { type=>'Email' } },
        expect => 'undef',
    },
    {
        name   => 'Minus and underscore in user and domain. OK',
        data   => { email => 'f_o-o@bar-bar.foo_foo.baz' },
        meta   => { email => { type=>'Email' } },
        expect => 'undef',
    },

    {
        name   => 'String. FAIL',
        data   => { foo => 'foo bar baz' },
        meta   => { foo => { type=>'Email' } },
    },
    {
        name   => 'Bad username. FAIL',
        data   => { foo => 'f o o@bar.baz' },
        meta   => { foo => { type=>'Email' } },
    },
    {
        name   => 'Bad domain. FAIL',
        data   => { foo => 'foo@bar baz' },
        meta   => { foo => { type=>'Email' } },
    },
);

SLight::Test::Validator::run_tests(
    tests  => \@tests,
);

# vim: fdm=marker
