package SLight::PathHandler::Page;
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
use base q{SLight::PathHandler};

my $VERSION = '0.0.4';

use SLight::API::Content qw( get_Contents_where get_Contents_fields_where );
use SLight::API::ContentSpec qw( get_ContentSpec );
use SLight::API::Page qw( get_Page_id_for_path );
use SLight::DataType;

use Carp::Assert::More qw( assert_defined );
# }}}

=over

=item get_path_target ( $self, $path )

Return HASHREF with I<Object Handler> (C<handler>) and I<Object ID> (C<id>).

Initial purpose of this function was to translate path to Class/ID,
so this information can be used by Permissions checkers,
to see if the User has access rights to some target pointed by the URL.

TOD: move this comment to PathHandler.pm

=back

=cut

sub get_path_target { # {{{
    my ( $self, $path ) = @_;

    my $page_id = get_Page_id_for_path($path);

    if ($page_id) {
        my $content_objects = get_Contents_fields_where(
            'Page.id' => $page_id,

            on_page_index => 0,

            _fields => [qw( id Spec.owning_module )],
        );

#        use Data::Dumper; warn Dumper $content_objects;

        if ($content_objects and scalar @{ $content_objects } == 1) {
            my $content = $content_objects->[0];

#            use Data::Dumper; warn Dumper $content;

            return {
                handler => $content->{'Spec.owning_module'},
                id      => $content->{'id'},
            };
        }
    }

    return;
} # }}}

sub analyze_path { # {{{
    my ( $self, $path ) = @_;

    assert_defined($path, "Path is defined");

    # There are two use cases: root or non-root.
    my ( $page_id, $aux_object_id );
    my $last_template = 'Default';

    # Check for aux object selector:
    if (scalar @{ $path } and $path->[-1] =~ m{-ob-(\d+)}s) {
        $aux_object_id = $1;

        pop @{ $path };
    }

    if (scalar @{ $path }) {
        ( $page_id, $last_template ) = $self->walk_the_path($path);

        if (not $page_id) {
            return $self->page_does_not_exist();
        }
    }
    else {
        # Page with ID of 1 is the root page.
        # (if this is not the case, it means, that DB is broken)
        $page_id = 1;
    }

#    use Data::Dumper; warn 'breadcrumb_path: '. Dumper \@breadcrumb_path;

#    warn "Path: " . join ", ", @{ $path };
#    warn "ID:   " . $page_id;

    $self->set_page_id($page_id);

    my $page = SLight::API::Page::get_Page($page_id);

#    use Data::Dumper; warn 'Page: '. Dumper $page;

    # If there is no root page, return a nice 'Welcome' message :)
    if ($page_id == 1 and not $page) {
        $self->cms_db_is_empty();

        $self->set_page_id(0);
    }
    elsif ($aux_object_id) {
        $self->setup_aux_object($page_id, $aux_object_id);
    }
    elsif ($page) {
        $self->setup_objects($page_id);
    }
    else {
        # For now, assume the page is empty.
        $self->page_is_empty();

        $self->set_page_id(0);
    }

    $self->set_template( ($page->{'template'} or 'Default') );

    return $self->response_content();
} # }}}

sub cms_db_is_empty { # {{{
    my ( $self ) = @_;

    $self->set_objects(
        {
            e1 => {
                class => 'CMS::Welcome',
                oid   => undef,
            },
        },
    );

    $self->set_object_order([qw( e1 )]);

    $self->set_main_object('e1');

    return;
} # }}}

# Purpose:
#   Descend into the tree, to find the page pointed by path in URL.
sub walk_the_path { # {{{
    my ( $self, $path ) = @_;

    my $parent_id = 1;

    my $last_template = 'Default';

    my ( $page_id, @path_stack, @breadcrumb_path );

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
            # Still, this should end with E404 Page not found.
            return;
        }

        my $page = $pages->[0];

        $parent_id = $page_id = $page_id;

        push @path_stack, $part;

        my @langs = (
            $self->{'url'}->{'lang'},
            ( keys %{ $page->{'L10N'} } ),
            q{*}
        );

        my $path_label = $part;
        foreach my $lang (@langs) {
            if ($page->{'L10N'}->{$lang}) {
                $path_label = $page->{'L10N'}->{$lang}->{'breadcrumb'};
            }
        }

        push @breadcrumb_path, {
            label => $path_label,
            class => 'Test',
            href  => SLight::Core::URL::make_url(
                path => [ @path_stack ],
            ),
        };

        if ($pages->[0]->{'template'}) {
            $last_template = $pages->[0]->{'template'};
        }
    }

    $self->set_breadcrumb_path(\@breadcrumb_path);

    return ( $page_id, $last_template );
} # }}}

sub setup_aux_object { # {{{
    my ( $self, $page_id, $aux_object_id) = @_;
    
    my $objects = get_Contents_fields_where(
        status => [qw( V A ) ],

        id => $aux_object_id,

        Page_Entity_id => $page_id,

        _fields => [qw( id on_page_index Spec.owning_module )],
    );

    if (scalar @{ $objects }) {
        my $entry = $objects->[0];

        $self->set_main_object(q{ob} . $entry->{'id'});

        my $on_page_id = q{ob} . $entry->{'id'};

        $self->set_objects(
            {
                $on_page_id => {
                    oid   => $entry->{'id'},
                    class => $entry->{'Spec.owning_module'},
                }
            }
        );

        $self->set_main_object( $on_page_id );

        $self->set_object_order( [ $on_page_id ] );
    }
    else {
        $self->generic_error_page('NotFound');
    }

    return;
} # }}}

sub setup_objects { # {{{
    my ( $self, $page_id ) = @_;

    my $objects = get_Contents_fields_where(
        status => [qw( V A ) ],

        Page_Entity_id => $page_id,

        _fields => [qw( id on_page_index Spec.owning_module )],
    );

    if (scalar @{ $objects }) {
        my @object_ids;
        my %page_objects;
        my $found_main_object;
        foreach my $entry (sort { ($a->{'on_page_index'} <=> $b->{'on_page_index'}) or ($a->{'id'} <=> $b->{'id'}) } @{ $objects }) {
            if ($entry->{'on_page_index'} == 0 and not $found_main_object) {
                # Checking for 'on_page_index' AND $found_main_object may seem a bit too much.
                # But, let's not forget, that the software HAS to behave EVEN if some "power" user messes up with DB.
                $self->set_main_object(q{ob} . $entry->{'id'});

                $found_main_object = 1;
            }

            $page_objects{ q{ob} . $entry->{'id'} } = {
                oid   => $entry->{'id'},
                class => $entry->{'Spec.owning_module'},
            };

            push @object_ids, q{ob} . $entry->{'id'};
        }

        if (not $found_main_object) {
            # This is not a normal situation, something IS wrong, but... (should this be a fixme?)
            $self->set_main_object( $object_ids[0] );
        }

#        use Data::Dumper; warn 'page objects: '. Dumper \%page_objects;

        $self->set_objects(\%page_objects);

        $self->set_object_order(\@object_ids);
    }
    else {
        $self->page_is_empty();
    }

    return;
} # }}}

# vim: fdm=marker
1;
