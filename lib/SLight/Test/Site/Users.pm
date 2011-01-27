package SLight::Test::Site::Users;
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

use SLight::API::User;
use SLight::API::Avatar qw( set_Avatar );
use SLight::Test::Site::EmailTemplates;
use File::Slurp qw( read_file );
# }}}

# This module creates a set of Users.
# It can be used as such, or as part of some bigger site.

sub build { # {{{
    # When playing with Users, you usually need email stuff too.
    SLight::Test::Site::EmailTemplates::build();

    # A / 1
    SLight::API::User::add_User(
        login  => 'aga',
        status => 'Enabled',
        name   => 'Agnieszka',
        pass   => 'Agniecha',
        email  => 'agnes@test.test',
    );

    # B / 2
    SLight::API::User::add_User(
        login  => 'beti',
        status => 'Enabled',
        name   => 'Beata',
        pass   => 'Happy',
        email  => 'beata@test.test',
    );

    # E / 3
    SLight::API::User::add_User(
        login  => 'ela',
        status => 'Enabled',
        name   => 'Elżbieta', # Polish 'ż' is used intentionally!
        pass   => 'Elka',
        email  => 'ela@test.test',
    );

    set_Avatar(3, scalar read_file(SLight::Test::Site::Builder::trunk_path() . q{/t/SampleImage.gif}));

    # N / 4
    SLight::API::User::add_User(
        login  => 'nataly',
        status => 'Guest',
        name   => 'Natalia',
        pass   => 'LoremIpsumNataly',
        email  => 'natka@test.test',
    );

    # W / 5
    SLight::API::User::add_User(
        login  => 'wanda',
        status => 'Disabled',
        name   => 'Wanda L.',
        pass   => 'Wanda',
        email  => 'wanda@test.test',
    );

    return;
} # }}}

# vim: fdm=marker
1;
