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

use SLight::Core::Entity;

use Params::Validate qw( :all );
# }}}

my %meta = (
    all_fields  => [qw( id parent_id path template )],
    data_fields => [qw(    parent_id path template )],
);

sub add_page { # {{{
    my %P = validate (
        @_,
        {
            parent_id => { type=>SCALAR, optional=>1 },
            path      => { type=>SCALAR },
            
            template => { type=>SCALAR, optional=>1 },
        }
    );

    return SLight::Core::Entity::add_ENTITY(
        id => $P{'id'},

        parent_id => $P{'parent_id'},
        path      => $P{'path'},
            
        template => $P{'template'},

        _fields => $meta{'data_fields'},
        _table  => 'Page_Entity',
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

    return SLight::Core::Entity::update_ENTITY(
        id => $P{'id'},

        parent_id => $P{'parent_id'},
        path      => $P{'path'},
            
        template => $P{'template'},

        _fields => $meta{'data_fields'},
        _table  => 'Page_Entity',
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

    return SLight::Core::Entity::update_ENTITYs(
        ids => $P{'ids'},

        parent_id => $P{'parent_id'},
        path      => $P{'path'},
            
        template => $P{'template'},

        _fields => $meta{'data_fields'},
        _table  => 'Page_Entity',
    );
} # }}}

sub delete_page { # {{{
    my ( $id ) = @_;

    return SLight::Core::Entity::delete_ENTITYs( [ $id ], 'Page_Entity');
} # }}}

sub delete_pages { # {{{
    my ( $ids ) = @_;

    return SLight::Core::Entity::delete_ENTITYs($ids, 'Page_Entity');
} # }}}

sub get_page { # {{{
    my ( $id ) = @_;

    return SLight::Core::Entity::get_ENTITY($id, 'Page_Entity', $meta{'all_fields'});
} # }}}

sub get_pages { # {{{
    my ( $ids ) = @_;

    return SLight::Core::Entity::get_ENTITYs($ids, 'Page_Entity', $meta{'all_fields'});
} # }}}

sub get_page_ids_where { # {{{
    return SLight::Core::Entity::get_ENTITY_ids_where(
        @_,
        _table => 'Page_Entity',
    );
} # }}}

sub get_page_fields_where { # {{{
    return SLight::Core::Entity::get_ENTITY_fields_where(
        @_,
        _table => 'Page_Entity',
    );
} # }}}

# sub attach_page_to_page { # {{{
# } # }}}

# sub attach_pages_to_page { # {{{
# } # }}}

# vim: fdm=marker
1;
