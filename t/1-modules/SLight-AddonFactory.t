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

require SLight::AddonFactory;

my $f1_object;
ok ($f1_object = SLight::AddonFactory->new(), q{->new ok});
isa_ok($f1_object, 'SLight::AddonFactory', q{->new isa_ok});

my $t1_object;
ok ($t1_object = $f1_object->make( pkg => 'Core', addon => 'Path' ), q{->make ok});
isa_ok($t1_object, 'SLight::Addon::Core::Path', q{->make isa_ok});

# vim: fdm=marker
