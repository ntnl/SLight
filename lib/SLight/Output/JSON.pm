package SLight::Output::JSON;
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
use base q{SLight::Output};

use SLight::Core::Config;

use JSON::XS;
use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub process_object_data { # {{{
    my ( $self, $oid, $data_structure ) = @_;

#    use Data::Dumper; warn q{process_object_data: } . Dumper $oid, $data_structure;

    $self->{'JSON'}->{'objects'}->{$oid} = $data_structure;

    return;
} # }}}

sub process_addon_data { # {{{
    my ( $self, $addon, $data_structure ) = @_;

#    use Data::Dumper; warn q{process_addon_data: } . Dumper $addon, $data_structure;

    my $addon_placeholder = $addon;
    $addon_placeholder =~ s{::}{\.}s;

    $self->{'JSON'}->{'addons'}->{$addon_placeholder} = $data_structure;

    return;
} # }}}

sub serialize { # {{{
    my ( $self, $object_order, $template_code ) = @_;

#    use Data::Dumper; warn Dumper $self->{'JSON'};

    my %json_data = (
        data_order => $object_order,

        data => {},
    );
    
    foreach my $object_id (@{ $object_order }) {
        if ($self->{'JSON'}->{'objects'}->{$object_id}) {
            $json_data{'data'}->{$object_id} = $self->{'JSON'}->{'objects'}->{$object_id}->{'content'}->[0];
        }
    }

    return (
        encode_json( \%json_data ),
        q{text/plain; character-set: utf-8},
        q{application/json; character-set: utf-8}
    );
} # }}}

# vim: fdm=marker
1;
