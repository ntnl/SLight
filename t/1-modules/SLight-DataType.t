#!/usr/bin/perl

# Test for SLight::DataType
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .q{/../../lib/};

use Test::More;
use Test::Exception;
use utf8;
# }}}

use SLight::DataType;

plan tests =>
    + 1 # 'siganture' crash tests.
;

# 'siganture' crash tests.
dies_ok {
    SLight::DataType::signature( type=>'Foo' );
} "Function: 'siganture' handles bogus types corectly";

# vim: fdm=marker
