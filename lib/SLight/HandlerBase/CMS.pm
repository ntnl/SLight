package SLight::HandlerBase::CMS;
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

use SLight::Core::L10N qw( TR TF );
use SLight::API::ContentSpec qw( get_ContentSpec );
use SLight::API::Page qw( get_Page_full_path );
use SLight::API::Asset qw( get_Asset_ids_on_Content get_Asset_ids_on_Content_Field get_Asset );
use SLight::API::Util qw( human_readable_size );
use SLight::DataToken qw( mk_Link_token mk_Label_token mk_Container_token mk_Text_token mk_ListItem_token mk_Image_token );
use SLight::DataType;

use Carp::Assert::More qw( assert_defined assert_hashref assert_listref );
use Params::Validate qw( :all );
# }}}

my %signatures_cache;

# Turn Content Data (content_hash + content_type), into something useful.

my %render_methods = (
    'Label' => 'render_Label',
    'Text'  => 'render_Text',
    'Link'  => 'render_Link',
    'Email' => 'render_Email',
);

sub render_Label { # {{{
    my ( $self, $field_name, $value ) = @_;

    return mk_Label_token(
        class => q{V-} . $field_name . q{ Value},
        text  => ( $value or q{} ),
    );
} # }}}

sub render_Text { # {{{
    my ( $self, $field_name, $value ) = @_;

#    use Data::Dumper; warn "Text value: ". Dumper $value;

    return mk_Text_token(
        class => q{V-} . $field_name . q{ Value},
        text  => ( $value or q{} ),
    );
} # }}}

sub render_Link { # {{{
    my ( $self, $field_name, $value ) = @_;

    assert_defined($value, "Value not empty");

    return mk_Link_token(
        class => q{V-} . $field_name . q{ Value},
        text  => $value,
        href  => $value,
    );
} # }}}

sub render_Email { # {{{
    my ( $self, $field_name, $value ) = @_;

    assert_defined($value, "Value may not be empty!");

    return mk_Link_token(
        class => q{V-} . $field_name . q{ Value},
        text  => $value,
        href  => q{mailto:}. $value,
    );
} # }}}

sub render_cms_object { # {{{
    my ( $self, %P ) = @_;

    assert_defined($P{'Data'}, 'Data defined'); # The object's data
    assert_defined($P{'Spec'}, 'Spec defined'); # The object's specification

    if (not $P{'filter_cb'}) {
        $P{'filter_cb'} = sub { my ($field) = @_; return 1; }
    }

    my @values;

    foreach my $field_name (@{ $P{'Spec'}->{'_data_order'} }) {
        my $field = $P{'Spec'}->{'_data'}->{$field_name};

        if (not $P{'filter_cb'}->($field)) {
            next;
        }

        my $signature = ( $signatures_cache{ $field->{'datatype'} } or $signatures_cache{ $field->{'datatype'} } = SLight::DataType::signature(type=>$field->{'datatype'}) );

        my $value;
        if ($signature->{'asset'}) {
            $value = $self->render_asset_field( $field_name, $P{'Data'}, 1 );
        }
        elsif ($P{'Data'}->{ $field->{'id'} })  {
            my $text = SLight::DataType::decode_data(
                type   => $field->{'datatype'},
                value  => $P{'Data'}->{ $field->{'id'} }->{'value'},
                format => q{},
                target => 'LIST',
            );

            my $render_method_name = $render_methods{ $signature->{'display'} };

            assert_defined($render_method_name, q{Display method for '}. $signature->{'display'} .q{' unknown!});

            $value = $self->$render_method_name($field_name, $text);
        }

        if (defined $value) {
            # Should we add a label to it?
            if ($field->{'display_label'} == 0 or $field->{'display_label'} == 2) {
                my $label = mk_Label_token(
                    class => 'Label',
                    text  => ( $field->{'caption'} or q{} ),
                );

                push @values, mk_Container_token(
                    class   => $field_name,
                    content => [ $label, $value ],
                );
            }
            else {
                # Just the value...
                push @values, $value;
            }
        }
    }

    # Display count of assets (not including files attached to fields).
    if ($P{'assets_count'}) {
        my $value = mk_Label_token(
            class => 'SL_Assets',
            text  => TF('Assets: %d', undef, $P{'assets_count'}),
        );
        push @values, $value,
    }

    # Display number of comments.
    if ($P{'comments_count'}) {
        my $value = mk_Label_token(
            class => 'SL_Comments',
            text  => TF('Comments: %d', undef, $P{'comments_count'}),
        );
        push @values, $value,
    }

    # Add timebox, bot only if there was anything to show!.
    if (scalar @values) {
        push @values, $self->make_timebox($P{'Content'});
    }

    # Add toolbox, so actions can be used easily.
#    my $toolbox = $self->make_toolbox(
#    );
#    if ($toolbox) {
#        push @values, $toolbox,
#    }

    return @values;
} # }}}

# Prepare detailed view of a Content element.
sub render_cms_page { # {{{
    my ( $self, $Content, $Spec ) = @_;

    my $item_path = get_Page_full_path($Content->{'Page.id'});

    my @container_content = $self->render_cms_object(
        Content => $Content,

        Data => $self->get_l10n_value( $Content->{'Data'} ),
        Spec => $Spec,
    );

#    use Data::Dumper; warn Dumper \@container_content;

    # Display detailed information about assets.
    my $asset_ids = get_Asset_ids_on_Content($Content->{'id'});
    if (scalar @{ $asset_ids }) {
        my $assets_list = get_Assets($asset_ids);

        my @assets_list_contents;
        foreach my $asset_meta (@{ $assets_list }) {
            my $download_link = $self->build_url(
                path_handler => 'Asset',
                path         => [ $asset_meta->{'id'} ],
                action       => 'Download',
            );

            my $hr_size = human_readable_size($asset_meta->{'byte_size'});

            my $item = mk_ListItem_token(
                class   => 'Asset',
                content => [
                    mk_Link_token(
                        text => ( $asset_meta->{'filename'} or TR('Unknown') ),
                        href => $download_link
                    ),
                    mk_Label_token(
                        text  => ( $asset_meta->{'summary'} or q{-} ),
                        class =>'Summary'
                    ),
                    mk_Label_token(
                        text  => $hr_size,
                        class => 'Size'
                    ),
                ],
            );
            push @assets_list_contents, $item;
        }

        my $asset_list = mk_List_token(
            class   => 'Assets',
            content => \@assets_list_contents
        );

        push @container_content, $assets_list;
    }

#    # Display number of comments.
#    my $comments_count = SLight::Core::Comment::get_count(
#        handler => [ 'Content' ],
#        object  => [ $ContentData->{'content_hash'}->{'id'} ],
#    );
#    if ($comments_count) {
#        my $value = mk_Label_token(
#            class => 'SL_Comments',
#            text  => TF('Comments: %d', undef, $comments_count),
#        );
#        push @container_contents, $value;
#    }

    my $container = mk_Container_token(
        class   => 'Core',
        content => \@container_content,
    );

    return $container;
} # }}}

sub render_asset_field { # {{{
    my ( $self, $field, $content, $path, $thumb_mode ) = @_;

    my $value;

    $self->{'can_display_assets'} = 1;
# To be implemented in M4:
#    # Yes, this is suboptimal, but will be a good starting point for refactoring in future.
#    if (not defined $self->{'can_display_assets'}) {
#        my %grant;
#
#        if ($self->{'params'}->{'user'}->{'login'}) {
#            %grant = SLight::Core::User::Access::get_effective_user_access_rights(
#                login   => $self->{'params'}->{'user'}->{'login'},
#                pkg     => 'Content',
#                handler => 'Content',
#                action  => 'Asset',
#            );
#            if (not $grant{'Get'}) {
#                %grant = SLight::Core::User::Access::get_effective_user_access_rights(
#                    login   => q{!known!},
#                    pkg     => 'Content',
#                    handler => 'Content',
#                    action  => 'Asset',
#                );
#            }
#        }
#        else {
#            %grant = SLight::Core::User::Access::get_effective_user_access_rights(
#                login   => q{!guest!},
#                pkg     => 'Content',
#                handler => 'Content',
#                action  => 'Asset',
#            );
#        }
#
#        # We use this:
#        #   $self->{'can_display_assets'}
#        # undefined at start, will beSLight 0 or 1 when first check is performed.
#
#        if ($grant{'Get'}) {
#            $self->{'can_display_assets'} = 1;
#        }
#        else {
#            $self->{'can_display_assets'} = 0;
#        }
#    }

    my $asset_ids = get_Asset_ids_on_Content_Field($content->{'id'}, $field->{'id'});

    if (not scalar @{ $asset_ids }) {
        return;
    }

    my $asset_meta = get_Asset($asset_ids->[0]); # FIXME: display ALL assets (there can be more of them?)

    # Display Assets only, if User is able to download them.
    if ($asset_meta and $self->{'can_display_assets'}) {
        my $thumb_url = $self->build_url(
            path_handler => 'Asset',
            action       => 'Thumb',
            path         => [ 'Asset', $asset_meta->{'id'}, ],
        );

        # Fixme!
        # Hard coded to display images, so do not put anything else there ;)
        $value = mk_Image_token(
            class => 'Asset ' . $field->{'class'},
            href  => $thumb_url,
            label => ( $asset_meta->{'summary'} or $field->{'caption'} ),
        );
    }
    elsif ($asset_meta) {
        # Asset was added, but User does not have grant to see it.
        # In this case - issue an information.
        $self->add_notification(
            id   => 'Content-Assets-Not-Granted',
            type => 'ACCESS',
            text => TR('Assets have not been displayed, due to insufficient access grants.'),
        );
    }
    else {
        return;
    }

    return $value;
} # }}}

# Return 'SL_Timebox' container.
#
# Timebox displays up to three dates (each with time):
#   added date/time
#   changed date/time, if it's different then added date/time
#   child date/time, if it's different then added date/time
sub make_timebox { # {{{
    my ( $self, $Content ) = @_;

    assert_defined($Content->{'added_time'});
    assert_defined($Content->{'modified_time'});

    my @dates = (
        mk_Label_token(
            class => 'SL_AddedTime',
            text  => TF('Added: %s', undef, $Content->{'added_time'}),
        )
    );

    if ($Content->{'modified_time'} ne $Content->{'added_time'}) {
        push @dates, mk_Label_token(
            class => 'SL_ModifiedTime',
            text  => TF('Modified: %s', undef, $Content->{'modified_time'}),
        );
    }

    return mk_Container_token(
        class   => 'SL_Timebox',
        content => \@dates,
    );
} # }}}

# Purpose:
#   Create main toolbox for CMS::Entry-based page.
sub manage_toolbox { # {{{
    my ( $self, $oid ) = @_;

    my @common_toolbox = (
        {
            caption => TR('Edit'),
            action  => 'Edit',
        },
        {
            caption => TR('Delete'),
            action  => 'Delete',
        },
    );
    if ($self->is_main_object()) {
        $self->set_toolbox(
            [
                {
                    caption => TR('Add Content'),
                    action  => 'AddContent',
                },
                @common_toolbox,
            ]
        );
    }
    else {
        $self->push_toolbox(
            urls => \@common_toolbox,

            'add_to_path' => [ q{-ob-} . $oid ],
        );
    }

    return;
} # }}}

# # # Probably obsolete: # # #

# Very big warning:
#   This function uses Pager in quite un-optimal way.
#   Refactoring is recommended at first occasion!
sub ContentList_2_list { # {{{
    my ( $self, $ContentList, $page ) = @_;

    confess_on_false($page, "Parameter: 'page' must be grater then zero!");

    # Prepare data needed for Pager to work.
    my @entry_ids;
    my %entry_pool;
    foreach my $ContentData (sort { SLight::Core::Content::sort_callback($a->{'content_hash'}, $a->{'content_type'}, $b->{'content_hash'}, $b->{'content_type'}) } @{ $ContentList }) {
        my $id = $ContentData->{'content_hash'}->{'id'};

        push @entry_ids, $id;

        $entry_pool{$id} = $ContentData;
    }

    my $pager = SLight::Pager::SortedIds->new(
        page_size => 10,

        skeleton => \@entry_ids,

        fetch_callback => sub {
            my ( $ids ) = @_;

            # Fetch counts of comments and assets for ids on the list.
            my $comments_per_item = SLight::Core::Comment::get_counts_per_object(
                handler => [ 'Content' ],
                object  => $ids,
            );
            my $assets_per_item = SLight::API::Asset::get_counts_per_object(
                parent => 'content',
                object => $ids,
            );
            my $childs_per_item = SLight::Core::Content::get_counts(
                ids => $ids,
            );
  
            # Process the list, display items along with additional info related to them.
            my @list_items;
            foreach my $entry_id (@{ $ids }) {
                my $ContentData = $entry_pool{$entry_id};
  
                push @list_items, $self->ContentData_2_item(
                    $ContentData,
                    ( $comments_per_item->{$entry_id}    or 0),
                    ( $assets_per_item->{$entry_id} or 0),
                    ( $childs_per_item->{$entry_id}      or 0)
                );
            }

            return \@list_items;
        },
    );

    my $items = $pager->get_page($page);

    $self->set_pager($pager->pager_plugin_meta_data()); 

    return mk_List_token(
        class   => 'content',
        content => $items,
    );
} # }}}

# vim: fdm=marker
1;
