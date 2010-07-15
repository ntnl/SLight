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

use Test::More;
use FindBin qw{ $Bin };
use lib $Bin .q{/../../lib/};

use SLight::Test::Site;
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin .q{/../},
    site     => 'Users',
);

use SLight::Core::Email;

plan tests =>
    + 3 # get_by_id
    + 5 # get_email_id
    + 1 # get_user
    + 1 # get_email_login_map
    + 1 # add_email
    # set_user_id (actual test runs get_email_id)
;

is (SLight::Core::Email::get_email_id('foo@bar.baz'),        undef, 'get_email_id on non-existing email.');
is (SLight::Core::Email::get_email_id('agnes@test.test'), 1,        'get_email_id on existing email.');

is (SLight::Core::Email::add_email('e@mail.com'),    6, 'add_email');
is (SLight::Core::Email::get_email_id('e@mail.com'), 6, 'get_email_id after add_email.');

is_deeply(
    SLight::Core::Email::get_email_login_map('agnes@test.test', 'beata@test.test', 'natka@test.test', 'c@foo-example.bar'),
    {
        'agnes@test.test' => 'aga',
        'beata@test.test' => 'beti',
        'natka@test.test' => 'nataly',
    },
    'get_email_login_map'
);

SLight::Core::Email::set_user_id('c@foo-example.bar', 3);

is(SLight::Core::Email::get_user('ela@test.test'), 'ela', 'get_user');

# get_email with auto-create...
is (SLight::Core::Email::get_email_id('auto@crea.te', 1), 7, 'get_email_id with auto-create.');
is (SLight::Core::Email::get_email_id('auto@crea.te'),    7, 'get_email_id with auto-create - check.');

is_deeply (
    [ SLight::Core::Email::get_by_id(7) ],
    [
        'auto@crea.te',
        undef
    ],
    'get_by_id with no login.'
);
is_deeply (
    [ SLight::Core::Email::get_by_id(4) ],
    [
        'natka@test.test',
        'nataly'
    ],
    'get_by_id with login.'
);
is_deeply (
    [ SLight::Core::Email::get_by_id(123) ],
    [],
    'get_by_id - nonexisting ID.'
);

# vim: fdm=marker

