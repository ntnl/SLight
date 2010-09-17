package SLight::Handler::CMS::Spec::New;
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

use SLight::API::ContentSpec qw( add_ContentSpec );
use SLight::Core::L10N qw( TR );
# }}}

sub form_spec { # {{{
    my ( $self, $oid, $metadata ) = @_;

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
    
    $form->add_Entry(
        name    => 'caption',
        caption => TR('Caption'),
        value   => q{},
    );

    return;
} # }}}

sub save_form { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $content_spec_id = add_ContentSpec(
        caption       => $self->{'options'}->{'caption'},
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
