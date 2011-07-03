package SLight::Handler::List::Aggregator::View;
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

    $self->set_class('SL_List_Aggregator');

#    use Data::Dumper; warn Dumper $self;

    # Get stuff 'bellow' this object in page structure.
    my $sub_pages = get_Page_fields_where(
        _fields => [qw( path )],

        parent_id => $self->{'page'}->{'page_id'},
    );

#    use Data::Dumper; warn Dumper $sub_pages;

    my $contents = get_Contents_fields_where(
        _fields => [qw( Page.id Data Spec.id added_time modified_time )],

        Page_Entity_id => [ map { $_->{'id'} } @{ $sub_pages } ],

        on_page_index => 0,
    );
    my %content_hash = map { $_->{'Page.id'} => $_ } @{ $contents };

#    use Data::Dumper; warn Dumper \%content_hash;

    my @objects;

    # FIXME: sorting is lame...
    foreach my $page (sort { $a->{'path'} cmp $b->{'path'} } @{ $sub_pages }) {
        my $content_object = ( $content_hash{ $page->{'id'} } or {} );

        my @parts;

        push @parts, mk_Link_token(
            text  => $page->{'path'},
            class => q{SL_Title},
            href  => $self->build_url(
                add_to_path => [ $page->{'path'} ],
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

                    if (not $field->{'display_on_list'}) {
                        return;
                    }

                    return 1;
                },
            );
        }

        push @parts, mk_Link_token(
            text  => TR("Read more..."), # FIXME: Replace with text from property.
            class => q{SL_More},
            href  => $self->build_url(
                add_to_path => [ $page->{'path'} ],
            ),
        );

        push @objects, mk_Container_token(
            class   => 'SL_Aggregator_Entry',
            content => \@parts,
        );
    }

    my $container = SLight::DataStructure::Token->new(
        class => q{SL_List_Aggregator},
        token => \@objects,
    );

    $self->push_data($container);

    return;
} # }}}


# vim: fdm=marker
1;
