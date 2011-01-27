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
use FindBin qw{ $Bin };
use lib $Bin .'/../../lib/';

use Test::More;
use Test::Exception;
use Test::FileReferenced;
use utf8;
# }}}

use SLight::Core::URL qw( parse_url make_url );

plan tests =>
    + 2 # Trash (crash tests)
    + 2 # Root
    + 4 # Path only
    + 2 # Path and Path handler
    + 2 # Action only
    + 2 # Everything
;

# Trash
dies_ok { # fixme - make that a throws_ok!
    parse_url(q{bla bla bla});
} 'Trash - parse';

dies_ok {
    make_url( foo=>'bar', 'baz' );
} 'Trash - make';

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
is_referenced_ok( parse_url(q{/Bar.web}), 'Action only - parse' );
is_referenced_ok(
    make_url(
        path_handler => 'Page',
        path         => [ ],
        action       => 'Bar',
    ),
    'Action only - make'
);

# Everything - a full blown URL
is_referenced_ok( parse_url(q{/_Foo/Bar/Baz/Aaa-bbb-pl-3.ajax}), 'Everything - parse' );
is_referenced_ok(
    make_url(
        protocol => 'ajax',

        path_handler => 'Foo',
        path         => [qw( Bar Baz )],
        action       => 'Aaa',
        step         => 'bbb',

        lang => 'pl',
        page => 3,

        add_domain => 1,

        options => {
            a => 1,
            b => 2
        },

        debug_switch => {
            test_profile  => 1,
            other_profile => 1,
        },
    ),
    'Everything - make'
);

# vim: fdm=marker
