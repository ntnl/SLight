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
use FindBin qw{ $Bin };
use lib $Bin . q{/../../lib/};

use Test::More;
use utf8;
# }}}

plan tests =>
    + 2 # most simple ->new() constructor tests
    + 2 # most simple ->make() method tests
;

require SLight::OutputFactory;

my $f1_object;
ok ($f1_object = SLight::OutputFactory->new(), q{->new ok});
isa_ok($f1_object, 'SLight::OutputFactory', q{->new isa_ok});

my $t1_object;
ok ($t1_object = $f1_object->make(output=>'TEST'), q{->make ok});
isa_ok($t1_object, 'SLight::Output::TEST', q{->make isa_ok});

# vim: fdm=marker
