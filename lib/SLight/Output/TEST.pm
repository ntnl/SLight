package SLight::Output::TEST;
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
use base q{SLight::Output};

use SLight::Core::Config;

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use Params::Validate qw( :all );
use YAML::Syck;
# }}}

sub process_object_data { # {{{
    my ( $self, $oid, $data_structure ) = @_;

    $self->{'TEST'}->{'objects'}->{$oid} = $data_structure; 

    return;
} # }}}

sub serialize { # {{{
    my ( $self, $object_order, $template_code ) = @_;

    return {
        'object_data'  => $self->{'TEST'}->{'objects'},
        'object_order' => $object_order,
        'template'     => $template_code,
    };
} # }}}

# vim: fdm=marker
1;
