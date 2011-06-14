package SLight::PathHandlerBase::Single;
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

# This is a king of Path handler, that always returns one object.
#
# Is a path is given, it returns Not Found error!

sub analyze_path { # {{{
    my ( $self, $path ) = @_;

    if (scalar @{ $path } > 1) {
        return $self->generic_error_page('NotFound');
    }

    my $object_class = $self->object_class();

    $self->set_objects(
        {
            o => {
                class => $object_class,
                oid   => $path->[0],
            },
        },
    );

    $self->set_object_order([qw( o )]);

    $self->set_main_object('o');

    $self->set_template( $self->template() );

    my $bread_crumbs = $self->bread_crumbs($path->[0]);

    $self->set_breadcrumb_path($bread_crumbs);

    return $self->response_content(); 
} # }}}

# Default:
sub template { # {{{
    return 'Default';
} # }}}

# Virtual
sub bread_crumbs { # {{{
    return [];
} # }}}

# vim: fdm=marker
1;

