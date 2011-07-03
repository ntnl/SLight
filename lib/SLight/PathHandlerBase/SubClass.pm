package SLight::PathHandlerBase::SubClass;
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
use base q{SLight::PathHandler};

# }}}

# Path handler, that returns selected object from a sub-class.
#
# Path must have either no (default object is returned), or one element.

sub analyze_path { # {{{
    my ( $self, $path ) = @_;

    if (scalar @{ $path } > 2) {
        return $self->generic_error_page('NotFound');
    }

    my $object_class;

    if (scalar @{ $path }) {
        $object_class = $self->class_base() . q{::} . $path->[0];

        # FIXME: verify, that the object class does exist!
    }
    else {
        $object_class = $self->default_class();
    }

    $self->set_objects(
        {
            o => {
                class => $object_class,
                oid   => $path->[1],
            },
        },
    );

    $self->set_object_order([qw( o )]);

    $self->set_main_object('o');

    $self->set_template( $self->template_name() );

    my $bread_crumbs = $self->bread_crumbs($path->[0], $path->[1]);

    $self->set_breadcrumb_path($bread_crumbs);

    return $self->response_content(); 
} # }}}

# Virtual
sub bread_crumbs { # {{{
    return [];
} # }}}

# Default. Can be replaced in sub class.
sub template_name { return 'Default'; }

# vim: fdm=marker
1;
