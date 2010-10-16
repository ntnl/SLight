package SLight::Addon::Core::Language;
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
use SLight::Core::URL;
use SLight::Core::Config;
use SLight::DataToken qw( mk_Link_token mk_Container_token );

use Params::Validate qw( :all );
# }}}

sub _process { # {{{
    my ( $self, %P ) = @_;

    my @langs = @{ SLight::Core::Config::get_option('lang') };

    my $selected_lang = ( $self->{'lang'} or $langs[0] );

    my @language_items;
    foreach my $language (@langs) {
        my $class = 'Other';

        if ($language eq $selected_lang) {
            $class = 'Current';
        }

        my $language_item = mk_Link_token(
            class => $language .q{-}. $class,
            href  => SLight::Core::URL::make_url(
                %{ $self->{'url'} },

                lang    => $language,
            ),
            text  => TR($language .q{#lang}),
        );

        push @language_items, $language_item;
    }

    my $container = mk_Container_token(
        class   => 'SLight_Language_Addon',
        content => \@language_items,
    );

    return $container;
} # }}}

# vim: fdm=marker
1;
