package SLight::Output::TEST;
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

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use Params::Validate qw( :all );
use YAML::Syck;
# }}}

sub prepare { # {{{
    my ( $self, $template ) = @_;

    $self->{'TEST'}->{'template'} = $template;

    return;
} # }}}

sub list_addons { # {{{
    # Fixme: tests should be able to overwrite this.
    return qw( Core::Toolbox Core::Path );
} # }}}

sub process_object_data { # {{{
    my ( $self, $oid, $data_structure ) = @_;

#    use Data::Dumper; warn q{process_object_data: } . Dumper $oid, $data_structure;

    $self->{'TEST'}->{'objects'}->{$oid} = $data_structure; 

    return;
} # }}}

sub process_addon_data { # {{{
    my ( $self, $addon, $data_structure ) = @_;

#    use Data::Dumper; warn q{process_addon_data: } . Dumper $addon, $data_structure;

    $self->{'TEST'}->{'addons'}->{$addon} = $data_structure; 

    return;
} # }}}

sub serialize { # {{{
    my ( $self, $object_order ) = @_;

#    use Data::Dumper; warn 'SERIALIZE: '. Dumper $self->{'TEST'};

    my $out = {
        'object_data'  => $self->{'TEST'}->{'objects'},
        'object_order' => $object_order,
        'addon_data'   => $self->{'TEST'}->{'addons'},
        'template'     => $self->{'TEST'}->{'template'},
    };

    # Want to dump 'out'?

    return $out;
} # }}}

# vim: fdm=marker
1;
