package SLight::PathHandler::Page;
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
use base q{SLight::PathHandler};

my $VERSION = '0.0.1';

use SLight::API::Content qw( get_Contents_where );
use SLight::API::ContentSpec qw( get_ContentSpec );
use SLight::API::Page;

use Carp::Assert::More qw( assert_defined );
# }}}

sub analyze_path { # {{{
    my ( $self, $path ) = @_;

    assert_defined($path, "Path is defined");

    # There are two use cases: root or non-root.
    my ( $page_id, $aux_object_id );
    my $last_template = 'Default';
    my @breadcrumb_path;
    my @path_stack;

    # Check for aux object selector:
    if (scalar @{ $path } and $path->[-1] =~ m{-ob-(\d+)}) {
        $aux_object_id = $1;

        pop @{ $path };
    }

    if (scalar @{ $path }) {
        # Descend into the tree, to find the page pointed by path in URL.
        my $parent_id = 1;
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
                last;
            }

            $parent_id = $page_id = $pages->[0]->{'id'};

            push @path_stack, $part;

            my $path_label = $part;
            my $content_objects = get_Contents_where(
                Page_Entity_id => $page_id,
                on_page_index  => 0,
            );
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
                                $path_label = $content_objects->[0]->{'_data'}->{$lang}->{ $content_spec->{'use_in_path'} };
                                last;
                            }
                        }
                    }
                    elsif ($content_objects->[0]->{ $content_spec->{'use_in_path'} }) {
                        $path_label = $content_objects->[0]->{ $content_spec->{'use_in_path'} };
                    }
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
    }
    else {
        # Page with ID of 1 is the root page.
        # (if this is not the case, it means, that DB is broken)
        $page_id = 1;
    }

    if (not $page_id) {
        return $self->page_not_found();
    }

    $self->set_breadcrumb_path(\@breadcrumb_path);

#    use Data::Dumper; warn 'breadcrumb_path: '. Dumper \@breadcrumb_path;
#    warn $page_id;

    $self->set_page_id($page_id);

    my $page = SLight::API::Page::get_Page($page_id);

    # If there is no root page, return a nice 'Welcome' message :)
    if ($page_id == 1 and not $page) {
        $self->cms_db_is_empty();
    }
    elsif ($aux_object_id) {
        my $objects = get_Contents_where(
            status => [qw( V A ) ],

            id => $aux_object_id,

            Page_Entity_id => $page_id
        );

        if (scalar @{ $objects }) {
            my $entry = $objects->[0];

            $self->set_main_object(q{ob} . $entry->{'id'});

            my $content_spec = get_ContentSpec($entry->{'Content_Spec_id'});

            my $on_page_id = q{ob} . $entry->{'id'};

            $self->set_objects(
                {
                    $on_page_id => {
                        oid   => $entry->{'id'},
                        class => $content_spec->{'owning_module'},
                    }
                }
            );

            $self->set_main_object( $on_page_id );

            $self->set_object_order( [ $on_page_id ] );
        }
        else {
            $self->page_not_found();
        }
    }
    elsif ($page) {
        my $objects = get_Contents_where(
            status => [qw( V A ) ],

            Page_Entity_id => $page_id
        );

        if (scalar @{ $objects }) {
            my @object_ids;
            my %page_objects;
            my $found_main_object;
            foreach my $entry (sort {  ($a->{'on_page_index'} <=> $b->{'on_page_index'}) or ($a->{'id'} <=> $b->{'id'}) } @{ $objects }) {
                if ($entry->{'on_page_index'} == 0 and not $found_main_object) {
                    # Checking for 'on_page_index' AND $found_main_object may seem a bit too much.
                    # But, let's not forget, that the software HAS to behave EVEN if some "power" user messes up with DB.
                    $self->set_main_object(q{ob} . $entry->{'id'});

                    $found_main_object = 1;
                }

                my $content_spec = get_ContentSpec($entry->{'Content_Spec_id'});

                $page_objects{ q{ob} . $entry->{'id'} } = {
                    oid   => $entry->{'id'},
                    class => $content_spec->{'owning_module'},
                };

                push @object_ids, q{ob} . $entry->{'id'};
            }

            if (not $found_main_object) {
                # This is not a normal situation, something IS wrong, but... (should this be a fixme?)
                $self->set_main_object( $object_ids[0]->['id'] );
            }

#            use Data::Dumper; warn 'page objects: '. Dumper \%page_objects;

            $self->set_objects(\%page_objects);

            $self->set_object_order(\@object_ids);
        }
        else {
            $self->page_is_empty();
        }
    }
    else {
        # For now, assume the page is empty.
        $self->page_is_empty();
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

sub page_is_empty { # {{{
    my ( $self ) = @_;

    $self->set_objects(
        {
            e1 => {
                class    => 'Core::Empty',
                oid      => undef,
            },
        },
    );

    $self->set_object_order([qw( e1 )]);

    $self->set_main_object('e1');

    return;
} # }}}

sub page_not_found { # {{{
    my ( $self ) = @_;

    $self->set_objects(
        {
            e1 => {
                class    => 'Error::NotFound',
                oid      => undef,
            },
        },
    );

    $self->set_object_order([qw( e1 )]);

    $self->set_main_object('e1');

    return;
} # }}}

# vim: fdm=marker
1;
