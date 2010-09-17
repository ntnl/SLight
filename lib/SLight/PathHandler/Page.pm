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
    my $page_id;
    my $last_template = 'Default';
    if (scalar @{ $path }) {
        my $parent_id = 1;
        foreach my $part (@{ $path }) {
            my $pages = SLight::API::Page::get_page_fields_where(
                parent_id => $parent_id,
                path      => $part,

                _fields => [qw( id template )],
            );

            if (not $pages->[0]) {
                last;
            }

            $parent_id = $page_id = $pages->[0]->{'id'};

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

    if ($page_id) {
        $self->set_page_id($page_id);

        my $page = SLight::API::Page::get_page($page_id);

        # If there is no root page, return a nice 'Welcome' message :)
        if ($page_id == 1 and not $page) {
            $self->cms_db_id_empty();
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
                foreach my $entry (sort { $a->{'on_page_index'} <=> $a->{'on_page_index'} } @{ $objects }) {
                    if ($entry->{'on_page_index'} == 0) {
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
                    $self->set_main_object( $object_ids[0]->['id']);
                }

                $self->set_objects(\%page_objects);

                $self->set_object_order(\@object_ids);
            }
            else {
                $self->page_is_empty();
            }
        }
        else {
            # Todo: get actual objects...
            # For now, assume the page is empty.
            $self->page_is_empty();
        }

        $self->set_template( ($page->{'template'} or 'Default') );
    }
    else {
        # Page not found!
        print STDERR "Page not found!\n";
        $self->set_template('Error');
    }

    return $self->response_content();
} # }}}

sub cms_db_id_empty { # {{{
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

# vim: fdm=marker
1;
