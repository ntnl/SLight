package SLight::API::Page;
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
use base 'Exporter';

use SLight::Core::Entity;

use Params::Validate qw( :all );
# }}}

our @EXPORT_OK = qw(
    add_Page
    update_Page
    update_Pages
    delete_Page
    delete_Pages
    get_Page
    get_Pages
    get_Pages_where
    get_Page_ids_where
    get_Page_fields_where
    get_Page_full_path
    get_Page_id_for_path
);
our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

my $_handler = SLight::Core::Entity->new( # {{{
    base_table  => 'Page_Entity',

    data_fields => [qw( path template )],

    is_a_tree => 1,
); # }}}

sub add_Page { # {{{
    my %P = validate (
        @_,
        {
            parent_id => { type=>SCALAR | UNDEF },
            path      => { type=>SCALAR },

            template => { type=>SCALAR, optional=>1 },
        }
    );

    return $_handler->add_ENTITY(
        parent_id => $P{'parent_id'},

        path     => $P{'path'},
        template => $P{'template'},
    );
} # }}}

sub update_Page { # {{{
    my %P = validate (
        @_,
        {
            id => { type=>SCALAR },

            parent_id => { type=>SCALAR, optional=>1 },
            path      => { type=>SCALAR, optional=>1 },
            
            template => { type=>SCALAR, optional=>1 },
        }
    );

    return $_handler->update_ENTITY(%P);
} # }}}

sub update_Pages { # {{{
    my %P = validate (
        @_,
        {
            ids => { type=>ARRAYREF },

            parent_id => { type=>SCALAR, optional=>1 },
            path      => { type=>SCALAR, optional=>1 },
            
            template => { type=>SCALAR, optional=>1 },
        }
    );

    return $_handler->update_ENTITYs(
        ids => $P{'ids'},

        parent_id => $P{'parent_id'},

        path     => $P{'path'},
        template => $P{'template'},
    );
} # }}}

sub delete_Page { # {{{
    my ( $id ) = @_;

    return $_handler->delete_ENTITYs( [ $id ] );
} # }}}

sub delete_Pages { # {{{
    my ( $ids ) = @_;

    return $_handler->delete_ENTITYs( $ids );
} # }}}

sub get_Page { # {{{
    my ( $id ) = @_;

    return $_handler->get_ENTITY($id);
} # }}}

sub get_Pages { # {{{
    my ( $ids ) = @_;

    return $_handler->get_ENTITYs($ids);
} # }}}

sub get_Pages_where { # {{{
    return $_handler->get_ENTITYs_where(@_);
} # }}}

sub get_Page_ids_where { # {{{
    return $_handler->get_ENTITY_ids_where(@_);
} # }}}

sub get_Page_fields_where { # {{{
    return $_handler->get_ENTITYs_fields_where(@_);
} # }}}

sub get_Page_full_path { # {{{
    my ( $id ) = @_;

    my @path;
    while ($id and my $page = $_handler->get_ENTITY($id)) {
        if ($page->{'parent_id'}) {
            unshift @path, $page->{'path'};
        }

        $id = $page->{'parent_id'};
    }

    return \@path;
} # }}}

sub get_Page_id_for_path { # {{{
    my ( $path ) = @_;

    if (not scalar @{ $path }) {
        return 1;
    }

    my $parent_id = 1;
    my $last_page_id;
    foreach my $part (@{ $path }) {
        if (not $part) { next; }

        my $pages = SLight::API::Page::get_Page_fields_where(
            parent_id => $parent_id,
            path      => $part,

            _fields => [qw( id template )],
        );

        if (not $pages->[0]) {
            # Something IS wrong here! It's not possible to have holes in path!
            # Let's hope, it's just User messing with the URL.
            return;
        }

        $parent_id = $last_page_id = $pages->[0]->{'id'};
    }

    return $last_page_id;
} # }}}

# vim: fdm=marker
1;
