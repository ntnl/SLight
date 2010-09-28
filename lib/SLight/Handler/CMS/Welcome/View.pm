package SLight::Handler::CMS::Welcome::View;
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

use SLight::API::ContentSpec qw( get_ContentSpecs_where );
use SLight::DataStructure::Dialog;
use SLight::Core::L10N qw( TR );

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('Welcome');

    my $specs = get_ContentSpecs_where(
        cms_usage => [1, 2, 3],
    );

    if (not scalar @{ $specs }) {
        my $dialog = SLight::DataStructure::Dialog->new(
            text => TR('Welcome to SLight Content Management System. This instalation has no content.'), 
        );

        $dialog->add_button(
            caption => TR("Start by adding Content specification."),
            href    => $self->build_url(
                path_handler => q{CMS_Spec},
                path         => [],
            )
        );

        $self->push_data($dialog);
    }
    else {
        my $dialog = SLight::DataStructure::Dialog->new(
            text => TR('Welcome to SLight Content Management System. This instalation has no content.'), 
        );

        $dialog->add_button(
            caption => TR("Start by adding Content."),
            href    => $self->build_url(
                action => q{AddContent},
            )
        );

        $self->push_data($dialog);
    }

    return;
} # }}}

# vim: fdm=marker
1;
