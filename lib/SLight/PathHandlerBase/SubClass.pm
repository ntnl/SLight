package SLight::PathHandlerBase::SubClass;
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

# Path handler, that returns selected object from a sub-class.
#
# Path must have either no (default object is returned), or one element.

sub analyze_path { # {{{
    my ( $self, $path ) = @_;

    if (scalar @{ $path } > 1) {
        return $self->generic_error_page('NotFound');
    }

    my $object_class;

    if (not scalar @{ $path }) {
        $object_class = $self->default_class();
    }
    else {
        $object_class = $self->class_base() . q{::} . $path->[0];

        # FIXME: verify, that the object class does exist!
    }

    $self->set_objects(
        {
            o => {
                class => $object_class,
                oid   => undef,
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
