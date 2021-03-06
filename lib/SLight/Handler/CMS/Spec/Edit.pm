package SLight::Handler::CMS::Spec::Edit;
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

use SLight::API::ContentSpec qw( update_ContentSpec );
use SLight::Core::L10N qw( TR TF );
# }}}

sub form_spec { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('CMS_Spec');

    return {
        title  => TR(q{Edit content Spec}),
        action => $self->build_url(
            action => 'Edit',
            path   => [
                'Spec',
                $oid,
            ],
            step => 'save',
        ),
        submit => TR('Update'),

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
        value   => ( $self->{'options'}->{'caption'} or $metadata->{'spec'}->{'caption'} ),
    );
    $form->add_Entry(
        name    => 'class',
        caption => TR('Class'),
        value   => ( $self->{'options'}->{'class'} or $metadata->{'spec'}->{'class'} ),
    );
    
    return;
} # }}}

sub save_form { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('CMS_Spec');

    update_ContentSpec(
        id      => $oid,
        caption => $self->{'options'}->{'caption'},
    );

    return $self->build_url(
        action => 'View',
        path   => [
            'Spec',
            $oid,
        ],
        step   => 'view'
    );
} # }}}

# vim: fdm=marker
1;
