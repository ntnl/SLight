package SLight::Handler::List::Gallery::View;
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
use base q{SLight::HandlerBase::List::View};

use SLight::Core::L10N qw( TR TF );
use SLight::API::Page qw( get_Page_fields_where );
use SLight::API::Content qw( get_Contents_fields_where );
use SLight::API::ContentSpec qw( get_ContentSpec );
use SLight::DataToken qw( mk_Link_token mk_Label_token mk_Text_token mk_Container_token );
use SLight::DataStructure::Token;

use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_List_Gallery');

#    use Data::Dumper; warn Dumper $self;

    # Get stuff 'bellow' this object in page structure.
    my $sub_pages = [ sort { ( $b->{'menu_order'} cmp $b->{'menu_order'} ) or ( $a->{'path'} cmp $b->{'path'} ) } @{ get_Page_fields_where(
        _fields => [qw( path )],

        parent_id => $self->{'page'}->{'page_id'},
    ) } ];

    if (not scalar @{ $sub_pages }) {
        return;
    }

    # Note, that item index is numbered from 0
    my $item_index = $self->{'url'}->{'page'} - 1;
    if ($self->{'url'}->{'page'} < 1) {
        $item_index = 1;
    }
    elsif ($self->{'url'}->{'page'} + 1 > scalar @{ $sub_pages }) {
        $item_index = ( scalar @{ $sub_pages } ) - 2;
    }

    my @pages_to_show;
    my @nav_links;

    if ($item_index > 0) {
        # Can show "Previous" link.
        my $page = $sub_pages->[ $item_index - 1 ];

        $page->{'_page'} = $item_index;

        push @pages_to_show, $page;

        if ($item_index > 1) {
            push @nav_links, mk_Link_token(
                text  => TR('Previous'),
                class => q{SL_Nav_Previous},
                href  => $self->build_url(
                    page => $page->{'_page'},
                ),
            );
        }
    }

    # In any case - show the "Current" item.
    my $page = $sub_pages->[ $item_index ];

    $page->{'_page'} = $item_index + 1;

    push @pages_to_show, $page;

    push @nav_links, mk_Link_token(
        text  => TR('Zoom'),
        class => q{SL_Nav_Zoom},
        href  => $self->build_url(
            action => 'Zoom',
            page   => $page->{'_page'},
        ),
    );

    if ($item_index + 1 < scalar @{ $sub_pages }) {
        # Can show "Next" link.
        my $page = $sub_pages->[ $item_index + 1 ];

        $page->{'_page'} = $item_index + 2;

        push @pages_to_show, $page;

        if ($item_index + 2 < scalar @{ $sub_pages }) {
            push @nav_links, mk_Link_token(
                text  => TR('Next'),
                class => q{SL_Nav_Next},
                href  => $self->build_url(
                    page => $item_index + 2,
                ),
            );
        }
    }

#    use Data::Dumper; warn Dumper $sub_pages;

#    use Data::Dumper; warn Dumper \@pages_to_show;

    my $contents = get_Contents_fields_where(
        _fields => [qw( Page.id Data Spec.id added_time modified_time )],

        Page_Entity_id => [ map { $_->{'id'} } @pages_to_show ],

        on_page_index => 0,
    );
    my %content_hash = map { $_->{'Page.id'} => $_ } @{ $contents };

#    use Data::Dumper; warn Dumper \%content_hash;
#    use Data::Dumper; warn Dumper \@pages_to_show;

    my @objects;

    # FIXME: sorting is lame...
    # Generally it sorts alphabetically.
    foreach my $page (@pages_to_show) {
        my $content_object = ( $content_hash{ $page->{'id'} } or {} );

        my @parts;

        push @parts, mk_Link_token(
            text  => $page->{'path'},
            class => q{SL_Title},
            href  => $self->build_url(
                action => 'Zoom',
                page   => $page->{'_page'},
            ),
        );

#        use Data::Dumper;
#        push @parts, mk_Text_token( text => '<pre>'. ( Dumper $content_object ) .'</pre>' );

        if ($content_object->{'id'}) {
            my $content_data = $self->get_l10n_value( $content_object->{'Data'} );

            my $spec = get_ContentSpec($content_object->{'Spec.id'});

#            push @parts, mk_Text_token( text => '<pre>'. ( Dumper $spec ) .'</pre>' );

            push @parts, $self->render_cms_object(
                Content => $content_object,

                Data => $content_data,
                Spec => $spec,

                filter_cb => sub {
                    my ( $field ) = @_;

                    if ($field->{'display_on_page'}) {
                        return 1;
                    }

                    return;
                },
            );
        }

        push @objects, mk_Container_token(
            class   => 'SL_Gallery_Entry',
            content => \@parts,
        );
    }

    # Render buttons...
    push @objects, mk_Container_token(
        class   => 'SL_Gallery_Navigation',
        content => \@nav_links,
    );

    my $container = SLight::DataStructure::Token->new(
        class => q{SL_List_Gallery},
        token => \@objects,
    );

    $self->push_data($container);

    return;
} # }}}

# vim: fdm=marker
1;
