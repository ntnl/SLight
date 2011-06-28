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

# Obsolete?
# sub get_pages_and_objects { # {{{
#     my ( $self, $parent_page_id ) = @_;
# 
#     my $pages = get_Page_fields_where(
#         parent_id => $parent_page_id,
# 
#         _fields => [qw( path )]
#     );
# 
#     my @pages_and_objects;
# 
#     foreach my $page (@{ $pages }) {
#         my %entry = (
#             s => 0,
#             l => $page->{'path'},
#         );
# 
#         push @pages_and_objects, \%entry;
#     }
# 
#     return [ sort { ( $a->{'s'} <=> $b->{'s'} ) or ( $a->{'s'} cmp $b->{'s'} ) } @pages_and_objects ];
# } # }}}

sub build_menu { # {{{
    my ( $self, $base_path, $pages ) = @_;

    my $dfl = SLight::Core::Config::get_option('lang')->[0];

    my @menu_items;
    foreach my $page (sort { $a->{'menu_order'} <=> $b->{'menu_order'} } @{ $pages }) {
        my $class = 'Other';

        # FIXME! This will not work on 2-nd level page :(
        if ($self->{'page_id'} == $page->{'id'}) {
            $class = 'Current';
        }

        my $l10n_node = ( $page->{'L10N'}->{ $self->{'url'}->{'lang'} } or $page->{'L10N'}->{ $dfl } or { menu => $page->{'path'} } );

#        use Data::Dumper; warn Dumper $l10n_node;

        my $menu_item = mk_Link_token(
            class => $class,
            href  => SLight::Core::URL::make_url(
                path => [ @{ $base_path }, $page->{'path'} ],
            ),
            text => $l10n_node->{'menu'},
        );

        push @menu_items, $menu_item;
    }

    return \@menu_items;
} # }}}

# vim: fdm=marker
1;
