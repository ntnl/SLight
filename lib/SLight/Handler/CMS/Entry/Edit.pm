package SLight::Handler::CMS::Entry::Edit;
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
use base q{SLight::HandlerBase::ContentEntryForm};

use SLight::API::Content qw( get_Content update_Content );
use SLight::API::ContentSpec qw( get_ContentSpecs_where get_ContentSpec );
use SLight::API::Page qw( get_Page );
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

#    use Data::Dumper; warn "Content ($oid): " . Dumper $content;

    # Is this needed after migration to Accessor?
    my $content_spec = get_ContentSpec($content->{'Spec.id'});

    $self->set_class($content_spec->{'class'});

    return $self->_form($content, $content_spec, {});
} # }}}

sub handle_save { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $content = get_Content($oid);

    my $content_spec = get_ContentSpec($content->{'Spec.id'});

    $self->set_class($content_spec->{'class'});

    # Get the data, that User sent us.
    my ( $errors, $warnings, $data, $assets ) = $self->slurp_content_form_data(
        content      => $content,
        content_spec => $content_spec,
    );

    if (keys %{ $errors }) {
        # Re-display the form.
        return $self->_form($content, $content_spec, $errors);
    }

    my $page_id = $self->{'page'}->{'page_id'};

#    use Data::Dumper; warn Dumper $self->{'page'};

    if ($content->{'on_page_index'} == 0) {
        my %page = (
            id => $page_id,

            template   => $self->{'options'}->{'page.template'},
            menu_order => $self->{'options'}->{'page.order'},

            L10N => {
                $self->{'url'}->{'lang'} => {
                    title      => $self->{'options'}->{'page.title'},
                    breadcrumb => $self->{'options'}->{'page.breadcrumb'},
                    menu       => $self->{'options'}->{'page.menu'},
                },
            },
        );

#        use Data::Dumper; die Dumper(\%page);

        SLight::API::Page::update_Page(%page);
    }

    my %content = (
        id => $oid,

        Data => $data,

        comment_write_policy => $self->{'options'}->{'meta.comment_write_policy'},
        comment_read_policy  => $self->{'options'}->{'meta.comment_read_policy'},
    );

#    use Data::Dumper; die Dumper \%content;
#    use Data::Dumper; warn Dumper \%content;

    update_Content(
        %content,
#        debug => 1,
    );

    $self->process_field_assets(
        id     => $oid,
        assets => $assets,
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

    my %params = (
        form    => $form,
        spec    => $content_spec,
        content => $content,
        errors  => $errors,
    );
    if ($content->{'on_page_index'} == 0) {
        my $page = get_Page($content->{'Page.id'});

        $params{'page'} = $page;
    }

    $self->build_form_guts(%params);

    $self->push_data($form);

    return $form;
} # }}}

# vim: fdm=marker
1;
