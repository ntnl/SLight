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
use lib $Bin .'/../../lib/';

use Test::More;
use Test::FileReferenced;
use utf8;
# }}}

use SLight::Core::URL qw( parse_url make_url );

plan tests =>
    + 2 # Root
    + 4 # Path only
    + 2 # Path and Path handler
    + 2 # Action only
;

# Root
is_referenced_ok( parse_url(q{/}), 'Root - parse' );
is_referenced_ok(
    make_url(
    ),
    'Root - make'
);

# Path only
is_referenced_ok( parse_url(q{/Foo/}), 'Path only - parse' );
is_referenced_ok(
    make_url(
        path => [ 'Foo' ]
    ),
    'Path only - make'
);
is_referenced_ok( parse_url(q{/Foo/Bar/}), 'Path only x2 - parse' );
is_referenced_ok(
    make_url(
        path => [ 'Foo', 'Bar' ]
    ),
    'Path only x2 - make'
);

# Path and Path handler
is_referenced_ok( parse_url(q{/_Bar/Foo/}), 'Path with path handler - parse' );
is_referenced_ok(
    make_url(
        path_handler => 'Bar',
        path         => [ 'Foo' ]
    ),
    'Path with path handler - make'
);

# Action only
is_referenced_ok( parse_url(q{/_Bar/Foo/}), 'Path with path handler - parse' );
is_referenced_ok(
    make_url(
        path_handler => 'Bar',
        path         => [ 'Foo' ]
    ),
    'Path with path handler - make'
);

# vim: fdm=marker
