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

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle { # {{{
    my ( $self, $oid, $metadata ) = @_;

#    warn ":)";

    use SLight::DataStructure::Token;

    my $token = SLight::DataStructure::Token->new(
        token => {
            type => q{Label},
            text => q{Works!},
        }
    );

    return $token;
} # }}}

# vim: fdm=marker
1;
