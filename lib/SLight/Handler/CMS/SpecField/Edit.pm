package SLight::Handler::CMS::SpecField::Edit;
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
use base q{SLight::HandlerBase::CMS::FieldForm};

use SLight::API::ContentSpec qw( update_ContentSpec );
use SLight::Core::L10N qw( TR );

use Carp::Assert::More qw( assert_defined );
# }}}

sub form_spec { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('CMS_Spec_Field');

    my $spec = $metadata->{'spec'};

    return {
        title  => TR(q{Edit field}),
        action => $self->build_url(
            action => 'Edit',
            path   => [
                'Field',
                $spec->{'id'},
                $oid,
            ],
            step => 'save'
        ),
        submit => TR('Change'),

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

    my %data = (
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
    );

    if ($self->{'options'}->{'class'} ne $oid) {
        # FIXME! This will work only, if there are no Content Entries for this Spec!!!
        $data{$oid} = undef;
    }

    update_ContentSpec(
        id => $metadata->{'spec'}->{'id'},

        _data => \%data,
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
