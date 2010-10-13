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

# Test for CoMe::Response::DiffForm
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .'/../../lib/';

use SLight::Test::Runner qw( run_tests );

use English qw( -no_match_vars );
# }}}

use SLight::DataStructure::Dialog::Notification;

my $response = SLight::DataStructure::Dialog::Notification->new(
    text  => 'This is an example notification'
    class => 'test',
);

# At this point, only a smoke test.

my @tests = (
    {
        name     => "add_PasswordEntry",
        callback => sub { return (eval { $response->add_PasswordEntry(@_); } or $EVAL_ERROR) },
        args     => [],
    },
);

run_tests(
    tests => \@tests,
);

# vim: fdm=marker

