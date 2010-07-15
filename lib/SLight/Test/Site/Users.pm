package SLight::Test::Site::Users;
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

use SLight::API::User;
# }}}

# This module creates a set of Users.
# It can be used as such, or as part of some bigger site.

sub build { # {{{
    # A
    SLight::API::User::add_user(
        login  => 'aga',
        status => 'Enabled',
        name   => 'Agnieszka',
        pass   => 'Agniecha',
        email  => 'agnes@test.test',
    );

    # B
    SLight::API::User::add_user(
        login  => 'beti',
        status => 'Enabled',
        name   => 'Beata',
        pass   => 'Happy',
        email  => 'beata@test.test',
    );

    # E
    SLight::API::User::add_user(
        login  => 'ela',
        status => 'Enabled',
        name   => 'Elżbieta', # Polish 'ż' is used intentionally!
        pass   => 'Elka',
        email  => 'ela@test.test',
    );

    # N
    SLight::API::User::add_user(
        login  => 'nataly',
        status => 'Guest',
        name   => 'Natalia',
        pass   => 'LoremIpsumNataly',
        email  => 'natka@test.test',
    );

    # W
    SLight::API::User::add_user(
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
