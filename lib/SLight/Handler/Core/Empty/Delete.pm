package SLight::Handler::Core::Empty::Delete;
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
use base q{SLight::Handler};

use SLight::DataStructure::Dialog::YesNo;

use SLight::API::Page;
use SLight::Core::L10N qw( TR TF );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('Empty');

    my $dialog = SLight::DataStructure::Dialog::YesNo->new(
        message => TR("Do you want to delete current page? Please confirm."),

        yes_href => $self->build_url(
            action => 'Delete',
            step   => 'commit',
        ),
        yes_caption => TR("Yes"),

        no_href => $self->build_url(
            action => 'Delete',
            step   => 'view',
        ),
        no_caption => TR("No"),

        class => 'SL_Delete_Dialog',
    );

    $self->push_data($dialog);

    return;
} # }}}

sub handle_commit { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('Empty');

    SLight::API::Page::delete_Page($self->{'page'}->{'page_id'});

    # FIXME: This has to be fixed, so that the User is redirected to parent page, not to root!
    $self->redirect(
        $self->build_url(
            action => 'View',
            step   => 'view',
            path   => [],
        )
    );

    return;
} # }}}

# vim: fdm=marker
1;
