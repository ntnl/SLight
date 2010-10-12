package SLight::Handler::CMS::Entry::Delete;
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
use base q{SLight::HandlerBase::CMS};

use SLight::Core::L10N qw( TR TF );
use SLight::API::Content qw( get_Content );
use SLight::API::ContentSpec qw( get_ContentSpec );
use SLight::DataStructure::Dialog::YesNo;

use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $content = get_Content($oid);

    my $content_spec = get_ContentSpec($content->{'Content_Spec_id'});

    $self->set_class($content_spec->{'class'});

    my $dialog = SLight::DataStructure::Dialog::YesNo->new(
        message => TF("Do you want to delete '%s'? Please confirm.", undef, $content->{'id'}), # FIXME: use title field instead!

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

        class => 'SLight_Delete_Dialog',
    );

    $self->push_data($dialog);

    $self->manage_toolbox($oid);

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
