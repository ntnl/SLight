package SLight::Handler::CMS::SpecField::Delete;
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
use base q{SLight::Handler};

use SLight::DataStructure::Dialog::YesNo;

use SLight::API::ContentSpec qw( update_ContentSpec );
use SLight::Core::L10N qw( TR TF );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('CMS_Spec_Field');

    my $spec = $metadata->{'spec'};
    
    my $field_data = $spec->{'_data'}->{$oid};

    my $dialog = SLight::DataStructure::Dialog::YesNo->new(
        message => TF("Do you want to delete CMS Spec Field: '%s'? Please confirm.", undef, $field_data->{'caption'}),

        yes_href => $self->build_url(
            action => 'Delete',
            step   => 'commit',
            path   => [
                'Field',
                $metadata->{'spec'}->{'id'},
                $oid,
            ],
        ),
        yes_caption => TR("Yes"),

        no_href => $self->build_url(
            action => 'Delete',
            step   => 'view',
            path   => [
                'Field',
                $metadata->{'spec'}->{'id'},
                $oid,
            ],
        ),
        no_caption => TR("No"),

        class => 'SL_Delete_Dialog',
    );

    $self->push_data($dialog);

    return;
} # }}}

sub handle_commit { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('CMS_Spec_Field');

    my $spec = $metadata->{'spec'};

    update_ContentSpec(
        id => $spec->{'id'},

        _data => {
            $oid => undef,
        }
    );

    $self->redirect(
        $self->build_url(
            action => 'View',
            step   => 'view',
            path   => [
                'Spec',
                $metadata->{'spec'}->{'id'},
            ],
        )
    );

    return;
} # }}}

# vim: fdm=marker
1;
