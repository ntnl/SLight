package SLight::API::Content;
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

use Carp;
use Params::Validate qw{ :all };
# }}}

our @EXPORT_OK = qw(
    add_Content
    update_Content
    update_Contents
    count_Contents_where
    get_Content
    get_Contents
    get_Content_ids_where
    get_Contents_where
    get_Contents_fields_where
    delete_Content
    delete_Contents
);
our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

my $_handler = SLight::Core::Entity->new( # {{{
    base_table       => 'Content_Entity',
    child_table      => 'Content_Entity_Data',

# Fixme: add added_time and modified_time to the list: (they are dynamically created, therefore tricky!
    data_fields        => [qw( status Page_Entity_id on_page_index comment_write_policy comment_read_policy Content_Spec_id added_time modified_time )],
    child_data_fields  => [qw( value )],
    parent_data_fields => [qw( owning_module )],

    child_key => [ 'language', 'Content_Spec_Field_id' ],

    has_metadata => 1,
    has_owner    => 1,
    has_assets   => 1,
    has_comments => 1,

#    # Yes, this implementation is not optimal, but will suit as a nice Proof Of Concept.
#    # Once it setles, it can be refactored to address it's shortcommings.
#    data_callback => {
#        data_in  => \&_data_in_cb,
#        data_out => \&_data_out_cb
#    },

    cache_namespace => 'SLight::Core::Content'
); # }}}

sub add_Content { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    return $_handler->add_ENTITY(%P);
} # }}}

sub update_Content { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    return $_handler->update_ENTITY(%P);
} # }}}

sub update_Contents { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    return $_handler->update_ENTITYs(%P);
} # }}}

sub count_Contents_where { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    return $_handler->count_ENTITYs_where(%P);
} # }}}

sub get_Content { # {{{
    my ( $id ) = @_; # Fixme: use Params::Validate here!

    return $_handler->get_ENTITY($id);
} # }}}

sub get_Contents { # {{{
    my ( $ids ) = @_; # Fixme: use Params::Validate here!

    return $_handler->get_ENTITYs($ids);
} # }}}

sub get_Contents_where { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    return $_handler->get_ENTITYs_where(%P);
} # }}}

sub get_Contents_fields_where { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    return $_handler->get_ENTITYs_fields_where(%P);
} # }}}

sub get_Content_ids_where { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    return $_handler->get_ENTITY_ids_where(%P);
} # }}}

sub delete_Content { # {{{
    my ( $id ) = @_; # Fixme: use Params::Validate here!

    return $_handler->delete_ENTITY($id);
} # }}}

sub delete_Contents { # {{{
    my ( $ids ) = @_; # Fixme: use Params::Validate here!

    return $_handler->delete_ENTITYs($ids);
} # }}}


#sub _update_mtime { # {{{
#    my ( $update_id ) = @_;
#
#    my $NOW = SLight::Core::DB::NOW();
#
#    while ($update_id) {
#        Cache_invalidate_referenced($CACHE_NAMESPACE, [$update_id]);
#
#        SLight::Core::DB::run_query(
#            query => [ "UPDATE ContentEntry SET `revision` = `revision` + 1, child_time = ", $NOW, " WHERE id = ", $update_id ],
##            debug => 1,
#        );
#
#        my $sth = SLight::Core::DB::run_query(
#            query => [ "SELECT ContentEntry_id FROM ContentEntry WHERE id = ", $update_id ],
##            debug => 1,
#        );
#        ( $update_id ) = $sth->fetchrow_array();
#    }
#    
#    return;
#} # }}}


#sub set_status { # {{{
#    my %P = validate(
#        @_,
#        {
#            id     => { type=>SCALAR },
#            status => { type=>SCALAR, regex=>qr{^visible|hidden$}s }, ## no critic qw(ProhibitPunctuationVars)
#        }
#    );
#
#    SLight::Core::DB::run_update(
#        table => 'ContentEntry',
#        set   => {
#            status => $P{'status'},
#        },
#        where => [
#            'id = ', $P{'id'}
#        ]
#    );
#
#    return $P{'status'};
#} # }}}

# vim: fdm=marker
1;
