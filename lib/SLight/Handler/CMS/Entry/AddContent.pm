package SLight::Handler::CMS::Entry::AddContent;
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

use SLight::API::Content qw( add_Content );
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

    assert_defined($self->{'page'}->{'page_id'}, 'ID (in page) defined');

    my $specs = get_ContentSpecs_where(
        cms_usage => [1, 2, 3],
    );

    if (not scalar @{ $specs }) {
        # FIXME!
        # tell User, that there are no usable Content types, and how He can add them.
        return;
    }

    my $table = SLight::DataStructure::List::Table->new(
        columns => [
            {
                class => 'data',
                name => 'label',
            },
            {
                class => 'data',
                name => 'as_page_link',
            },
            {
                class => 'data',
                name => 'append_link',
            },
        ]
    );

    foreach my $spec (@{ $specs }) {
        # Hardcoded for now (FIXME!)
        $table->add_Row(
            class => 'default',
            data => {
                label => $spec->{'caption'},

                as_page_link => [
                    mk_Link_token(
                        text => TR('As new page'),
                        href => $self->build_url(
                            step    => 'form',
                            options => {
                                target  => 'New',
                                spec_id => $spec->{'id'},
                            },
                        ),
                    ),
                ],
                append_link => [
                    mk_Link_token(
                        text => TR('Append here'),
                        href => $self->build_url(
                            step    => 'form',
                            options => {
                                target => 'Current',
                                spec_id => $spec->{'id'},
                            },
                        ),
                    )
                ]
            },
        );
    }

    $self->push_data($table);

    return;
} # }}}

sub handle_form { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $spec = get_ContentSpec($self->{'options'}->{'spec_id'});

    my $form = SLight::DataStructure::Form->new(
        submit => TR('Add'),
        action => $self->build_url(
            step => 'save',
        ),
        hidden => {
            target  => $self->{'options'}->{'target'},
            spec_id => $self->{'options'}->{'spec_id'},
        }
    );

    $self->build_form_guts(
        form    => $form,
        spec    => $spec,
        errors  => {},
    );

    $self->push_data($form);

    return;
} # }}}

sub handle_save { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $content_spec = get_ContentSpec($self->{'options'}->{'spec_id'});

    # Get the data, that User sent us.
    my ( $errors, $warnings, $data, $attachments ) = $self->slurp_content_form_data(
        content_spec => $content_spec,
    );

    if (keys %{ $errors }) {
        # Re-display the form.
    
        my $form = SLight::DataStructure::Form->new(
            submit => TR('Add'),
            action => $self->build_url(
                step => 'save',
            ),
            hidden => {
                target  => $self->{'options'}->{'target'},
                spec_id => $self->{'options'}->{'spec_id'},
            }
        );

        $self->build_form_guts(
            form    => $form,
            spec    => $content_spec,
            errors  => $errors,
            content => {},
        );

        $self->push_data($form);

        return;
    }

    my $page_id;
    if ($self->{'options'}->{'target'} eq 'New') {
        my %page = (
            path => $self->{'options'}->{'page.path'},
        );

        if ($self->{'options'}->{'template'}) {
            $page{'template'} = $self->{'options'}->{'page.template'};
        }

        if ($self->{'page'}->{'page_id'}) {
            $page{'parent_id'} = $self->{'page'}->{'page_id'};
        }

        $page_id = SLight::API::Page::add_page(%page);
    }
    else {
        $page_id = $self->{'page'}->{'page_id'};
    }

#    use Data::Dumper; warn Dumper $self->{'page'};

    my %content = (
        Page_Entity_id => $page_id,

        Content_Spec_id => $self->{'options'}->{'spec_id'},

        status => q{V},

        _data => $data,

        comment_write_policy => $self->{'options'}->{'meta.comment_write_policy'},
        comment_read_policy  => $self->{'options'}->{'meta.comment_read_policy'},
    );

    if ($self->{'options'}->{'target'} eq 'New') {
        $content{'on_page_index'} = 0;
    }
    else {
        $content{'on_page_index'} = 1; # At the moment, it will just put the 'aux' content in the back.
    }

    my $content_id = add_Content(%content);

    $self->process_field_attachments(
        id          => $content_id,
        attachments => $attachments,
    );

    my %target_url = (
        add_domain => 1,

        action => 'View',
        step   => 'view',
    );
    if ($self->{'options'}->{'target'} eq 'New') {
        $target_url{add_to_path} = [
            $self->{'options'}->{'page.path'}
        ];
    }

    $self->redirect( $self->build_url(%target_url) );

    return;
} # }}}

# vim: fdm=marker
1;
