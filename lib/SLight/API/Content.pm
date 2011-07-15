package SLight::API::Content;
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

use SLight::Core::Config;
use SLight::Core::Accessor;
use SLight::Core::DB;

use Carp;
use Carp::Assert::More qw( assert_integer assert_isa );
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

my $_handler = SLight::Core::Accessor->new( # {{{
    table   => 'Content_Entity',
    columns => [qw( status on_page_index comment_write_policy comment_read_policy added_time modified_time )],

    refers => {
        Spec => {
            table   => 'Content_Spec',
            columns => [qw( id owning_module class cms_usage )],
        },
        Page => {
            table   => 'Page_Entity',
            columns => [qw( id parent_id path menu_order )],
        },
        Owner => {
            table   => 'Email',
            columns => [qw( email user_id )],
        },
    },

    referenced => {
        Data => {
            table   => 'Content_Entity_Data',
            columns => [qw( Content_Entity_id Content_Spec_Field_id language value )], # summary sort_index_aid

            cb => {
                get => sub { # {{{
                    my ( $items ) = @_;

                    my %data;
                    foreach my $item (@{ $items }) {
                        delete $item->{'id'};
                        delete $item->{'Content_Entity_id'};

                        $data{ delete $item->{'language'} }->{ delete $item->{'Content_Spec_Field_id'} } = $item;
                    }
                    return \%data;
                }, # }}}
                put => sub { # {{{
                    my ( $parent_id, $data ) = @_;

                    my @items;
                    foreach my $language (keys %{ $data }) {
                        foreach my $Content_Spec_Field_id (keys %{ $data->{$language} }) {
                            assert_isa($data->{ $language }->{ $Content_Spec_Field_id }, 'HASH');

                            push @items, {
                                key => {
                                    Content_Entity_id     => int $parent_id,
                                    Content_Spec_Field_id => int $Content_Spec_Field_id,
                                    language              => $language
                                },
                                val => $data->{ $language }->{ $Content_Spec_Field_id },
                            };
                        }
                    }

                    return @items;
                } # }}}
            }
        },
    },

    has_metadata => 1,
    has_owner    => 1,
    has_assets   => 1,
    has_comments => 1,

    cache_namespace => 'SLight::Core::Content'
); # }}}

sub add_Content { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    assert_integer($P{'Content_Spec_id'}, 'Content_Spec_id');

    return $_handler->add_ENTITY(
        %P,

        added_time    => $_handler->timestamp_2_timedate(time),
        modified_time => $_handler->timestamp_2_timedate(time),
    );
} # }}}

sub update_Content { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    return $_handler->update_ENTITY(
        %P,

        modified_time => $_handler->timestamp_2_timedate(time),
    );
} # }}}

sub update_Contents { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    return $_handler->update_ENTITIES(
        %P,

        modified_time => $_handler->timestamp_2_timedate(time),
    );
} # }}}

sub count_Contents_where { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    return $_handler->count_ENTITIES_where(%P);
} # }}}

sub get_Content { # {{{
    my ( $id ) = @_; # Fixme: use Params::Validate here!

    my $content_object = $_handler->get_ENTITY($id, 1);

    return $content_object;
} # }}}

sub get_Contents { # {{{
    my ( $ids ) = @_; # Fixme: use Params::Validate here!

    my $content_objects = $_handler->get_ENTITIES($ids);

    return $content_objects;
} # }}}

sub get_Contents_where { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    my $unfold = $P{'_unfold'};

    my $content_objects = $_handler->get_ENTITIES_where(%P);

    if ($unfold) {
        _unfold($content_objects, $P{'_data_lang'}, $unfold);
    }

    return $content_objects;
} # }}}

sub get_Contents_fields_where { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    my $unfold = $P{'_unfold'};

    my $content_objects = $_handler->get_ENTITIES_fields_where(%P);

    if ($unfold) {
        _unfold($content_objects, $P{'_data_lang'}, $unfold);
    }

    return $content_objects;
} # }}}

# This routing will add _uf_* keys to every object in $objects list.
# It supports:
#   _uf_order_by
#   _uf_use_as_title
#   _uf_use_in_menu
#   _uf_use_in_path
#
# Note: this is more a prototype, that will be slow.
# As soon as it does the right thing, it has to be re factored.
#
# Note: fields that are to be unfolded have to be added to _fields.
# This is not done automatically for now.
sub _unfold { # {{{
    my ( $objects, $lang, $unfold ) = @_;

    my $default_lang = SLight::Core::Config::get_option('lang')->[0];

    my %need_fields;
    my %need_fields_oids;

    my %need_data_fields;
    my %need_data_fields_oids;

    #use Data::Dumper; warn Dumper $objects;

    foreach my $object (@{ $objects }) {
        my @langs = (
            ( $lang or $default_lang ),
            ( keys %{ $object->{'_data'} } ),
            q{*}
        );

        foreach my $field (@{ $unfold }) {
            my $spec = $object->{$field};

            if (not defined $spec) {
                $object->{ '_uf_' . $field } = $object->{'id'};
            }
            elsif ($spec =~ m{^\d+$}s) {
                foreach my $lang (@langs) {
                    if (exists $object->{'_data'}->{$lang}->{$spec}) {
                        $object->{ '_uf_' . $field } = $object->{'_data'}->{$lang}->{$spec};
                        last;
                    }
                }

                if (not $object->{ '_uf_' . $field }) {
                    $need_data_fields{$spec} = $object;
                    $need_data_fields_oids{ $object->{'id'} } = 1;
                }
            }
            else {
                if (exists $object->{ $spec }) {
                    $object->{ '_uf_' . $spec } = $object->{ $spec };
                }
                else {
                    push @{ $need_fields{$spec} }, $object;
                    $need_fields_oids{ $object->{'id'} } = 1;
                }
            }
        }
    }

    if (keys %need_fields_oids) {
        my $extras = get_Contents_fields_where(
            _fields => [ keys %need_fields ],

            _data_fields => [],

            ids => [ keys %need_fields_oids ],
        );
        my %extras_hash;
        foreach my $object (@{ $extras }) {
            $extras_hash{ $object->{'id'} } = $object;
        }

#        use Data::Dumper; warn 'fields ' . Dumper %extras_hash;
    }

    if (keys %need_data_fields_oids) {
        my $extras;
        my $sth = SLight::Core::DB::run_query(
            query => [
                'SELECT Content_Entity_id, Content_Spec_Field_id, language, value FROM Content_Entity_Data WHERE Content_Entity_id IN ', [ keys %need_data_fields_oids ],
                ' AND Content_Spec_Field_id IN ', [keys %need_data_fields]
            ],
            debug => 1,
        );
        while (my ($oid, $fid, $lang, $value) = $sth->fetchrow_array()) {
            $extras->{$oid}->{$fid}->{$lang} = $value;
        }

        foreach my $field_id (keys %need_data_fields) {
            foreach my $object (@{ $need_data_fields{$field_id} }) {
                my $lang = '*';
                $object->{'_data'}->{$lang}->{$field_id} = $extras->{$object->{'id'}}->{$field_id}->{$lang}; #FIXME!
            }
        }

#        use Data::Dumper; warn 'data ' . Dumper $extras;
    }

    return;
} # }}}

sub get_Content_ids_where { # {{{
    my %P = @_; # Fixme: use Params::Validate here!

    return $_handler->get_ENTITIES_ids_where(%P);
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
