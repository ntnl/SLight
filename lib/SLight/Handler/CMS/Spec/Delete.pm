package SLight::Handler::CMS::Spec::Delete;
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
use base q{SLight::Handler};

use SLight::DataStructure::Dialog::YesNo;

use SLight::API::ContentSpec qw( delete_ContentSpec );
use SLight::Core::L10N qw( TR );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $spec = $metadata->{'spec'};

    my $dialog = SLight::DataStructure::Dialog::YesNo->new(
        message => TF("Do you want to delete CMS Spec: '%s'? Please confirm.", undef, $metadata->{'spec'}->{'caption'}),

        yes_href => $self->build_url(
            action => 'Delete',
            step   => 'commit',
            path   => [
                'Spec',
                $oid,
            ],
        ),
        yes_caption => TR("Yes"),

        no_href => $self->build_url(
            action => 'Delete',
            step   => 'view',
            path   => [
                'Spec',
                $oid,
            ],
        ),
        no_caption => TR("No"),

        class => 'SLight_Delete_Dialog',
    );

    $self->push_data($dialog);

    return;
} # }}}

sub handle_commit { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $spec = $metadata->{'spec'};

    delete_ContentSpec($oid);

    $self->redirect(
        $self->build_url(
            action => 'View',
            step   => 'view',
            path   => [],
        )
    );

    return;
} # }}}

# vim: fdm=marker
1;
