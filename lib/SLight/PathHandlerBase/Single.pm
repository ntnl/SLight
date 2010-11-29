package SLight::PathHandlerBase::Single;
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
use base q{SLight::PathHandler};

# }}}

# This is a king of Path handler, that always returns one object.
#
# Is a path is given, it returns Not Found error!

sub analyze_path { # {{{
    my ( $self, $path ) = @_;

    if (scalar @{ $path }) {
        return $self->generic_error_page('NotFound');
    }

    my $object_class = $self->object_class();

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

