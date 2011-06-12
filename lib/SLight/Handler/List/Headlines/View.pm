package SLight::Handler::List::Headlines::View;
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
use SLight::DataToken qw( mk_Link_token );
use SLight::DataStructure::Token;

use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_class('SL_List_Headlines');

#    use Data::Dumper; warn Dumper $self;

    # Get stuff 'bellow' this object in page structure.
    my $sub_pages = get_Page_fields_where(
        _fields => [qw( path L10N )],

        parent_id => $self->{'page'}->{'page_id'},
    );

#    use Data::Dumper; warn Dumper $sub_pages;

    my @objects;

    # FIXME: sorting is lame...
    foreach my $page (sort { $a->{'path'} cmp $b->{'path'} } @{ $sub_pages }) {
        my $value = ( $self->get_l10n_value($page->{'L10N'}) or { title=> $page->{'path'} } );

        push @objects, mk_Link_token(
            text  => $value->{'title'},
            class => q{Item},
            href  => $self->build_url(
                add_to_path => [ $page->{'path'} ],
            ),
        );
    }

    my $container = SLight::DataStructure::Token->new(
        class => q{SL_List_Headlines},
        token => \@objects,
    );
    
    $self->push_data($container);

    return;
} # }}}

# vim: fdm=marker
1;
