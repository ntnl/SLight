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
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use English qw( -no_match_vars );
use Test::More;
use Test::Exception;
# }}}

plan tests =>
    + 1 # Is a working base.
;

require SLight::HandlerBase::ContentEntryForm;

my $object = SLight::HandlerBase::ContentEntryForm->new();
ok($object, 'new() works');

# vim: fdm=marker
