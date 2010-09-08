package SLight::Handler::CMS::SpecList::View;
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

use SLight::API::ContentSpec qw( get_all_ContentSpecs );
use SLight::DataStructure::Token;
use SLight::DataToken qw( mk_Label_token );

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $specs = get_all_ContentSpecs();

#    warn ":)";

    my $token = SLight::DataStructure::Token->new(
        token => mk_Label_token(
            text => q{Works!},
        ),
    );

    return $token;
} # }}}

# vim: fdm=marker
1;
