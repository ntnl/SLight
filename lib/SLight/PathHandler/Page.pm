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
        my $page = SLight::API::Page::get_page($page_id);

        $self->set_template( ($page->{'template'} or 'Default') );

        # Future: get objects (class + id, with proper order) from Object store
    }
    else {
        # Page not found!
        print STDERR "Page not found!\n";
        $self->set_template('Error');
    }

    return $self->response_content();
} # }}}

# vim: fdm=marker
1;
