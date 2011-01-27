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

# Test for CoMe::Response::DiffForm
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .'/../../lib/';

use SLight::Test::Runner qw( run_tests );

use English qw( -no_match_vars );
# }}}

use SLight::DataStructure::Form::Diff;

my $response = SLight::DataStructure::Form::Diff->new(
    action => 'Bar.cgi',
    hidden => {},
    submit => 'Go',
    class  => 'test',
);

# At this point, only a smoke test.

my @tests = (
    {
        name     => "add_Entry",
        callback => sub { return $response->add_Entry(@_); },
        args     => [
            name    => "foo_entry",
            caption => "Foo entry",

            name_a  => 'Left entry',
            value_a => 'Left value',
            error_a => 'Left has error',

            name_b  => 'Right entry',
            value_b => 'Right value',
            error_b => 'Right has error',
        ],
    },
    {
        name     => "add_PasswordEntry",
        callback => sub { return (eval { $response->add_PasswordEntry(@_); } or $EVAL_ERROR) },
        args     => [],
    },
    {
        name     => "add_TextEntry",
        callback => sub { return $response->add_TextEntry(@_); },
        args     => [
            name    => "foo_entry",
            caption => "Foo entry",

            name_a  => 'Left entry',
            value_a => 'Left value',
            error_a => 'Left has error',

            name_b  => 'Right entry',
            value_b => 'Right value',
            error_b => 'Right has error',
        ],
    },
    {
        name     => "add_SelectEntry",
        callback => sub { return (eval { $response->add_SelectEntry(@_); } or $EVAL_ERROR) },
        args     => [],
    },
    {
        name     => "add_FileEntry",
        callback => sub { return (eval { $response->add_FileEntry(@_); } or $EVAL_ERROR) },
        args     => [],
    },
    {
        name     => "add_Check",
        callback => sub { return (eval { $response->add_Check(@_); } or $EVAL_ERROR) },
        args     => [],
    },
);

run_tests(
    tests => \@tests,
);

# vim: fdm=marker
