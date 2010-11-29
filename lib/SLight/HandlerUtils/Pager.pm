package SLight::HandlerUtils::Pager;
################################################################################
# 
# SLight - Lightweight Content Management System.
#
# Copyright (C) 2010 Bartłomiej /Natanael/ Syguła
#
# This is free software.
# It is licensed, and can be distributed under the same terms as Perl itself.
#
# More information on: http://slight-cms.org/
# 
################################################################################
use strict; use warnings; use utf8; # {{{
use SLight::Core::L10N qw( TR TF );

use Params::Validate qw( :all );
# }}}

# Purpose:
#   Prepare pager :)
#   SLight generates pagers as a list of actions, for example:
#   
#   [ First ] [ Previous ] [ ..5 ] [ 6 ] [ 7 ] [ 8 ] [ 9 ] [ 10 ] [ 11.. ] [ Next ] [ Last ]
#
#   First / Last page buttons:
#       They move You to the first/last page in the list, instantly.
#       They appear only, when first/last page is not included in the visible list of pages.
#
#   Previous / next page buttons:
#       They always point to page number +1 or -1 relative to current one.
#       Class: Previous_Page / Next_Page
#
#   Page buttons:
#       No more then seven of them.
#       If the first/last pages in the list are not first/last in the pager, they will have the '..' added to them.
#       Current page gets the class 'Page_Current', others get 'Page_Before' and 'Page_After', respectively.
#
#   Only elements that are needed, are added.
#
#   First element in the pager gets the class 'First', last gets 'Last', extra,
#   just in case, You would like them to have rounded corners, or such stuff :)
#
#   Here is how the pager looks for pages:
#    1) 1 2 3 4 5 6 7 N L
#    2) P 1 2 3 4 5 6 7 N L
#    3) P 1 2 3 4 5 6 7 N L
#    4) P 1 2 3 4 5 6 7 N L
#    5) F P 2 3 4 5 6 7 8 N L
#    6) F P 3 4 5 6 7 8 9 N L
#    7) F P 4 5 6 7 8 9 10 N L
#    8) F P 5 6 7 8 9 10 11 N
#    9) F P 5 6 7 8 9 10 11 N
#   10) F P 5 6 7 8 9 10 11 N
#   11) F P 5 6 7 8 9 10 11
sub make_pager { # {{{
    my ( $self, $pager_meta ) = @_;

    # If there is only one page - skip the whole thing.
    if ($pager_meta->{'pages_count'} == 1) {
        return;
    }

    my @pager_elements;
    
    if ($pager_meta->{'current_page'} > 4) {
        # Add 'First' action.
        push @pager_elements, $self->{'response'}->make_Action(
            caption => TR('First#page'),
            class   => 'First_Page',
            href    => $self->_url(1),
        );
    }

    if ($pager_meta->{'current_page'} > 1) {
        # Add 'Previous' action.
        push @pager_elements, $self->{'response'}->make_Action(
            caption => TR('Previous#page'),
            class   => 'Previous_Page',
            href    => $self->_url($pager_meta->{'current_page'} - 1),
        );
    }
    
    # Add page links.

    # Define which pages will be visible (pager will display no more then 7 of them)
    my ( $first_visible_page, $last_visible_page) = __compute_bounds($pager_meta);

    foreach my $page ($first_visible_page .. $last_visible_page) {
        my $class = 'Page_Current';
        if ($page < $pager_meta->{'current_page'}) {
            $class = 'Page_Before';
        }
        elsif ($page > $pager_meta->{'current_page'}) {
            $class = 'Page_After';
        }

        my $caption = $page;

        push @pager_elements, $self->{'response'}->make_Action(
            caption => $caption,
            class   => $class,
            href    => $self->_url($page),
        );
    }

    if ($pager_meta->{'current_page'} < $pager_meta->{'pages_count'}) {
        # Add the 'Next' action.
        push @pager_elements, $self->{'response'}->make_Action(
            caption => TR('Next#page'),
            class   => 'Next_Page',
            href    => $self->_url($pager_meta->{'current_page'} + 1),
        );
    }

    if ($pager_meta->{'current_page'} < $pager_meta->{'pages_count'} - 3) {
        # Add the 'Last' action.
        push @pager_elements, $self->{'response'}->make_Action(
            caption => TR('Last#page'),
            class   => 'Last_Page',
            href    => $self->_url($pager_meta->{'pages_count'}),
        );
    }

    # Mark first and last elements in the pager with 'extra' classes.

    # Make and return container for the widget.
    my $pager_container = $self->{'response'}->make_Container(
        class   => 'SLight_Pager',
        content => \@pager_elements,
    );

    return $pager_container;
} # }}}

sub _url { # {{{
    my ( $self, $page ) = @_;

    return SLight::Core::URL::make_url( %{ $self->{'url'} }, page => $page );
} # }}}
    
# Private subroutines

# Purpose:
#   Compute first and last visible page, for current pager.
sub __compute_bounds { # {{{
    my ( $pager_meta ) = @_;

    my ( $first_visible_page, $last_visible_page);
    
    if ($pager_meta->{'current_page'} <= 4) {
        $first_visible_page = 1;

        if ($pager_meta->{'pages_count'} > 7) {
            $last_visible_page = 7;
        }
        else {
            $last_visible_page = $pager_meta->{'pages_count'};
        }
    }
    elsif ($pager_meta->{'current_page'} > $pager_meta->{'pages_count'} - 3) {
        $last_visible_page = $pager_meta->{'pages_count'};

        if ($pager_meta->{'pages_count'} > 7) {
            $first_visible_page = $pager_meta->{'pages_count'} - 6;
        }
        else {
            $first_visible_page = 1;
        }
    }
    else {
        if ($pager_meta->{'current_page'} - 3 >= 1) {
            $first_visible_page = $pager_meta->{'current_page'} - 3;
        }
        else {
            $first_visible_page = 1;
        }

        if ($pager_meta->{'current_page'} + 3 <= $pager_meta->{'pages_count'}) {
            $last_visible_page  = $pager_meta->{'current_page'} + 3;
        }
        else {
            $last_visible_page  = $pager_meta->{'pages_count'};
        }
    }

    return ( $first_visible_page, $last_visible_page);
} # }}}

# vim: fdm=marker
1;
