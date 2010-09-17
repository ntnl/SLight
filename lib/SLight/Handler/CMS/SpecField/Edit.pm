package SLight::Handler::CMS::SpecField::Edit;
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
use base q{SLight::HandlerBase::SimpleForm};

use SLight::API::ContentSpec qw( update_ContentSpec );
use SLight::Core::L10N qw( TR );
# }}}

sub form_spec { # {{{
    my ( $self, $oid, $metadata ) = @_;

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
            'caption' => { type=>'String' },
        },
    };
} # }}}

sub make_form { # {{{
    my ( $self, $oid, $metadata, $form ) = @_;

    my $field_data = $metadata->{'spec'}->{'_data'}->{$oid};

# Editing class not implemented (TODO)
#    $form->add_Entry(
#        name    => 'class',
#        caption => TR('Class') . q{:},
#        value   => q{},
#    );
    $form->add_Entry(
        name    => 'caption',
        caption => TR('Caption') . q{:},
        value   => ( $self->{'options'}->{'caption'} or $field_data->{'caption'} ),
    );
    $form->add_Entry(
        name    => 'order',
        caption => TR('Order') . q{:},
        value   => ( $self->{'options'}->{'order'} or $field_data->{'order'} ),
    );
    $form->add_SelectEntry(
        name    => 'datatype',
        caption => TR('Data type') . q{:},
        value   => ( $self->{'options'}->{'datatype'} or $field_data->{'datatype'} ),
        options => [
    		[ 'String', TR('String') ],
	    	[ 'Text',   TR('Text') ],

    		[ 'Email', TR('Email') ],
	    	[ 'Link',  TR('Link') ],

    		[ 'Int',   TR('Integer') ],
	    	[ 'Money', TR('Monetary value') ],

		    [ 'Date',     TR('Date') ],
		    [ 'Time',     TR('Time') ],
		    [ 'DateTime', TR('Date and time') ],

    		[ 'Image', TR('Image') ],
	    	[ 'Asset', TR('Asset') ],
        ]
    );

    $form->add_SelectEntry(
        name    => 'translate',
        caption => TR('Localization') . q{:},
        value   => ( $self->{'options'}->{'translate'} or $field_data->{'translate'} ),
        options => [
            [ '0', TR('Not translatable'), ],
            [ '1', TR('This field is translatable'), ],
        ]
    );

    $form->add_SelectEntry(
        name    => 'display_on_page',
        caption => TR('Display on page') . q{:},
        value   => ( $self->{'options'}->{'display_on_page'} or $field_data->{'options'} ),
        options => [
            [ '0', TR('Do not display'), ],
            [ '1', TR('Display as summary'), ],
            [ '2', TR('Display in full form'), ],
        ]
    );

    $form->add_SelectEntry(
        name    => 'display_on_list',
        caption => TR('Display on list') . q{:},
        value   => ( $self->{'options'}->{'display_on_list'} or $field_data->{'display_on_list'} ),
        options => [
            [ '0', TR('Do not display'), ],
            [ '1', TR('Display as summary'), ],
            [ '2', TR('Display in full form'), ],
        ]
    );

    $form->add_SelectEntry(
        name    => 'display_label',
        caption => TR('Display label') . q{:},
        value   => ( $self->{'options'}->{'display_label'} or $field_data->{'display_label'} ),
        options => [
            [ '0', TR('display on pages and on lists.'), ],
            [ '1', TR('only on lists.'), ],
            [ '2', TR('only on pages.'), ],
            [ '3', TR('do not display (only on forms)'), ],
        ]
    );

    $form->add_SelectEntry(
        name    => 'optional',
        caption => TR('Is required') . q{:},
        value   => ( $self->{'options'}->{'optional'} or $field_data->{'optional'} ),
        options => [
            [ '0', TR('Yes, it is always required'), ],
            [ '1', TR('No, it is optional'), ],
        ]
    );

    $form->add_Entry(
        name    => 'max_length',
        caption => TR('Maximum length') . q{:},
        value   => ( $self->{'options'}->{'max_length'} or $field_data->{'max_length'} ),
    );

    return;
} # }}}

sub save_form { # {{{
    my ( $self, $oid, $metadata ) = @_;

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
        step   => 'view',
        path   => [
            'Field',
            $metadata->{'spec'}->{'id'},
            $self->{'options'}->{'class'},
        ],
    );
} # }}}

# vim: fdm=marker
1;
