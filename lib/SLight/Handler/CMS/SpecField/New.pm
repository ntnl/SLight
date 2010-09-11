package SLight::Handler::CMS::SpecField::New;
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
    my ( $self, $form ) = @_;
    
    $form->add_Entry(
        name    => 'class',
        caption => TR('Class:'),
        value   => q{},
    );
    $form->add_Entry(
        name    => 'caption',
        caption => TR('Caption:'),
        value   => q{},
    );
    $form->add_Entry(
        name    => 'Order',
        caption => TR('Order:'),
        value   => q{},
    );
    $form->add_SelectEntry(
        name    => 'datatype',
        caption => TR('Data type:'),
        value   => q{},
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
        caption => TR('Localization:'),
        value   => q{},
        options => [
            [ '0', TR('Not translatable'), ],
            [ '1', TR('This field is translatable'), ],
        ]
    );

    $form->add_SelectEntry(
        name    => 'display_on_page',
        caption => TR('Display on page:'),
        value   => q{},
        options => [
            [ '0', TR('Do not display'), ],
            [ '1', TR('Display as summary'), ],
            [ '2', TR('Display in full form'), ],
        ]
    );

    $form->add_SelectEntry(
        name    => 'display_on_list',
        caption => TR('Display on list:'),
        value   => q{},
        options => [
            [ '0', TR('Do not display'), ],
            [ '1', TR('Display as summary'), ],
            [ '2', TR('Display in full form'), ],
        ]
    );

    $form->add_SelectEntry(
        name    => 'display_label',
        caption => TR('Display label:'),
        value   => q{},
        options => [
            [ '0', TR('display on pages and on lists.'), ],
            [ '1', TR('only on lists.'), ],
            [ '2', TR('only on pages.'), ],
            [ '3', TR('do not display (only on forms)'), ],
        ]
    );

    $form->add_SelectEntry(
        name    => 'optional',
        caption => TR('Is required:'),
        value   => q{},
        options => [
            [ '0', TR('Yes, it is always required'), ],
            [ '1', TR('No, it is optional'), ],
        ]
    );

    $form->add_Entry(
        name    => 'max_length',
        caption => TR('Maximum length:'),
        value   => q{},
    );

    return;
} # }}}

# vim: fdm=marker
1;
