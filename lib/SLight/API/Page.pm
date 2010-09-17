package SLight::API::Page;
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
use base 'Exporter';

use SLight::Core::Entity;

use Params::Validate qw( :all );
# }}}

our @EXPORT_OK = qw(
    get_Page_full_path
);
our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

my $_handler = SLight::Core::Entity->new( # {{{
    base_table  => 'Page_Entity',

    data_fields => [qw( path template )],

    is_a_tree => 1,
); # }}}

# Fixme: It should be: 'add_Page', not: 'add_page', and so on...

sub add_page { # {{{
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

sub update_page { # {{{
    my %P = validate (
        @_,
        {
            id => { type=>SCALAR },

            parent_id => { type=>SCALAR, optional=>1 },
            path      => { type=>SCALAR },
            
            template => { type=>SCALAR },
        }
    );

    return $_handler->update_ENTITY(
        id => $P{'id'},

        parent_id => $P{'parent_id'},

        path     => $P{'path'},
        template => $P{'template'},
    );
} # }}}

sub update_pages { # {{{
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

sub delete_page { # {{{
    my ( $id ) = @_;

    return $_handler->delete_ENTITYs( [ $id ] );
} # }}}

sub delete_pages { # {{{
    my ( $ids ) = @_;

    return $_handler->delete_ENTITYs( $ids );
} # }}}

sub get_page { # {{{
    my ( $id ) = @_;

    return $_handler->get_ENTITY($id);
} # }}}

sub get_pages { # {{{
    my ( $ids ) = @_;

    return $_handler->get_ENTITYs($ids);
} # }}}

sub get_page_ids_where { # {{{
    return $_handler->get_ENTITY_ids_where(@_);
} # }}}

sub get_page_fields_where { # {{{
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

# TODO:
#
# sub id_for_path

# vim: fdm=marker
1;
