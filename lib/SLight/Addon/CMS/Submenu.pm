package SLight::Addon::CMS::Submenu;
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
use SLight::API::Page;
use SLight::Core::URL;
use SLight::Core::Config;
use SLight::DataToken qw( mk_Link_token mk_Container_token );

use Params::Validate qw( :all );
# }}}

sub _process { # {{{
    my ( $self ) = @_;

    if (not $self->{'page_id'}) {
        return;
    }

    my $page = SLight::API::Page::get_page($self->{'page_id'});

    if ($page->{'parent_id'} == 1) {
        return;
    }

    my $pages = SLight::API::Page::get_page_fields_where(
        parent_id => $page->{'parent_id'},

        _fields => [qw( path )]
    );

    my @menu_items;
    foreach my $sub_page (@{ $pages }) {
        my $class = 'Other';

        # FIXME! This will not work on 2-nd level page :(
        if ($page->{'id'} == $sub_page->{'id'}) {
            $class = 'Current';
        }

        my $menu_item = mk_Link_token(
            class => $class,
            href  => SLight::Core::URL::make_url(
                path => [ $sub_page->{'path'} ],
            ),
            text => $sub_page->{'path'}, # Fix this! Use some hjuman text.
        );

        push @menu_items, $menu_item;
    }

    my $container = mk_Container_token(
        class   => 'SLight_Submenu_Addon',
        content => \@menu_items,
    );

    return $container;
} # }}}

# vim: fdm=marker
1;
