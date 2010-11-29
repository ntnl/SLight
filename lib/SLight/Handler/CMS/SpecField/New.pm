package SLight::Handler::CMS::SpecField::New;
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
use base q{SLight::HandlerBase::CMS::FieldForm};

use SLight::API::ContentSpec qw( update_ContentSpec );
use SLight::Core::L10N qw( TR );

use Carp::Assert::More qw( assert_defined );
# }}}

sub form_spec { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('CMS_Spec_Field');

    return {
        title  => TR(q{New field}),
        action => $self->build_url(
            action => 'New',
            path   => [
                'Field',
                $metadata->{'spec'}->{'id'},
            ],
            step => 'save'
        ),
        submit => TR('Add'),

        validator_metadata => {
            'class'           => { type=>'ASCII' },
            'caption'         => { type=>'String' },
            'order'           => { type=>'Integer' },
            'datatype'        => { type=>'ASCII' },
            'translate'       => { type=>'Integer' },
            'display_on_page' => { type=>'Integer' },
            'display_on_list' => { type=>'Integer' },
            'display_label'   => { type=>'Integer' },
            'optional'        => { type=>'Integer' },
            'max_length'      => { type=>'Integer' },
        },
    };
} # }}}

sub save_form { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('CMS_Spec_Field');

    assert_defined($self->{'options'}->{'class'}, "Class MUST be defined");

    update_ContentSpec(
        id => $metadata->{'spec'}->{'id'},

        _data => {
            $self->{'options'}->{'class'} => {
                caption         => $self->{'options'}->{'caption'},
                order           => $self->{'options'}->{'order'},
                datatype        => $self->{'options'}->{'datatype'},
                default         => ( $self->{'options'}->{'default'} or q{} ),
                translate       => $self->{'options'}->{'translate'},
                display_on_page => $self->{'options'}->{'display_on_page'},
                display_on_list => $self->{'options'}->{'display_on_list'},
                display_label   => $self->{'options'}->{'display_label'},
                optional        => $self->{'options'}->{'optional'},
                max_length      => $self->{'options'}->{'max_length'},
            },
        }
    );

    return $self->build_url(
        action => 'View',
        path   => [
            'Field',
            $metadata->{'spec'}->{'id'},
            $self->{'options'}->{'class'},
        ],
        step   => 'view'
    );
} # }}}

# vim: fdm=marker
1;
