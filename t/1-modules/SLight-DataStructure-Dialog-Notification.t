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
use lib $Bin .'/../../lib/';

use Test::More;
use Test::FileReferenced;
use English qw( -no_match_vars );
# }}}

plan tests =>
    + 1 # Create
    + 1 # get_data
;

use SLight::DataStructure::Dialog::Notification;

my $response = SLight::DataStructure::Dialog::Notification->new(
    text  => 'This is an example notification',
    class => 'test',
);

isa_ok($response, 'SLight::DataStructure::Dialog::Notification');

is_referenced_ok(
    $response->get_data(),
    'get_data() example'
);

# vim: fdm=marker
