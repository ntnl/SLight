package SLight::Addon::Core::Path;
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

use SLight::Core::Config;
use SLight::DataToken qw( mk_Link_token mk_Container_token );

use Params::Validate qw( :all );
# }}}

our $VERSION = '0.0.2';

sub _process { # {{{
    my ( $self, %P ) = @_;

    if (not $self->{'meta'}->{'path_bar'}) {
        return;
    }

#    use Data::Dumper; warn Dumper $self->{'meta'}->{'path_bar'};

    my @path_items = (
        mk_Link_token(
            class => 'Root',
            href  => SLight::Core::Config::get_option('web_root'),
            text  => SLight::Core::Config::get_option('name'),
        ),
    );

    foreach my $pwd_bar_item (@{ $self->{'meta'}->{'path_bar'} }) {
        my $path_item = mk_Link_token(
            class => $pwd_bar_item->{'class'}, # FIXME: Should be assigned here, not elsewhere!!!
            href  => $pwd_bar_item->{'href'},
            text  => $pwd_bar_item->{'label'},
        );

        push @path_items, $path_item;
    }

    my $container = mk_Container_token(
        class   => 'SLight_Path_Addon',
        content => \@path_items,
    );

    return $container;
} # }}}

# vim: fdm=marker
1;
