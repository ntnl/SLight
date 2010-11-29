package SLight::Addon::CMS::Rootmenu;
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

    my $pages = SLight::API::Page::get_Page_fields_where(
        parent_id => 1,

        _fields => [qw( path )]
    );

    my @menu_items;
    foreach my $page (@{ $pages }) {
        my $class = 'Other';

        my ( $order_by, $use_in_menu ) = $self->extract_fields($page->{'id'});

        # FIXME! This will not work on 2-nd level page :(
        if ($self->{'page_id'} == $page->{'id'}) {
            $class = 'Current';
        }

        my $menu_item = mk_Link_token(
            class => $class,
            href  => SLight::Core::URL::make_url(
                path => [ $page->{'path'} ],
            ),
            text => ( $use_in_menu or $page->{'path'} ),
        );

        $menu_item->{'_sort'} = ( $order_by or $page->{'path'} );

        push @menu_items, $menu_item;
    }

    my $container = mk_Container_token(
        class   => 'SLight_Rootmenu_Addon',
        content => [
            map { delete $_->{'_sort'}; $_ } sort { $a->{'_sort'} cmp $b->{'_sort'} } @menu_items
        ],
    );

    return $container;
} # }}}

# vim: fdm=marker
1;
