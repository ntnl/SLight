package SLight::HandlerUtils::UserLogin;
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

use SLight::Core::Session;

use Carp::Assert::More qw( assert_defined );
# }}}

# Purpose:
#   Log-in the given user.
sub login { # {{{
    my ( $id, $login ) = @_;

    assert_defined($id);
    assert_defined($login);

    my %user_hash = (
        login => $login,
        id    => $id,
    );
    SLight::Core::Session::part_set(
        'user',
        \%user_hash
    );

    return;
} # }}}

# vim: fdm=marker
1;
