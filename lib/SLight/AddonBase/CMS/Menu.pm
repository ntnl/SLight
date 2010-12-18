package SLight::AddonBase::CMS::Menu;
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
use base q{SLight::Addon};

use SLight::API::Content qw( get_Contents_where );
use SLight::API::ContentSpec qw( get_ContentSpec );
use SLight::API::Page qw( get_Page_fields_where );
use SLight::Core::L10N qw( TR TF );
# }}}

sub get_pages_and_objects { # {{{
    my ( $self, $parent_page_id ) = @_;

    my $pages = get_Page_fields_where(
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

# Purpose:
#   Return content for 'order_by' and 'use_in_menu'.
sub extract_fields { # {{{
    my ( $self, $page_id ) = @_;
    
    my $content_objects = get_Contents_where(
        Page_Entity_id => $page_id,
        on_page_index  => 0,
#        debug => 1,
    );

    if (not $content_objects->[0]) {
        return;
    }

    my @fields_content;

    my $content_spec = get_ContentSpec($content_objects->[0]->{'Content_Spec_id'});

    my @langs = (
        $self->{'url'}->{'lang'},
        ( keys %{ $content_objects->[0]->{'_data'} } ),
        q{*}
    );

    my $content = q{};

    foreach my $field (qw( order_by use_in_menu )) {
        if ($content_spec and $content_spec->{$field}) {
            if ($content_spec->{$field} =~ m{\d}s) {
                foreach my $lang (@langs) {
                    if ($content_objects->[0]->{'_data'}->{$lang}->{ $content_spec->{$field} }) {
                        $content = $content_objects->[0]->{'_data'}->{$lang}->{ $content_spec->{$field} };
                        last;
                    }
                }
            }
            elsif ($content_objects->[0]->{ $content_spec->{$field} }) {
                $content = $content_objects->[0]->{ $content_spec->{$field} };
            }
        }

        push @fields_content, $content;
    }

    return @fields_content;
} # }}}

# vim: fdm=marker
1;
