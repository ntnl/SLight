package SLight::Addon::CMS::Submenu;
################################################################################
# 
# SLight - Lightweight Content Management System.
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
use base q{SLight::AddonBase::CMS::Menu};

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

    my $page = SLight::API::Page::get_Page($self->{'page_id'});

    if (not $page->{'parent_id'} or $page->{'parent_id'} == 1) {
        return;
    }

    my $pages = SLight::API::Page::get_Page_fields_where(
        parent_id => $page->{'parent_id'},

        _fields => [qw( path )]
    );

    my @menu_items;
    foreach my $sub_page (@{ $pages }) {
        my $class = 'Other';

        my ( $order_by, $use_in_menu ) = $self->extract_fields($sub_page->{'id'});

        # FIXME! This will not work on 2-nd level page :(
        if ($page->{'id'} == $sub_page->{'id'}) {
            $class = 'Current';
        }

        my $menu_item = mk_Link_token(
            class => $class,
            href  => SLight::Core::URL::make_url(
                path => [ $sub_page->{'path'} ],
            ),
            text => ( $use_in_menu or $sub_page->{'path'} ),
        );

        $menu_item->{'_sort'} = ( $order_by or $sub_page->{'path'} );

        push @menu_items, $menu_item;
    }

    my $container = mk_Container_token(
        class   => 'SLight_Submenu_Addon',
        content => [
            map { delete $_->{'_sort'}; $_ } sort { $a->{'_sort'} cmp $b->{'_sort'} } @menu_items
        ],
    );

    return $container;
} # }}}

# vim: fdm=marker
1;
