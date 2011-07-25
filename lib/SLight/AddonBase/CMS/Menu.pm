package SLight::AddonBase::CMS::Menu;
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
use base q{SLight::Addon};

use SLight::API::Content qw( get_Contents_where );
use SLight::API::ContentSpec qw( get_ContentSpec );
use SLight::API::Page qw( get_Page_fields_where );
use SLight::Core::Config;
use SLight::Core::L10N qw( TR TF );
use SLight::DataToken qw( mk_Link_token );
# }}}

sub build_menu { # {{{
    my ( $self, $base_path, $pages, $selected_page_id ) = @_;

    my $dfl = SLight::Core::Config::get_option('lang')->[0];

    my @menu_items;
    foreach my $page (sort { $a->{'menu_order'} <=> $b->{'menu_order'} or $b->{'id'} <=> $a->{'id'} } @{ $pages }) {
        my $class = 'Other';

        if ($page->{'id'} == $selected_page_id) {
            $class = 'Current';
        }

        my $label;
        foreach my $lang (@{ SLight::Core::Config::get_option('lang') }, q{*}) {
            warn "$lang?";
            if ($page->{'L10N'}->{ $lang }->{'menu'}) {
                $label = $page->{'L10N'}->{ $lang }->{'menu'};
                last;
            }
        }

        if (not $label) {
            $label = $page->{'path'};
        }

        my $menu_item = mk_Link_token(
            class => $class,
            href  => SLight::Core::URL::make_url(
                path => [ @{ $base_path }, $page->{'path'} ],
            ),
            text => $label,
        );

        push @menu_items, $menu_item;
    }

    return \@menu_items;
} # }}}

# vim: fdm=marker
1;
