package SLight::Handler::CMS::Entry::AddContent;
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

use SLight::API::Content qw( add_Content get_Content_ids_where );
use SLight::API::ContentSpec qw( get_ContentSpecs_where get_ContentSpec );
use SLight::API::Page;
use SLight::DataStructure::List::Table;
use SLight::DataStructure::Form;
use SLight::Core::L10N qw( TR );
use SLight::DataToken qw( mk_Label_token mk_Link_token );
use SLight::HandlerMetaFactory;

use Carp;
use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('AddContent');

    assert_defined($self->{'page'}->{'page_id'}, 'ID (in page) defined');

    my $specs = get_ContentSpecs_where(
        cms_usage     => [1, 2, 3],
        owning_module => 'CMS::Entry',
    );

    if (not scalar @{ $specs }) {
        # FIXME!
        # tell User, that there are no usable Content types, and how He can add them.
        return;
    }

    my $table = SLight::DataStructure::List::Table->new(
        columns => [
            {
                caption => TR('Name'),
                class   => 'main_name',
                name    => 'label',
            },
            {
                caption => TR('Handler'),
                class   => 'name',
                name    => 'owning_module',
            },
            {
                caption => q{},
                class   => 'link',
                name    => 'as_page_link',
            },
            {
                caption => q{},
                class   => 'link',
                name    => 'append_link',
            },
        ],
    );

    $table->add_Row(
        data => {
            label => TR('Empty space'),

            owning_module => q{Core::Empty},

            as_page_link => [
                mk_Link_token(
                    text => TR('As new page'),
                    href => $self->build_url(
                        step    => 'form',
                        options => {
                            target  => q{New},
                            handler => q{CMS::Entry},
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
                            handler => q{CMS::Entry},
                        },
                    ),
                )
            ]
        },
    );

    foreach my $list_type (qw( Headlines News Blog Gallery Aggregator )) {
        # Hard-coded "for now" (FIXME!)
        $table->add_Row(
            data => {
                label => TR(q{List: } . $list_type),

                owning_module => q{List::} . $list_type,

                as_page_link => [
                    mk_Link_token(
                        text => TR('As new page'),
                        href => $self->build_url(
                            step    => 'form',
                            options => {
                                target  => 'New',
                                handler => q{List::} . $list_type,
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
                                handler => q{List::} . $list_type,
                            },
                        ),
                    )
                ]
            },
        );
    }

    foreach my $spec (@{ $specs }) {
        # Hard-coded "for now" (FIXME!)
        $table->add_Row(
            data => {
                label => TR("Content") .q{: }. $spec->{'caption'},

                owning_module => $spec->{'owning_module'},

                as_page_link => [
                    mk_Link_token(
                        text => TR('As new page'),
                        href => $self->build_url(
                            step    => 'form',
                            options => {
                                target  => 'New',
                                handler => q{CMS::Entry},
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
                                target  => 'Current',
                                handler => q{CMS::Entry},
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

    $self->set_class('AddContent');

    my $meta_handler = $self->_meta_handler($self->{'options'}->{'handler'});

    my $content_spec = $meta_handler->get_spec($self->{'options'}->{'spec_id'});

    my $form = SLight::DataStructure::Form->new(
        submit => TR('Add'),
        action => $self->build_url(
            step => 'save',
        ),
        hidden => {
            target  => $self->{'options'}->{'target'},
            handler => $self->{'options'}->{'handler'},
            spec_id => ( $self->{'options'}->{'spec_id'} or q{} ),
        }
    );

    $self->build_form_guts(
        form    => $form,
        spec    => $content_spec,
        errors  => {},
    );

    $self->push_data($form);

    return;
} # }}}

sub handle_save { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('AddContent');

    my $meta_handler = $self->_meta_handler($self->{'options'}->{'handler'});

    my $content_spec = $meta_handler->get_spec($self->{'options'}->{'spec_id'}, 1);

    # Get the data, that User sent us.
    my ( $errors, $warnings, $data, $assets ) = $self->slurp_content_form_data(
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
            path => ( $self->{'options'}->{'page.path'} or q{} ),
        );

        if ($self->{'options'}->{'page.template'}) {
            $page{'template'} = $self->{'options'}->{'page.template'};
        }

#        use Data::Dumper; die Dumper($self->{'page'});

        if ($self->{'page'}->{'page_id'}) {
            $page{'parent_id'} = $self->{'page'}->{'page_id'};
        }
        else {
            $page{'parent_id'} = undef;
        }

#        use Data::Dumper; die Dumper(\%page);

        $page_id = SLight::API::Page::add_Page(%page);
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
        # Check, if there is already some content, and - adjust the index respectively.
        my $content_ids = get_Content_ids_where(
            Page_Entity_id => $page_id,
        );

        $content{'on_page_index'} = scalar @{ $content_ids } + 1;
    }

    my $content_id = add_Content(%content);

    $self->process_field_assets(
        id     => $content_id,
        assets => $assets,
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

sub _meta_handler { # {{{
    my ( $self, $class ) = @_;

    my $factory = SLight::HandlerMetaFactory->new();

    my ( $pkg, $handler ) = split m/::/s, $class;

    my $handlermeta = $factory->make(
        pkg     => $pkg,
        handler => $handler,
    );

    return $handlermeta;
} # }}}

# vim: fdm=marker
1;
