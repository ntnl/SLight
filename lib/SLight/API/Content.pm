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
use utf8;

use SLight::Core::Config;
use SLight::Core::DB;
use SLight::Core::Email;
#use SLight::Core::Cache qw( Cache_get Cache_put Cache_invalidate Cache_invalidate_referenced );
#use SLight::Core::Cache::Util;

use Carp;
use Params::Validate qw{ :all };
# }}}

# Content hash:
# {
#   id => INT,
#       # Auto created, can not be changed
#
#   parent_id => INT
#       # Id of the parent entry
#
#   ContentType_id => STRING,
#       # ContentType ID
#
#   path => STRING,
#        # Path element, used to identify the entry using URL.
#
#   status => 'visible' / 'hidden' / 'system',
#
#   template => FILE_NAME,
#
#   comments => INT,
#
#   data => {
#       field => value
#   },
#
#   added_time
#       # Time, when this entry was added.
#       # Set automaticly, when entry is added, then read-only.
#
#   modified_time
#       # Time, when this entry had it's most recent change.
#
#   revision
#       # Integer, starting from zero.
#
#   email => STRING,
#       # Email used to sign the comment.
#       # It will be either an email given in the form, by the guest, when it filed the comment,
#       # or the email of the (registered) User.
#       # Read-only field.
#
#   user => STRING,
#       # Login of the User, that made the comment.
#       # If the comment was made by a guest, this will be 'undef'.
#       # This is read-only, field will be returned by functions, but should not be given to them.
#       # Read-only field.
# }
#
# See also: description in content.sql
#
#   Cache:
#
# Note, that it's not always possible to invalidate cached Content data,
# when it changes. Each time stuff is fetched from Cache, it's revision
# must be verified, to see if cached data still is valid!
#
# Making Cache keys:
#   single-ID-LANG
#
#   list-ID1(R1)-ID2(R2)-...-IDn(Rn)-LANG
#       - Ids should always be sorted numerically!
#
#   sorted_list-ID1(R1)-ID2(R2)-...-IDn(Rn)-LANG
#       - Ids should always be sorted numerically!

my $default_data_lang = 'en';

my $CACHE_NAMESPACE = 'CoMe::Core::Content';

sub set_one { # {{{
    my %P = validate (
        @_,
        {
            id           => { type=>SCALAR, optional=>1 },
            EmailMeta_id => { type=>SCALAR, optional=>1 },

	        parent_id         => { type=>SCALAR, optional=>1, default=>0 },
	        ContentType       => { type=>HASHREF, },
            ContentHandler_id => { type=>SCALAR },

            path     => { type=>SCALAR },
            status   => { type=>SCALAR, regex=>qw{^(hidden|visible)$} },
            template => { type=>SCALAR },
            comments => { type=>SCALAR },

	        data => { type=>HASHREF },

            data_lang => { type=>SCALAR, optional=>1, default=>$default_data_lang },
        }
    );

#    use Data::Dumper; warn 'CoMe::Core::Content::set_one: '. Dumper \%P;

    my $NOW = CoMe::Core::DB::NOW();

    # In what mode should we run?
    my %current_data;
    if ($P{'id'}) {
        Cache_invalidate_referenced($CACHE_NAMESPACE, [$P{'id'}]);

        %current_data = get_one(
            id => $P{'id'},

            data_lang => $P{'data_lang'}
        );

        # SQL module will do the update, only if the values differ :)
        CoMe::Core::DB::run_update(
            table => 'ContentEntry',
            set => {
                ContentEntry_id => $P{'parent_id'},
                ContentType_id  => $P{'ContentType'}->{'id'},
                path            => $P{'path'},
                status          => $P{'status'},
                template        => $P{'template'},
                comments        => $P{'comments'},
                modified_time   => $NOW,
                revision        => $current_data{'revision'} + 1,
            },
            diff => {
                ContentEntry_id => $current_data{'parent_id'},
                ContentType_id  => $current_data{'ContentType'}->{'id'},
                path            => $current_data{'path'},
                status          => $current_data{'status'},
                template        => $current_data{'template'},
                comments        => $current_data{'comments'},
                modified_time   => $current_data{'modified_time'},
                revision        => 1, # Force it to always change.
            },
            where => [
                'id = ', $P{'id'}
            ],
#            debug => 1,
        );
    }
    else {
        # Simply put stuff in DB.
        confess_on_false(
            ( $P{'EmailMeta_id'} ),
            q{Mandatory parameter: 'EmailMeta_id' missing, when adding new content!},
        );

        CoMe::Core::DB::run_insert(
            'into'   => 'ContentEntry',
            'values' => {
                ContentEntry_id   => $P{'parent_id'},
                ContentHandler_id => $P{'ContentHandler_id'},
                ContentType_id    => $P{'ContentType'}->{'id'},
                EmailMeta_id      => $P{'EmailMeta_id'},
                path              => $P{'path'},
                status            => $P{'status'},
                template          => $P{'template'},
                comments          => $P{'comments'},
                added_time        => $NOW,
                modified_time     => $NOW,
                child_time        => $NOW,
            },
#            debug => 1,
        );

        %current_data = (
            id             => CoMe::Core::DB::last_insert_id(),
            norent_id      => $P{'parent_id'},
            ContentType_id => $P{'ContentType'}->{'id'},
            path           => $P{'path'},
            status         => $P{'status'},
            template       => $P{'template'},
            revision       => 1,
        );
        
        confess_on_false($current_data{'id'}, "ID was not set by DB!");
    }

    # Fixme!
    #   Use cases:
    #       - field was translated, but it is not
    #       - field was not translated, but is not
    #   are not handled cleanly! Currently they work, but may produce garbage.

    my %data_field_values;
    my $sth = CoMe::Core::DB::run_select(
        columns => [qw{ ContentEntry_id field value }],
        from    => 'ContentEntryData',
        where   => [
            'ContentEntry_id = ', $current_data{'id'},
            ' AND language IN ', [ $P{'data_lang'}, q{*} ],
        ],
#        debug => 1,
    );
    while (my ($id, $field, $value) = $sth->fetchrow_array()) {
        $data_field_values{$field} = $value;
    }

    # Insert new data fields, or update existing ones.
    foreach my $field_id (keys %{ $P{'data'} }) {
        my $field = $P{'ContentType'}->{'fields'}->{$field_id};

        # By default, assume, that field is not translatable.
        my $field_lang = q{*};
        if ($field->{'translate'}) {
            $field_lang = $P{'data_lang'};
        }

        if (defined $data_field_values{$field_id}) {
            # OK, so we have a candidate to being updated.
            # But - do we actually need to update?
            if ($data_field_values{$field_id} ne $P{'data'}->{$field_id}) {
                CoMe::Core::DB::run_update(
                    table => 'ContentEntryData',
                    set => {
                        value => $P{'data'}->{$field_id}
                    },
                    where => [
                        'ContentEntry_id = ', $current_data{'id'},
                        ' AND field = ',      $field_id,
                        ' AND language IN ', [ $P{'data_lang'}, q{*} ],
                    ],
#                    debug => 1,
                );
            }
        }
        else {
            # We must insert.
            CoMe::Core::DB::run_insert(
                'into'   => 'ContentEntryData',
                'values' => {
                    ContentEntry_id => $current_data{'id'},
                    field           => $field_id,
                    value           => $P{'data'}->{$field_id},
                    language        => $field_lang,
                },
#                debug => 1,
            );
        }
    }

    # Delete data fields, that are no longer present.
    foreach my $field_id (keys %data_field_values) {
        if (not defined $P{'data'}->{$field_id}) {
            CoMe::Core::DB::run_delete(
                from => 'ContentEntryData',
                where => [
                    'ContentEntry_id = ', $current_data{'id'},
                    ' AND field = ', $field_id,
                    ' AND language IN ', [ $P{'data_lang'}, q{*} ],
                ],
#                debug => 1,
            );
        }
    }

    # Update child_time in all our parents.
    _update_mtime($P{'parent_id'});

    if (wantarray) {
        return %current_data;
    }

    return \%current_data;
} # }}}

# Purpose:
#   Change content of some selected data fields in the Content entry.
#   Content entry must exist!
#
# Fixme:
#   Take Content Type as input parameter, and check fields!
sub set_fields_data { # {{{
    my %P = validate(
        @_,
        {
            id        => { type=>SCALAR },
            set_data  => { type=>HASHREF },
            data_lang => { type=>SCALAR, optional=>1, default=>$default_data_lang },
        }
    );

    my @fields = keys %{ $P{'set_data'} };

    # Check current state.
    my %current_data;
    my $sth = CoMe::Core::DB::run_query(
        query => ["SELECT field, value FROM ContentEntryData WHERE ContentEntry_id = ", $P{'id'}, ' AND language IN ', [ $P{'data_lang'}, q{*} ], ' AND field IN ', \@fields ],
#        debug => 1,
    );

    while (my ($field, $value) = $sth->fetchrow_array()) {
        $current_data{$field} = $value;
    }

    foreach my $field (@fields) {
        if (defined $current_data{$field}) {
            CoMe::Core::DB::run_query(
                query => ["UPDATE ContentEntryData SET value = ", $P{'set_data'}->{$field}, " WHERE ContentEntry_id = ", $P{'id'}, ' AND field = ', $field ],
#                debug => 1,
            );
        }
        else {
            CoMe::Core::DB::run_query(
                query => ["INSERT INTO ContentEntryData (ContentEntry_id, field, value, language) VALUES ", [ $P{'id'}, $field, $P{'set_data'}->{$field}, $P{'data_lang'} ], ],
#                debug => 1,
            );
        }
    }

    # Update modification time in this entry, and in it's parents.
    _update_mtime($P{'id'});

    Cache_invalidate_referenced($CACHE_NAMESPACE, [$P{'id'}]);

    return;
} # }}}

sub _update_mtime { # {{{
    my ( $update_id ) = @_;

    my $NOW = CoMe::Core::DB::NOW();

    while ($update_id) {
        Cache_invalidate_referenced($CACHE_NAMESPACE, [$update_id]);

        CoMe::Core::DB::run_query(
            query => [ "UPDATE ContentEntry SET `revision` = `revision` + 1, child_time = ", $NOW, " WHERE id = ", $update_id ],
#            debug => 1,
        );

        my $sth = CoMe::Core::DB::run_query(
            query => [ "SELECT ContentEntry_id FROM ContentEntry WHERE id = ", $update_id ],
#            debug => 1,
        );
        ( $update_id ) = $sth->fetchrow_array();
    }
    
    return;
} # }}}

sub get_one { # {{{
    my %P = validate (
        @_,
        {
            id   => { type=>SCALAR, optional=>1 },
            path => { type=>SCALAR, optional=>1 },

            ContentHandler_id => { type=>SCALAR, optional=>1 },

            data_lang => { type=>SCALAR, optional=>1, default=>$default_data_lang },
        }
    );

    # Support for 'path' option.
    if (defined $P{'path'}) {
        $P{'id'} = id_for_path($P{'path'});

        # Bail out ASAP, if non-existing ID was give.
        if (not $P{'id'}) {
            return;
        }
    }

    my $cache_key = q{single-} . $P{'id'} .q{-}. $P{'data_lang'};

    my $cached_data = Cache_get($CACHE_NAMESPACE, $cache_key, [ $P{'id'} ]);

    if ($cached_data and _revision($P{'id'}) == $cached_data->[0]->{'revision'}) {
        if ($cached_data->[0] and $P{'ContentHandler_id'} and $cached_data->[0]->{'ContentHandler_id'} != $P{'ContentHandler_id'}) {
            # Maybe We should die, or something?
            carp ( sprintf "Expected and actual ContentType_ differ: %d vs %d!", $cached_data->[0]->{'ContentHandler_id'}, $P{'ContentHandler_id'} );

            return;
        }

        if (wantarray) {
            return %{ $cached_data->[0] };
        }
        else {
            return $cached_data->[0];
        }
    }

    my $entries = _fetch_entries_by_id( [ $P{'id'} ], $P{'data_lang'}, $cache_key );

    if (not $entries) {
        return;
    }

    if ($entries->[0] and $P{'ContentHandler_id'} and $entries->[0]->{'ContentHandler_id'} != $P{'ContentHandler_id'}) {
        # Maybe We should die, or something?
        carp ( sprintf "Expected and actual ContentType_ differ: %d vs %d!", $entries->[0]->{'ContentHandler_id'}, $P{'ContentHandler_id'} );

        return;
    }

    if (wantarray) {
        return %{ $entries->[0] };
    }

    return $entries->[0];
} # }}}

sub get_list { # {{{
    my %P = validate (
        @_,
        {
            ContentHandler_id => { type=>SCALAR },

            id   => { type=>SCALAR, optional=>1 },
            path => { type=>SCALAR, optional=>1 },

            data_lang => { type=>SCALAR, optional=>1, default=>$default_data_lang },
        }
    );

    my $id = $P{'id'};

    if ($P{'path'} and $P{'path'} eq q{/}) {
        # Special case - root elements!
        $id = 0;
    }
    elsif (defined $P{'path'}) {
        $id = id_for_path($P{'path'});
    }
    
    my $id_to_revision = _early_entry_fetch(
        [
            'ContentEntry_id = ', $id,
            ' AND ContentHandler_id = ', $P{'ContentHandler_id'},
        ]
    );

    my $list_key = CoMe::Core::Cache::Util::id_to_rev_string($id_to_revision, $P{'data_lang'});

    my $cached_list = Cache_get($CACHE_NAMESPACE, $list_key);
    if ($cached_list) {
        if (wantarray) {
            return @{ $cached_list };
        }

        return $cached_list;
    }

    return _fetch_entries_by_id( [ keys %{ $id_to_revision } ], $P{'data_lang'}, $list_key );
} # }}}

# Get number of childrens of given ids.
sub get_counts { # {{{
    my %P = validate (
        @_,
        {
            ContentHandler_id => { type=>SCALAR, optional=>1 },

            ids  => { type=>ARRAYREF },
        }
    );

    my @query = (
        "SELECT COUNT(*), ContentEntry_id FROM ContentEntry WHERE ContentEntry_id IN ", $P{'ids'}
    );
    if ($P{'ContentHandler_id'}) {
        push @query, " AND ContentHandler_id = ", $P{'ContentHandler_id'};
    }
    push @query, " GROUP BY ContentEntry_id";

    my $sth = CoMe::Core::DB::run_query(
        query => \@query,
#        debug => 1
    );

    my %counts;
    while (my ($count, $id) = $sth->fetchrow_array()) {
        $counts{$id} = $count;
    }

    return \%counts;
} # }}}

sub del { # {{{
    my %P = validate (
        @_,
        {
            id => { type=>SCALAR | ARRAYREF },
        }
    );

    my $sth;

    # Support for SCALAR | ARRAYREF thing...
    if (not ref $P{'id'}) {
        $P{'id'} = [ $P{'id'} ];
    }

#    warn "Before: ". (join ", ", @{ $P{'id'} });

    # Delete Childs as well.
    my @last_ids = @{ $P{'id'} };
    while (scalar @last_ids) {
        $sth = CoMe::Core::DB::run_query(
            query => [ "SELECT id FROM ContentEntry WHERE ContentEntry_id IN ", \@last_ids ]
        );

        @last_ids = ();
        while (my ($child_id) = $sth->fetchrow_array()) {
            push @last_ids, $child_id;
        }
        
        push @{ $P{'id'} }, @last_ids;
    }

#    warn "Before: ". (join ", ", @{ $P{'id'} });

    # Delete Attachments.
    CoMe::Core::Attachment::del_by_object(
        parent  => 'content',
        object  => $P{'id'},
    );

    # Delete Comments.
    CoMe::Core::Comment::del_by_object(
        handler => 'Content',
        object  => $P{'id'}
    );

    # Now, main data can be deleted.
    CoMe::Core::DB::run_delete(
        from  => 'ContentEntryData',
        where => [
            'ContentEntry_id IN ', $P{'id'}
        ],
#        debug => 1,
    );
    CoMe::Core::DB::run_delete(
        from  => 'ContentEntry',
        where => [
            'id IN ', $P{'id'}
        ]
    );

    return 1;
} # }}}

sub set_status { # {{{
    my %P = validate(
        @_,
        {
            id     => { type=>SCALAR },
            status => { type=>SCALAR, regex=>qr{^visible|hidden$}s }, ## no critic qw(ProhibitPunctuationVars)
        }
    );

    CoMe::Core::DB::run_update(
        table => 'ContentEntry',
        set   => {
            status => $P{'status'},
        },
        where => [
            'id = ', $P{'id'}
        ]
    );

    return $P{'status'};
} # }}}

sub search { # {{{
    my %P = validate (
        @_,
        {
            metadata => { type=>HASHREF, optional=>1 },
            data     => { type=>HASHREF, optional=>1 },
            match    => { type=>SCALAR, optional=>1, default=>'equal', },

            data_lang => { type=>SCALAR, optional=>1, default=>$default_data_lang },

            ids_only => { type=>BOOLEAN, optional=>1, default=>0 },
        }
    );

    # Each ID must e matched by ALL searches.
    my %entries;
    my $matches_level = 0;
    if ($P{'metadata'}) {
        $matches_level++;
    }
    if ($P{'data'}) {
        $matches_level += scalar keys %{ $P{'data'} };
    }

    my $match_operator = q{=};
    if ($P{'match'} eq 'like') {
        $match_operator = q{LIKE};
    }

    # Search in metadata.
    if ($P{'metadata'}) {
        my %field_swap = (
            'parent_id' => 'ContentEntry_id'
        );

        my @where;
        my $where_prefix = q{};

        foreach my $field (qw{ id parent_id ContentType_id path status template }) {
            if (exists $P{'metadata'}->{$field}) {
                my $db_name = ( $field_swap{$field} or $field );
    
                push @where, $where_prefix . $db_name . q{ }. $match_operator .q{ };
                push @where, $P{'metadata'}->{$field};

                $where_prefix = q{ AND };
            }

#            use Data::Dumper; warn Dumper \@where;
        }

        if (scalar @where) {
            my $sth = CoMe::Core::DB::run_select(
                columns => [qw{ id }],
                from    => 'ContentEntry',
                where   => \@where,
#                debug   => 1,
            );
            while (my ($id) = $sth->fetchrow_array()) {
                $entries{$id}++;
            }
        }
    }

    # Search in data
    if ($P{'data'}) {
        foreach my $field (keys %{ $P{'data'} }) {
            my $sth = CoMe::Core::DB::run_select(
                distinct => 1,
                columns  => [qw{ ContentEntry_id }],
                from     => 'ContentEntryData',
                where    => [
                    ' field = ', $field,
                    ' AND language IN ', [ $P{'data_lang'}, q{*} ],
                    ' AND value '. $match_operator .q{ }, $P{'data'}->{$field},
                ],
#                debug => 1,
            );
            while (my ($id) = $sth->fetchrow_array()) {
                $entries{$id}++;
            }
        }
    }

#    use Data::Dumper; warn "Entries found, for level $matches_level: ". Dumper \%entries;
#    use Data::Dumper; warn "Query was: ". Dumper \%P;

    if ($P{'ids_only'}) {
        my @ids;

        foreach my $id (keys %entries) {
            if ($entries{$id} == $matches_level) {
                push @ids, $id;
            }
        }

        return \@ids;
    }

    # When get_list is implemented natively, this code can be replaced with call for a list.
    my @ids_to_fetch;
    foreach my $id (keys %entries) {
        if ($entries{$id} == $matches_level) {
            push @ids_to_fetch, $id;
        }
    }

    return _fetch_entries_by_id( \@ids_to_fetch, $P{'data_lang'} );
} # }}}

# Using full-blown cache would add too much overhead, making it useless.
# Fully-local, hash-based cache is the only way to boost this.
my %path_to_id_cache = ();

sub id_for_path { # {{{
    my ( $path ) = @_;

#    warn "ID for path: ". $path;

    # Remove last "/".
    if ($path eq q{/}) {
        return 0;
    }
    else {
        $path =~ s{/$}{}s;
    }

    confess_on_false( scalar ($path =~ m{^(/[^/]+)+$}s), "Path is invalid!" );

    if ($path_to_id_cache{$path}) {
        return $path_to_id_cache{$path};
    }

    my $id = 0;

    my @path_parts = split /\//s, $path;
    shift @path_parts;

#    use Data::Dumper; warn 'Path parted: '. Dumper \@path_parts;

    foreach my $part (@path_parts) {
        my $sth = CoMe::Core::DB::run_select(
            columns => [qw{ id }],
            from    => 'ContentEntry',
            where   => [
                'ContentEntry_id = ', $id,
                ' AND path = ', $part,
            ],
#           debug => 1,
        );

        ($id) = $sth->fetchrow_array();

#        warn "Part: $part ($id)";

        if (not $id) {
            return $path_to_id_cache{$path} = undef;
        }
    }

#    warn "ID for '$path' is: $id";

    return $path_to_id_cache{$path} = $id;
} # }}}

sub path_for_id { # {{{
    my ( $id ) = @_;

    confess_on_false(scalar ($id =~ m{^\d+$}s), "Id: '$id' is not numeric!");
    
    my ($path, $part) = (q{}, q{});

    while ($id) {
        my $sth = CoMe::Core::DB::run_select(
            columns => [qw{ ContentEntry_id path }],
            from    => 'ContentEntry',
            where   => [
                'id = ', $id,
            ],
#            debug => 1,
        );

        ($id, $part) = $sth->fetchrow_array();

        if ($part) {
            $path = q{/} . $part . $path;
        }
    }

    if ($path) {
        return $path .q{/};
    }

    return q{};
} # }}}

# Utility subroutines.

# Handy subroutine, that helps with sorting lists of Content datas.
# It supports sorting between different ContentTypes, thus it needs two pairs of arguments:
#   ContentHash A
#   ContentType A
#   ContentHash B
#   ContentType B
sub sort_callback { # {{{
    my ( $data_a, $type_a, $data_b, $type_b ) = @_;

    my $value_a = $data_a->{'data'}->{ $type_a->{'role'}->{'sort'} };
    my $value_b = $data_b->{'data'}->{ $type_b->{'role'}->{'sort'} };

    if ($value_a =~ m/^\d+$/s and $value_b =~ m/^\d+$/s) {
        return $value_a <=> $value_b;
    }

    return $value_a cmp $value_b;
} # }}}

# Purpose:
#   Make and return map:
#       user login -> number of content items He owns
#   for given list of users.
#   
#   If some users from the list do not own any item, their login will not appear in the map.
#
# Fixme:
#   cover in native test!
sub get_owned_counts_by_login { # {{{
    my %P = @_;
    validate(
        @_,
        {
            logins => { type=>ARRAYREF },
        }
    );

    my $sth = CoMe::Core::DB::run_query(
        query => [q{SELECT login, COUNT(*) FROM ContentEntry LEFT JOIN EmailMeta ON EmailMeta.id = ContentEntry.EmailMeta_id LEFT JOIN UserMeta ON UserMeta.id = EmailMeta.UserMeta_id WHERE login IN }, $P{'logins'}, q{ GROUP BY login} ],
#        debug => 1,
    );
    my %map;
    while (my ($login, $count) = $sth->fetchrow_array()) {
        $map{$login} = $count;
    }

    return \%map;
} # }}}

# Private subroutines.

sub _revision { # {{{
    my ( $id ) = @_;

    my $sth = CoMe::Core::DB::run_query(
        query => ['SELECT revision FROM ContentEntry WHERE id = ', $id],
#        debug => 1,
    );
    my ($revision) = $sth->fetchrow_array();

    return $revision;
} # }}}

# Purpose:
#   Assist in Content entry retrieval, by preparing map of id-revision.
#   This map is intended to be used as a referemce, to check if data retrieved
#   from Cache is still valid.
sub _early_entry_fetch { # {{{
    my ( $where ) = @_;

    my $sth = CoMe::Core::DB::run_select(
        columns => [qw( id revision )],
        from    => 'ContentEntry',
        where   => $where,
#        debug => 1
    );
    my %id_to_rev;
    while (my ($id, $revision) = $sth->fetchrow_array()) {
        $id_to_rev{$id} = $revision;
    }

    return \%id_to_rev;
} # }}}

# Purpose:
#   Fetch entries with given IDs, and store the answer in Cache,
#   under given key.
sub _fetch_entries_by_id { # {{{
    my ( $ids, $data_lang, $cache_key ) = @_;

    my %entries;

    my $sth = CoMe::Core::DB::run_select(
        columns => [qw( id ContentEntry_id ContentHandler_id ContentType_id EmailMeta_id path status template comments added_time modified_time child_time revision )],
        from    => 'ContentEntry',
        where   => [ 'id IN ', $ids ],
#        debug => 1
    );
    while ( my $entry = $sth->fetchrow_hashref ) {
        $entry->{'parent_id'} = delete $entry->{'ContentEntry_id'};

        # Append information about the User, who made the comment.
        ( $entry->{'email'}, $entry->{'user'} ) = CoMe::Core::Email::get_by_id($entry->{'EmailMeta_id'});

        # Put into the pool.
        $entries{ $entry->{'id'} } = $entry;
    }

    # Quit at this point, if there ware are no entries fetched.
    if (not scalar keys %entries) {
        return;
    }

    # If there was at lease one entry, fetch it's data.
    my $data_sth = CoMe::Core::DB::run_select(
        columns => [qw{ ContentEntry_id value field }],
        from    => 'ContentEntryData',
        where   => [
            'ContentEntry_id IN ', [ keys %entries ],
            ' AND language IN ', [ $data_lang, q{*} ],
        ],
#        debug => 1,
    );
    while (my ($id, $value, $field) = $data_sth->fetchrow_array()) {
        $entries{$id}->{'data'}->{$field} = $value;
    }

    if ($cache_key) {
        Cache_put($CACHE_NAMESPACE, $cache_key, [ values %entries ], $ids);
    }

    if (wantarray) {
        return values %entries;
    }

    return [ values %entries ];
} # }}}

# vim: fdm=marker
1;
