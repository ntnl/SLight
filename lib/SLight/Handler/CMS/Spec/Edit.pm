package SLight::Handler::CMS::Spec::Edit;
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
    
    my @role_field_options = $self->make_field_options($metadata->{'spec'});
    
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

sub make_field_options { # {{{
    my ( $self, $spec ) = @_;

    my @options = (
        [ q{path},          TR('URL Part') ],
        [ q{status},        TR('Status') ],
        [ q{added_time},    TR('Added time') ],
        [ q{modified_time}, TR('Modified time') ],
    );

#    use Data::Dumper; warn Dumper $spec;

    foreach my $field (@{ $spec->{'_data_order'} }) {
        push @options, [
            $spec->{'_data'}->{$field}->{'id'},
            TF('Data field: %s', undef, $spec->{'_data'}->{$field}->{'caption'}),
        ];
    }

    return @options;
} # }}}

sub save_form { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('CMS_Spec');

    update_ContentSpec(
        id      => $oid,
        caption => $self->{'options'}->{'caption'},

        order_by     => $self->{'options'}->{'order_by'},
        use_as_title => $self->{'options'}->{'use_as_title'},
        use_in_menu  => $self->{'options'}->{'use_in_menu'},
        use_in_path  => $self->{'options'}->{'use_in_path'},
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
