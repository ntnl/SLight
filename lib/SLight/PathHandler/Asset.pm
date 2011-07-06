package SLight::PathHandler::Asset;
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
use base q{SLight::PathHandler};

my $VERSION = '0.0.5';

use SLight::API::ContentSpec;

use Carp::Assert::More qw( assert_defined );
# }}}

=head1 DESCRPITION

This path handler supports the following path schemas:

=over

=item /_Asset/

Generates a page with single I<SLight::Handler::Core::AssetList> object.

=item /_Asset/Asset/$ID/*

Generates a page with single I<SLight::Handler::Core::Asset> object.

=back

=cut

sub analyze_path { # {{{
    my ( $self, $path ) = @_;

    assert_defined($path, "Path is defined");

    $self->set_template('Default');

    $self->set_breadcrumb_path([]);

    if (scalar @{ $path }) {
        # OK... so We're actually showing something...
        if ($path->[0] eq 'Asset') {
            $self->do_asset($path->[1], $path->[2]);
        }
        else {
            # FIXME! Bad URL - must report this fact. Somehow.
        }
    }
    else {
        # Dump the list of known specs.
        $self->do_asset_list();
    }

    return $self->response_content();
} # }}}

# Purpose:
#   List Assets available in system
sub do_asset_list { # {{{
    my ( $self ) = @_;

    $self->set_objects(
        {
            l1 => {
                class => 'Core::AssetList',
                oid   => undef,
            },
        },
    );

    $self->set_object_order([qw( l1 )]);

    $self->set_main_object('l1');

    return;
} # }}}

# Purpose:
#   Handle specific spec ;) and outline his fields as aux data.
sub do_asset { # {{{
    my ( $self, $id ) = @_;

    my %objects = (
        _asset => {
            class => 'Core::Asset',
            oid   => $id,
        },
    );

    $self->set_objects( \%objects );

    $self->set_object_order( [ '_asset' ] );

    $self->set_main_object('_asset');

    return;
} # }}}

# vim: fdm=marker
1;
