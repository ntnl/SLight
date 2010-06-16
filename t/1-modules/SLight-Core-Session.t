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

use SLight::Test::Site;

use English qw( -no_match_vars );
use Test::More;
# }}}

plan tests =>
    + 2 # start
    + 1 # save
    + 2 # restore
    + 2 # session_id
    + 3 # part
    + 2 # part_reset
    + 5 # is_valid_session_id
    + 1 # session_filename
    + 2 # validate_session
;

SLight::Test::Site::prepare_empty(
    test_dir => $Bin .q{/../},
);

use SLight::Core::Session;

is (SLight::Core::Session::session_id(), undef, 'get session id uninitialized');

my $session = SLight::Core::Session::start();

ok (SLight::Core::Session::session_id(), 'session already has id in module');

my $expires = time;

like ($session->{'expires'}, qr{^\d+$}, 'start - expires OK');

$session->{'expires'} = $expires;

is_deeply(
    $session,
    {
        'vars'    => {},
        'expires' => $expires
    },
    'session started'
);

SLight::Core::Session::part('vars', { one=>1, two=>2 } );

is_deeply(
    SLight::Core::Session::save(),
    $session,
    'save'
);

# Session was stored, so this will NOT show up in results:
$session->{'foo'} = 'bar';

my $valid_session_id = SLight::Core::Session::session_id();

# In the next request, user would sent the ID with a cookie, we must simulate that.
# Session id is invalid - will trigger creation of new session
my $restored = SLight::Core::Session::restore( 'Foo bar' );

ok (SLight::Core::Session::session_id() ne $valid_session_id, 'restore - invalid ID');

# Session id is valid - session will be restored.
$restored = SLight::Core::Session::restore( $valid_session_id );

$restored->{'expires'} = $expires;

is_deeply(
    $restored,
    {
        'vars'    => { one=>1, two=>2 },
        'expires' => $expires
    },
    'restore - valid ID'
);

is (SLight::Core::Session::part('foo'),        undef, 'part');
is (SLight::Core::Session::part('foo', 'bar'), 'bar', 'part');
is (SLight::Core::Session::part('foo'),        'bar', 'part');

is (SLight::Core::Session::part_reset('foo'),  undef, 'part_reset');
is (SLight::Core::Session::part('foo'),        undef, 'part_reset ok');

is (SLight::Core::Session::is_valid_session_id('379A7C9E-B1CD-11DD-88FF-FF22071AC5A9'), 1, 'is_valid_session_id GOOD');

is (SLight::Core::Session::is_valid_session_id(''), undef, 'is_valid_session_id BAD (none)');
is (Slight::Core::Session::is_valid_session_id('dsdsasdsadsdsadsadsadsadsadasdsasadadsadsadsadsadsadsadasdasdsadasdas'), undef, 'is_valid_session_id BAD (too long)');
is (SLight::Core::Session::is_valid_session_id('dsdsasd'), undef, 'is_valid_session_id BAD (too short)');
is (SLight::Core::Session::is_valid_session_id('$%^TGBI*()N^&*H*()$#%%^'), undef, 'is_valid_session_id BAD (invalid chars)');

SLight::Core::Session::save();

ok (-f SLight::Core::Session::session_filename(), 'session_filename');

is (ref SLight::Core::Session::validate_session([]), 'HASH', "validate_session - must be a hash!");
is (ref SLight::Core::Session::validate_session({ expires=>1234}), 'HASH', "validate_session - has expired!");

# vim: fdm=marker
