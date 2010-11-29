package SLight::Handler::Core::Asset::Delete;
################################################################################
# 
# SLight - Lightweight Content Management System.
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
use base q{SLight::HandlerBase::CMS};

use SLight::Core::L10N qw( TR TF );
use SLight::API::Asset qw( get_Asset delete_Asset );
use SLight::DataStructure::Dialog::YesNo;

use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $asset = get_Asset($oid);

    $self->set_class('Asset');

    my $dialog = SLight::DataStructure::Dialog::YesNo->new(
        message => TF("Do you want to delete asset '%s'? Please confirm.", undef, ($asset->{'summary'} or $asset->{'filename'})), # FIXME: use title field instead!

        yes_href => $self->build_url(
            action => 'Delete',
            step   => 'commit',
        ),
        yes_caption => TR("Yes"),

        no_href => $self->build_url(
            action => 'Delete',
            step   => 'view',
        ),
        no_caption => TR("No"),

        class => 'SLight_Delete_Dialog',
    );

    $self->push_data($dialog);

    $self->manage_toolbox($oid);

    return;
} # }}}

sub handle_commit { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('Asset');

    SLight::API::Asset::delete_Asset($oid);

    # FIXME: This has to be fixed, so that the User is redirected to parent page, not to root!
    $self->redirect(
        $self->build_url(
            path_handler => 'Asset',
            action       => 'View',
            step         => 'view',
            path         => [],
        )
    );

    return;
} # }}}

# vim: fdm=marker
1;
