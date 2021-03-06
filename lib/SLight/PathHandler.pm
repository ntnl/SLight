package SLight::PathHandler;
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

my $VERSION = '0.0.5';

use Carp::Assert::More qw( assert_listref assert_hashref assert_defined );
# }}}

# Make a new PathHandler object. Nothing fancy here.
sub new { # {{{
    my ( $class ) = @_;

    my $self = {
        page_id => undef,

        title => undef, # Optional.

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
        
        breadcrumb_path => [],
            # List of links that form the main Breadcrumb path.
    };

    bless $self, $class;

    return $self;
} # }}}

sub set_page_id { # {{{
    my ( $self, $page_id ) = @_;

    return $self->{'page_id'} = $page_id;
} # }}}

sub set_breadcrumb_path { # {{{
    my ( $self, $breadcrumb_path ) = @_;

    assert_listref($breadcrumb_path, 'Is a list');

    return $self->{'breadcrumb_path'} = $breadcrumb_path;
} # }}}

sub set_title { # {{{
    my ( $self, $title ) = @_;

    return $self->{'title'} = $title;
} # }}}

sub set_template { # {{{
    my ( $self, $template ) = @_;

    return $self->{'template'} = $template;
} # }}}

sub set_objects { # {{{
    my ( $self, $objects ) = @_;

    assert_hashref($objects, 'Objects is an hashref');

    return $self->{'objects'} = $objects;
} # }}}

sub set_main_object { # {{{
    my ( $self, $main_object ) = @_;

    assert_defined( $main_object, 'Object defined');

    return $self->{'main_object'} = $main_object;
} # }}}

sub set_object_order { # {{{
    my ( $self, $object_order ) = @_;

    assert_listref($object_order, 'Objects is an array');

    return $self->{'object_order'} = $object_order;
} # }}}

sub response_content { # {{{
    my ( $self ) = @_;

    # FIXME! Check, that Path handler returned what it should!

    my $content_response = {
        page_id => $self->{'page_id'},

        breadcrumb_path => $self->{'breadcrumb_path'},

        template => $self->{'template'},

        objects      => $self->{'objects'},
        object_order => $self->{'object_order'},
        main_object  => $self->{'main_object'},
    };

    if ($self->{'title'}) {
        $content_response->{'title'} = $self->{'title'};
    }

#    use Data::Dumper; warn Dumper $content_response;

    return $content_response;
} # }}}

# Some useful methods.

# Indicate, that path points to empty page.
sub page_is_empty { # {{{
    my ( $self ) = @_;

    $self->set_objects(
        {
            e1 => {
                class    => 'Core::Empty',
                oid      => undef,
            },
        },
    );

    $self->set_object_order([qw( e1 )]);

    $self->set_main_object('e1');

    return;
} # }}}

# Indicate, that the page specified by the path, does not exist.
# This is generally the equivalent od the E404 response.
sub page_does_not_exist { # {{{
    my ( $self ) = @_;

    return $self->generic_error_page('NotFound');
} # }}}

sub generic_error_page { # {{{
    my ( $self, $error_type ) = @_;

    $self->set_objects(
        {
            $error_type => {
                class => 'Error::' . $error_type,
                oid   => undef,
            },
        },
    );

    $self->set_object_order([ $error_type ]);

    $self->set_main_object( $error_type );

    $self->set_template( 'Error' );

    return $self->response_content(); 
} # }}}

# Virtual:
sub get_path_target { my ( $self ) = @_; return; }

# vim: fdm=marker
1;
