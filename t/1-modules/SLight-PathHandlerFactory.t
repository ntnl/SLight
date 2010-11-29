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
use utf8;
# }}}

plan tests =>
    + 2 # most simple ->new() constructor tests
    + 2 # most simple ->make() method tests
;

require SLight::PathHandlerFactory;

my $f1_object;
ok ($f1_object = SLight::PathHandlerFactory->new(), q{->new ok});
isa_ok($f1_object, 'SLight::PathHandlerFactory', q{->new isa_ok});

my $t1_object;
ok ($t1_object = $f1_object->make( handler => 'Page' ), q{->make ok});
isa_ok($t1_object, 'SLight::PathHandler::Page', q{->make isa_ok});

# vim: fdm=marker

