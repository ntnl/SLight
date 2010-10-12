package SLight::Handler::Core::Asset::Download;
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

use SLight::API::Asset qw( get_Asset get_Asset_data );
use SLight::Core::L10N qw( TR );

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('Asset');

    # Check if the asset exists:
    my $asset = get_Asset($oid);
    
    if ($asset) {
        my $data = get_Asset_data($asset->{'id'});

        $self->upload($data, $asset->{'mime_type'});
    }

    return;
} # }}}

# vim: fdm=marker
1;
