package SLight::Addon::Core::Sysinfo;
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
use base q{SLight::Addon};

use SLight::Core::L10N qw( TR TF );
use SLight::DataToken qw( mk_Label_token mk_Container_token );

use Params::Validate qw( :all );
# }}}

sub _process { # {{{
    my ( $self, %P ) = @_;

    my @info_items;
    
    # The string: $gen_item$ should be replaced by Interface,
    # the Interface knows how much time was actually needed.
    my $item = mk_Label_token(
        text => TR(q{Generated in:}). q{ $gen_time$s},
    );
    push @info_items, $item;

    my $container = mk_Container_token(
        class   => 'SLight_Sysinfo_Addon',
        content => \@info_items,
    );

    return $container;
} # }}}

# vim: fdm=marker
1;
