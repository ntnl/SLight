package SLight::AddonBase::CMS::Menu;
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
# }}}

sub get_pages_and_objects { # {{{
    my ( $self, $parent_page_id ) = @_;

    my $pages = SLight::API::Page::get_page_fields_where(
        parent_id => $parent_page_id,

        _fields => [qw( path )]
    );
    
    my @pages_and_objects;

    foreach my $page (@{ $pages }) {
        my %entry = (
            s => 0,
            l => $page->{'path'},
        );

        push @pages_and_objects, \%entry;
    }

    return [ sort { ( $a->{'s'} <=> $b->{'s'} ) or ( $a->{'s'} cmp $b->{'s'} ) } @pages_and_objects ];
} # }}}

sub extract_field { # {{{
    my ( $self, $page_id, $field ) = @_;
    
    my $content_objects = get_Contents_where(
        Page_Entity_id => $page_id,
        on_page_index  => 0,
    );

    my $menu_label;

    if ($content_objects->[0]) {
        my $content_spec = get_ContentSpec($content_objects->[0]->{'Content_Spec_id'});

        my @langs = (
            $self->{'url'}->{'lang'},
            ( keys %{ $content_objects->[0]->{'_data'} } ),
            q{*}
        );

        if ($content_spec and $content_spec->{'use_in_path'}) {
            if ($content_spec->{'use_in_path'} =~ m{\d}s) {
                foreach my $lang (@langs) {
                    if ($content_objects->[0]->{'_data'}->{$lang}->{ $content_spec->{'use_in_path'} }) {
                        $menu_label = $content_objects->[0]->{'_data'}->{$lang}->{ $content_spec->{'use_in_path'} };
                        last;
                    }
                }
            }
            elsif ($content_objects->[0]->{ $content_spec->{'use_in_path'} }) {
                $menu_label = $content_objects->[0]->{ $content_spec->{'use_in_path'} };
            }
        }
    }

    return;
} # }}}

# vim: fdm=marker
1;
