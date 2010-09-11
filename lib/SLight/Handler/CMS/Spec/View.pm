package SLight::Handler::CMS::Spec::View;
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

use SLight::API::ContentSpec qw( get_ContentSpec );
use SLight::Core::L10N qw( TR );
use SLight::DataStructure::List::Table::Properties;
use SLight::DataToken qw( mk_Label_token mk_Link_token );

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_toolbox(
        [
            {
                caption => TR('Add new Spec'),
                action  => 'New',
                path    => [
                    'Spec'
                ],
            }
        ]
    );
    
    my $spec = get_ContentSpec($oid);

    my $properties = SLight::DataStructure::List::Table::Properties->new(
        caption => TR(q{Content Entry specification:}),
    );

    return $properties;
} # }}}

# vim: fdm=marker
1;
