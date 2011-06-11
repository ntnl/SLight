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

my %display_methods = (
    'Label' => 'display_Label',
    'Text'  => 'display_Text',
    'Link'  => 'display_Link',
    'Email' => 'display_Email',
);

# Turn Content Data (content_hash + content_type), into something usefull.

# Prepare detailed view of a Content element.
sub ContentData_2_details { # {{{
    my ( $self, $content, $content_spec ) = @_;

    my $item_path = get_Page_full_path($content->{'Page.id'});

    my @container_contents = $self->display_ContentData_for_page(
        $content, $content_spec,
        $item_path,
        0,            # thumb mode OFF
    );

#    use Data::Dumper; warn Dumper \@container_contents;

    # Display detailed information about assets.
    my $asset_ids = get_Asset_ids_on_Content($content->{'id'});
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

        push @container_contents, $assets_list;
    }

#    # Display number of comments.
#    my $comments_count = SLight::Core::Comment::get_count(
#        handler => [ 'Content' ],
#        object  => [ $ContentData->{'content_hash'}->{'id'} ],
#    );
#    if ($comments_count) {
#        my $value = mk_Label_token(
#            class => 'SLight_Comments',
#            text  => TF('Comments: %d', undef, $comments_count),
#        );
#        push @container_contents, $value;
#    }

    # Add timebox.
    push @container_contents, $self->make_timebox($content);

    my $container = mk_Container_token(
        class   => 'Core',
        content => \@container_contents,
    );

    return $container;
} # }}}

sub display_ContentData_for_page { # {{{
    my ( $self, $content, $content_spec, $item_path, $thumb_mode ) = @_;

#    use Data::Dumper; warn Dumper $content, $content_spec;

    my @container_contents;

    my @langs = (
        $self->{'url'}->{'lang'},
        ( keys %{ $content->{'Data'} } ),
        q{*}
    );

#    use Data::Dumper; warn q{\@langs : }. Dumper \@langs;

    foreach my $field_name (@{ $content_spec->{'_data_order'} }) {
        my $field = $content_spec->{'_data'}->{$field_name};

        if (not $field->{'display_on_page'}) {
            next;
        }
        # Fixme: there should be an 'IF' what dictates, if it should be full, or just a summary.

        my $signature = ( $signatures_cache{ $field->{'datatype'} } or $signatures_cache{ $field->{'datatype'} } = SLight::DataType::signature(type=>$field->{'datatype'}) );

        my @inner_container_content;

        if ($field->{'display_label'} == 0 or $field->{'display_label'} == 2) {
            # Add label if 0 (always) or 2 (only pages)
            my $label = mk_Label_token(
                class => q{L-} . $field_name.' Label',
                text  => ( $field->{'caption'} or q{} ),
            );

            push @inner_container_content, $label;
        }

        if ($signature->{'asset'}) {
            my $value = $self->render_asset_field( $field, $content, $item_path, $thumb_mode );

            if (defined $value) {
                push @inner_container_content, $value;
            }
        }
        else {
#            use Data::Dumper; warn q{$content->{'Data'} : }. Dumper $content->{'Data'};

            # I think, that there is a better way to do this. Will refactor this, when the whole thing works. (small fixme)
            foreach my $field_lang ( @langs ) {
#                warn q{ lang / ID: } . $field_lang . q{ / } . $field->{'id'};

                if (defined $content->{'Data'}->{$field_lang}->{ $field->{'id'} }) {
                    my $value = SLight::DataType::decode_data(
                        type   => $field->{'datatype'},
                        value  => $content->{'Data'}->{$field_lang}->{ $field->{'id'} }->{'value'},
                        format => q{},
                        target => 'MAIN',
                    );

                    my $display_method_name = $display_methods{$signature->{'display'}};
                    assert_defined($display_method_name, q{Display method for '}. $signature->{'display'} .q{' is implemented});
                    $value = $self->$display_method_name($field_name, $value);

                    push @inner_container_content, $value;

                    last;
                }
            }
        }

        if (scalar @inner_container_content == 1) {
            # Special use case - only the value...
            push @container_contents, $inner_container_content[0];
        }
        elsif (scalar @inner_container_content > 1) {
            # Common use case - two things - must be put into container.
            push @container_contents, mk_Container_token(
                class   => q{C-} . $field_name .q{ Container},
                content => \@inner_container_content,
            );
        }
    }
    
#    use Data::Dumper; warn q{container_contents: }. Dumper \@container_contents;

    return @container_contents;
} # }}}

sub display_Label { # {{{
    my ( $self, $field_name, $value ) = @_;

    return mk_Label_token(
        class => q{V-} . $field_name . q{ Value},
        text  => ( $value or q{} ),
    );
} # }}}

sub display_Text { # {{{
    my ( $self, $field_name, $value ) = @_;

#    use Data::Dumper; warn "Text value: ". Dumper $value;

    return mk_Text_token(
        class => q{V-} . $field_name . q{ Value},
        text  => ( $value or q{} ),
    );
} # }}}

sub display_Link { # {{{
    my ( $self, $field_name, $value ) = @_;

    assert_defined($value, "Value not empty");

    return mk_Link_token(
        class => q{V-} . $field_name . q{ Value},
        text  => $value,
        href  => $value,
    );
} # }}}

sub display_Email { # {{{
    my ( $self, $field_name, $value ) = @_;

    assert_defined($value, "Value may not be empty!");

    return mk_Link_token(
        class => q{V-} . $field_name . q{ Value},
        text  => $value,
        href  => q{mailto:}. $value,
    );
} # }}}

# Note:
#   first textual field will beSLight a link to Overview.
sub ContentData_2_item { # {{{
    my ( $self, $ContentData, $comments_count, $assets_count, $childs_count ) = @_;

    my $item_path = SLight::Core::Content::path_for_id($ContentData->{'content_hash'}->{'id'});

    my @values;

    # Default action is to show the overview of the item - it's summary, and summary of it's childs.
    # But, if there are no childs, it's better to go streight to details.
    # This seems more intuituve.
    my $default_child_action = 'overview';
    if (not $childs_count) {
        $default_child_action = 'details';
    }

    my $overview_url = $self->build_url(
        method  => 'GET',
        handler => 'Content',
        action  => $default_child_action,
        options => {},
        path    => $item_path,
    );

    my $title_field = $ContentData->{'content_type'}->{'role'}->{'title'};
    my $overview_link = mk_Link_token(
        class => 'Title '. $title_field,
        text  => ( $ContentData->{'content_hash'}->{'data'}->{$title_field} or TR("Overview") ),
        href  => $overview_url,
    );
    push @values, $overview_link;

    foreach my $field_name (@{ $ContentData->{'content_type'}->{'fields_order'} }) {
        if ($field_name eq $title_field) {
            # Was already added, as title field, skip.
            next;
        }

        my $field = $ContentData->{'content_type'}->{'fields'}->{$field_name};

        # Skip fields, that have 'display' set to 2 (only pages) or 3 (only edit)
        if ($field->{'display'} == 2 or $field->{'display'} == 3) {
            next;
        }

        my $signature = ( $signatures_cache{ $field->{'datatype'} } or $signatures_cache{ $field->{'datatype'} } = SLight::DataType::signature(type=>$field->{'datatype'}) );

        # Currently labels, but in future, maybe other widgets.

        my $value;
        if ($signature->{'asset'}) {
            $value = $self->render_asset_field( $field_name, $ContentData, $item_path, 1 );
        }
        elsif ($ContentData->{'content_hash'}->{'data'}->{$field_name})  {
            my $text = SLight::DataType::decode_data(
                type   => $field->{'datatype'},
                value  => $ContentData->{'content_hash'}->{'data'}->{$field_name},
                format => q{},
                target => 'LIST',
            );

            my $display_method_name = $display_methods{$signature->{'display'}};
            confess_on_false($display_method_name, q{Display method for '}. $signature->{'display'} .q{' unknown!});
            $value = $self->$display_method_name($field_name, $text);
        }

        if (defined $value) {
            # Should we add a label to it?
            if ($field->{'use_label'} == 0 or $field->{'use_label'} == 2) {
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
    if ($assets_count) {
        my $value = mk_Label_token(
            class => 'SLight_Assets',
            text  => TF('Assets: %d', undef, $assets_count),
        );
        push @values, $value,
    }

    # Display number of comments.
    if ($comments_count) {
        my $value = mk_Label_token(
            class => 'SLight_Comments',
            text  => TF('Comments: %d', undef, $comments_count),
        );
        push @values, $value,
    }

    # Add timebox.
    push @values, $self->make_timebox($ContentData->{'content_hash'});

    # Add toolbox, so actions can be used easily.
    my $toolbox = $self->make_toolbox(
        actions => [qw{ details add edit translate delete attach }],
        pkg     => 'Content',
        handler => 'Content',
        path    => $item_path,
    );
    if ($toolbox) {
        push @values, $toolbox,
    }

    my $ListItem = mk_ListItem_token(
        class   => 'item',
        content => \@values,
    );

    return $ListItem;
} # }}}

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

# Return 'SLight_Timebox' container.
#
# Timebox displays up to three dates (each with time):
#   added date/time
#   changed date/time, if it's different then added date/time
#   child date/time, if it's different then added date/time
sub make_timebox { # {{{
    my ( $self, $content ) = @_;

    my @dates = (
        mk_Label_token(
            class => 'SLight_AddedTime',
            text  => TF('Added: %s', undef, $content->{'added_time'}),
        )
    );

    if ($content->{'modified_time'} ne $content->{'added_time'}) {
        push @dates, mk_Label_token(
            class => 'SLight_ModifiedTime',
            text  => TF('Modified: %s', undef, $content->{'modified_time'}),
        );
    }

# To be implemented, maybe.
#    if ($content->{'child_time'} ne $content->{'added_time'}) {
#        push @dates, mk_Label_token(
#            class => 'SLight_ChildTime',
#            text  => TF('Changes inside: %s', undef, $content->{'child_time'}),
#        );
#    }

    return mk_Container_token(
        class   => 'SLight_Timebox',
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

# vim: fdm=marker
1;
