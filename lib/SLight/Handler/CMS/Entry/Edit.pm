package SLight::Handler::CMS::Entry::Edit;
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
use base q{SLight::HandlerBase::ContentEntryForm};

use SLight::API::Content qw( get_Content update_Content );
use SLight::API::ContentSpec qw( get_ContentSpecs_where get_ContentSpec );
use SLight::API::Page;
use SLight::DataStructure::List::Table;
use SLight::DataStructure::Form;
use SLight::Core::L10N qw( TR );
use SLight::DataToken qw( mk_Label_token mk_Link_token );

use Carp;
use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $content = get_Content($oid);

    my $content_spec = get_ContentSpec($content->{'Content_Spec_id'});

    my $form = SLight::DataStructure::Form->new(
        submit => TR('Update'),
        action => $self->build_url(
            step => 'save',
        ),
        hidden => {}
    );

    $self->build_form_guts(
        form    => $form,
        spec    => $content_spec,
        errors  => {},
        content => $content,
    );

    $self->push_data($form);

    return;
} # }}}

sub handle_save { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $content = get_Content($oid);

    my $content_spec = get_ContentSpec($content->{'Content_Spec_id'});

    # Get the data, that User sent us.
    my ( $errors, $warnings, $data, $attachments ) = $self->slurp_content_form_data(
        content      => $content,
        content_spec => $content_spec,
    );

    if (keys %{ $errors }) {
        # Re-display the form.
    
        my $form = SLight::DataStructure::Form->new(
            submit => TR('Update'),
            action => $self->build_url(
                step => 'save',
            ),
            hidden => {}
        );

        use Data::Dumper; warn Dumper $errors;

        $self->build_form_guts(
            form    => $form,
            spec    => $content_spec,
            errors  => {},
            content => $content,
        );

        $self->push_data($form);

        return;
    }

    my $page_id = $self->{'page'}->{'page_id'};

#    use Data::Dumper; warn Dumper $self->{'page'};

    my %content = (
        id => $content->{'id'},

        _data => $data,

        comment_write_policy => $self->{'options'}->{'meta.comment_write_policy'},
        comment_read_policy  => $self->{'options'}->{'meta.comment_read_policy'},
    );

    update_Content(%content);

    $self->process_field_attachments(
        id          => $content->{'id'},
        attachments => $attachments,
    );

    my %target_url = (
        add_domain => 1,

        action => 'View',
        step   => 'view',
    );

    $self->redirect( $self->build_url(%target_url) );

    return;
} # }}}

# vim: fdm=marker
1;
