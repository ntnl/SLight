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

use SLight::Test::Site;

use Test::More;
use Test::Exception;
use utf8;
# }}}

use SLight::Core::Cache qw(
    Cache_begin_L1
    Cache_end_L1

    Cache_get
    Cache_get_L1

    Cache_put
    Cache_put_L1

    Cache_invalidate
    Cache_invalidate_referenced
);

plan tests =>
    + 2 # cold cache tests
    + 3 # hot cache tests - L1 off
    + 7 # hot cache tests - L1 on
    + 10 # references/invalidation by reference
;

#my $site_root = SLight::Test::Site::prepare_fake(
#    test_dir => $Bin . q{/../},
#    site     => 'Minimal'
#);
my $site_root = SLight::Test::Site::prepare_empty(
    test_dir => $Bin .q{/../},
);

# Cold cache tests
is(
    Cache_get('Test', 'Foo'),
    undef,
    'Cache_get on cold cache (L1 off)'
);
is(
    Cache_get_L1('Test', 'Foo'),
    undef,
    'Cache_get_L1 on cold cache (L1 off)'
);


# Hot cache tests with L1 off.
is_deeply(
    Cache_put('Test', 'Foo', { one => 1, two => 'II', three => [1, 1, 1] }),
    { one => 1, two => 'II', three => [1, 1, 1] },
    'Cache_put on cold cache (L1 off)'
);
is_deeply(
    Cache_get('Test', 'Foo'),
    { one => 1, two => 'II', three => [1, 1, 1] },
    'Cache_get on hot cache (L1 off)'
);
is(
    Cache_get_L1('Test', 'Foo'),
    undef,
    'Cache_get_L1 on hot cache (L1 off)'
);

# Hot cache tests with L1 on
is(Cache_begin_L1(), 1, 'Enabling L1 cache');
is_deeply(
    Cache_put('Test', 'Bar', [ 'one', 2, [1, 1, 1] ]),
    [ 'one', 2, [1, 1, 1] ],
    'Cache_put on cold cache (l1 on)'
);
is_deeply(
    Cache_get('Test', 'Bar'),
    [ 'one', 2, [1, 1, 1] ],
    'Cache_get on hot cache (L1 on)'
);
is_deeply(
    Cache_get_L1('Test', 'Bar'),
    [ 'one', 2, [1, 1, 1] ],
    'Cache_get_L1 on hot cache (L1 on)'
);
is(Cache_end_L1(), 0, 'Disabling L1 cache');
is_deeply(
    Cache_get('Test', 'Bar'),
    [ 'one', 2, [1, 1, 1] ],
    'Cache_get on hot cache (L1 on-off)'
);
is(
    Cache_get_L1('Test', 'Bar'),
    undef,
    'Cache_get_L1 on hot cache (L1 on-off)'
);

# references/invalidation by reference

# Put something into cache first...
is_deeply(
    Cache_put('ReferenceTest', 'data_1', { 1 => 'One', 2 => 'Two', 3 => 'Three' }, [1, 2, 3]),
    { 1 => 'One', 2 => 'Two', 3 => 'Three' },
    'Put with references (1/3)'
);
is_deeply(
    Cache_put('ReferenceTest', 'data_2', { 2 => 'Two', 3 => 'Three', 4=>'Four' }, [2, 3, 4]),
    { 2 => 'Two', 3 => 'Three', 4=>'Four' },
    'Put with references (2/3)'
);
is_deeply(
    Cache_put('ReferenceTest', 'data_3', { 1 => 'One', 4 => 'Four' }, [1, 4]),
    { 1 => 'One', 4 => 'Four' },
    'Put with references (3/3)'
);

# Make sure, it IS there:
is_deeply(
    Cache_get('ReferenceTest', 'data_1'),
    { 1 => 'One', 2 => 'Two', 3 => 'Three' },
    'Get referenced data (1/3)'
);
is_deeply(
    Cache_get('ReferenceTest', 'data_2'),
    { 2 => 'Two', 3 => 'Three', 4=>'Four' },
    'Get referenced data (2/3)'
);
is_deeply(
    Cache_get('ReferenceTest', 'data_3'),
    { 1 => 'One', 4 => 'Four' },
    'Get referenced data (3/3)'
);

# Remove something, that refers given object:
is (
    Cache_invalidate_referenced('ReferenceTest', [ 4 ]),
    2,
    'Invalidate referenced items (two of three)'
);

is_deeply(
    Cache_get('ReferenceTest', 'data_1'),
    { 1 => 'One', 2 => 'Two', 3 => 'Three' },
    'Check referenced data - first still exists'
);
is_deeply(
    Cache_get('ReferenceTest', 'data_2'),
    undef,
    'Check referenced data - second is invalid'
);
is(
    Cache_get('ReferenceTest', 'data_3'),
    undef,
    'Check referenced data - third is invalid'
);

# vim: fdm=marker
