package SLight::Handler::List::Blog::View;
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

use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_List_Blog');

#    use Data::Dumper; warn Dumper $self;

    # Get stuff 'bellow' this object in page structure.
    my $sub_pages = get_Page_fields_where(
        _fields => [qw( path )],

        parent_id => $self->{'page'}->{'page_id'},
    );

#    use Data::Dumper; warn Dumper $sub_pages;

    my $contents = get_Contents_fields_where(
        _fields => [qw( Page_Entity_id use_as_title )],

        Page_Entity_id => [ map { $_->{'id'} } @{ $sub_pages } ],
    );
    my %content_hash = map { $_->{'Page_Entity_id'} => $_ } @{ $contents };

#    use Data::Dumper; warn Dumper \%content_hash;

    my @objects;

    # FIXME: sorting is lame...
    foreach my $page (sort { $a->{'path'} cmp $b->{'path'} } @{ $sub_pages }) {
        my $content_object = ( $content_hash{ $page->{'id'} } or {} );

        push @objects, mk_Link_token(
            text  => $page->{'path'},
            class => q{Item},
            href  => $self->build_url(
                add_to_path => [ $page->{'path'} ],
            ),
        );
    }

    my $container = SLight::DataStructure::Token->new(
        class => q{SL_List_Blog},
        token => \@objects,
    );
    
    $self->push_data($container);

    return;
} # }}}

# vim: fdm=marker
1;
