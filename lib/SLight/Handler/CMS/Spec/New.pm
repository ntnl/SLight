package SLight::Handler::CMS::Spec::New;
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
use base q{SLight::HandlerBase::SimpleForm};

use SLight::API::ContentSpec qw( add_ContentSpec );
use SLight::Core::L10N qw( TR );
use SLight::DataStructure::Form;
use SLight::DataToken qw( mk_Label_token );

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_meta_field('title', TR(q{New content spec}));
    
    my $form = SLight::DataStructure::Form->new(
        action => $self->build_url(
            action => 'New',
            path   => [
                'Spec'
            ],
        ),
        hidden => {},
        submit => TR('Add'),
    );

    return $form;
} # }}}

sub handle_save { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $redirect;

    return $redirect;
} # }}}

# vim: fdm=marker
1;
