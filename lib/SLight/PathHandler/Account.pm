package SLight::PathHandler::Account;
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
use base q{SLight::PathHandler};

# }}}

sub analyze_path { # {{{
    my ( $self, $path ) = @_;

    my ( $object_class, $login );

    if (not scalar @{ $path }) {
        $object_class = q{Account::List};
    }
    elsif (scalar @{ $path } == 1) {
        $object_class = q{Account::Account};

        $login = $path->[0];
    }
    elsif (scalar @{ $path } == 2) {
        # FIXME: verify, that the object class does exist!
        $object_class = q{Account::} . $path->[1];

        $login = $path->[0];
    }
    else {
        return $self->generic_error_page('NotFound');
    }

    $self->set_objects(
        {
            o => {
                class => $object_class,
                oid   => $login,
            },
        },
    );

    $self->set_object_order([qw( o )]);

    $self->set_main_object('o');

    $self->set_template( 'Default' );

    return $self->response_content(); 
} # }}}

# vim: fdm=marker
1;
