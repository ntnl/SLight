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
    my ( $self, $oid, $metadata, $form, $errors ) = @_;
    
    $self->set_class('CMS_Spec');

    $form->add_Entry(
        name    => 'caption',
        caption => TR('Caption'),
        value   => ( $self->{'options'}->{'caption'} or q{} ),
        error   => $errors->{'caption'},
    );
    $form->add_Entry(
        name    => 'class',
        caption => TR('Class'),
        value   => ( $self->{'options'}->{'caption'} or q{} ),
        error   => $errors->{'class'},
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
