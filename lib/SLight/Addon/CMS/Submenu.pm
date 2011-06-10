package SLight::Addon::CMS::Submenu;
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

        _fields => [qw( path menu_order L10N )]
    );

    my $menu_items = $self->build_menu([], $pages);

    my $container = mk_Container_token(
        class   => 'SLight_Submenu_Addon',
        content => $menu_items,
    );

    return $container;
} # }}}

# vim: fdm=marker
1;
