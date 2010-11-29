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
use Test::Output;
# }}}

plan tests =>
    + 1 # Dmp
    + 1 # mDmp
;

use SLight::Dbg;

#        Dmp( { foo => 'Foo', bar => undef } );

stderr_like(
    sub {
        Dmp( { foo => 'Foo', bar => undef } );
    },
    qr{\@main}sm,
    'Basic Dmp test'
);

#        mDmp( 'Test hash', { foo => 'Foo', bar => undef } );

stderr_like(
    sub {
        mDmp( 'Test hash', { foo => 'Foo', bar => undef } );
    },
    qr{Test hash.+?\@main}sm,
    'Basic Dmp test'
);

# vim: fdm=marker
