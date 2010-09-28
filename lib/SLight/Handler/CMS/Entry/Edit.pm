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

    $self->set_class($content_spec->{'class'});

    return $self->_form($content, $content_spec, {});
} # }}}

sub handle_save { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $content = get_Content($oid);

    my $content_spec = get_ContentSpec($content->{'Content_Spec_id'});

    $self->set_class($content_spec->{'class'});

    # Get the data, that User sent us.
    my ( $errors, $warnings, $data, $attachments ) = $self->slurp_content_form_data(
        content      => $content,
        content_spec => $content_spec,
    );

    if (keys %{ $errors }) {
        # Re-display the form.
        return $self->_form($content, $content_spec, $errors);
    }

    my $page_id = $self->{'page'}->{'page_id'};

#    use Data::Dumper; warn Dumper $self->{'page'};

    my %content = (
        id => $oid,

        _data => $data,

        comment_write_policy => $self->{'options'}->{'meta.comment_write_policy'},
        comment_read_policy  => $self->{'options'}->{'meta.comment_read_policy'},
    );

#    use Data::Dumper; die Dumper \%content;
#    use Data::Dumper; warn Dumper \%content;

    update_Content(
        %content,
        debug => 1,
    );

    $self->process_field_attachments(
        id          => $oid,
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

sub _form { # {{{
    my ( $self, $content, $content_spec, $errors ) = @_;

    my %url = (
        step        => 'save',
        add_to_path => [ q{-ob-} . $content->{'id'} ],
    );

    my $form = SLight::DataStructure::Form->new(
        submit => TR('Update'),
        action => $self->build_url(%url),
        hidden => {}
    );

#    use Data::Dumper; warn Dumper $errors;

    $self->build_form_guts(
        form    => $form,
        spec    => $content_spec,
        errors  => {},
        content => $content,
    );

    $self->push_data($form);

    return $form;
} # }}}

# vim: fdm=marker
1;
