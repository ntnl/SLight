package SLight::PathHandler;
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

my $VERSION = '0.0.1';

# }}}

# Make a new PathHandler object. Nothing fancy here.
sub new { # {{{
    my ( $class ) = @_;

    my $self = {
        template => undef,

        objects => {},
            # Objects, that should appear on the page.
            # Key should is used only internally, by the Request Handler.
            # Value should be a hash, similar to this one:
            #   {
            #       class => 'SLight::Handler::Core::Empty',
            #           # Class, that will handle the object.
            #
            #       oid => '123',
            #           # Object ID, that the Class has to handle.
            #
            #       metadata => {},
            #           # Optional - depends on Class.
            #           # Stuff, that PageHandler would like to pass to the Class handler.
            #           # It can be used to pass data, that PageHandled has fetched, that
            #           # would otherwise had to be fetched again by the Class itself.
            #   }
        object_order => [],
            # Order in which objects appear on the page.
        main_object => undef,
            # Key name of primary object.
            # This one is always handled first, as it can return redirection,
            # that will block processing of other (aux) object.
            #
            # Usually, this is the object directly associated to the page URL.
    };

    bless $self, $class;

    return $self;
} # }}}

sub set_template { # {{{
    my ( $self, $template ) = @_;

    return $self->{'template'} = $template;
} # }}}

sub response_content { # {{{
    my ( $self ) = @_;

    return {
        template => $self->{'template'},

        objects      => $self->{'objects'},
        object_order => $self->{'object_order'},
        main_object  => $self->{'main_object'},
    };
} # }}}

# vim: fdm=marker
1;
