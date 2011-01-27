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

use Test::More;
use utf8;
# }}}

plan tests =>
    + 2 # most simple ->new() constructor tests
    + 2 # most simple ->make() method tests
;

require SLight::HandlerFactory;

my $f1_object;
ok ($f1_object = SLight::HandlerFactory->new(), q{->new ok});
isa_ok($f1_object, 'SLight::HandlerFactory', q{->new isa_ok});

my $t1_object;
ok ($t1_object = $f1_object->make( pkg => 'Core', handler => 'Empty', action => 'View' ), q{->make ok});
isa_ok($t1_object, 'SLight::Handler::Core::Empty::View', q{->make isa_ok});

# vim: fdm=marker

