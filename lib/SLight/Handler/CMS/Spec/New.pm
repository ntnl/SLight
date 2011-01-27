package SLight::Handler::CMS::Spec::New;
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
use base q{SLight::HandlerBase::SimpleForm};

use SLight::API::ContentSpec qw( add_ContentSpec );
use SLight::Core::L10N qw( TR );
# }}}

sub form_spec { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('CMS_Spec');

    return {
        title  => TR(q{New content Spec}),
        action => $self->build_url(
            action => 'New',
            path   => [
                'Spec'
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
    
    $self->set_class('CMS_Spec');

    $form->add_Entry(
        name    => 'caption',
        caption => TR('Caption'),
        value   => ( $self->{'options'}->{'caption'} or q{} ),
    );
    $form->add_Entry(
        name    => 'class',
        caption => TR('Class'),
        value   => ( $self->{'options'}->{'caption'} or q{} ),
    );

    my @role_field_options = (
        [ q{path},          TR('URL Part') ],
        [ q{status},        TR('Status') ],
        [ q{added_time},    TR('Added time') ],
        [ q{modified_time}, TR('Modified time') ],
    );

    $form->add_SelectEntry(
        name    => 'order_by',
        caption => TR('Order field'),
        value   => ( $self->{'options'}->{'order_by'} or q{} ),
        options => \@role_field_options,
    );
    $form->add_SelectEntry(
        name    => 'use_as_title',
        caption => TR('Title field'),
        value   => ( $self->{'options'}->{'use_as_title'} or q{} ),
        options => \@role_field_options,
    );
    $form->add_SelectEntry(
        name    => 'use_in_menu',
        caption => TR('Menu field'),
        value   => ( $self->{'options'}->{'use_in_menu'} or q{} ),
        options => \@role_field_options,
    );
    $form->add_SelectEntry(
        name    => 'use_in_path',
        caption => TR('Path field'),
        value   => ( $self->{'options'}->{'use_in_path'} or q{} ),
        options => \@role_field_options,
    );

    return;
} # }}}

sub save_form { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('CMS_Spec');

    # FIXME! Add user input validation!

    my $content_spec_id = add_ContentSpec(
        caption       => $self->{'options'}->{'caption'},
        class         => $self->{'options'}->{'class'},
        owning_module => q{CMS::Entry},

        order_by     => $self->{'options'}->{'order_by'},
        use_as_title => $self->{'options'}->{'use_as_title'},
        use_in_menu  => $self->{'options'}->{'use_in_menu'},
        use_in_path  => $self->{'options'}->{'use_in_path'},

        cms_usage => 3, # FIXME: should not be hard-coded.
    );

    return $self->build_url(
        action => 'View',
        path   => [
            'Spec',
            $content_spec_id,
        ],
        step   => 'view'
    );
} # }}}

# vim: fdm=marker
1;
