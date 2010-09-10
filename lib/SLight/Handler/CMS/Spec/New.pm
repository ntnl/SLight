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
use SLight::DataStructure::Redirect;
use SLight::DataToken qw( mk_Label_token );
use SLight::Validator qw( validate_input );

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    $self->set_meta_field('title', TR(q{New content Spec}));

    my $form = SLight::DataStructure::Form->new(
        action => $self->build_url(
            action => 'New',
            path   => [
                'Spec'
            ],
            step => 'save'
        ),
        hidden => {},
        submit => TR('Add'),
    );

    $form->add_Entry(
        name    => 'caption',
        caption => TR('Caption'),
        value   => q{},
    );

    return $form;
} # }}}

sub handle_save { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $errors = $self->validate_form_input(
        %{ $self->{'options'} }
    );

#    use Data::Dumper; warn 'Options: '. Dumper $self->{'options'};

    my $content_spec_id = add_ContentSpec(
        caption       => $self->{'options'}->{'caption'},
        owning_module => q{CMS::Entry},
    );

    my $redirect = SLight::DataStructure::Redirect->new(
        href => $self->build_url(
            action => 'View',
            path   => [
                'Spec',
                $content_spec_id,
            ],
            step   => 'view'
        ),
        # Some caption/label maybe?
    );

    return $redirect;
} # }}}

sub validate_form_input { # {{{
    my ( $self, %data ) = @_;
    
    my %validator_metadata = (
        'caption'     => { type=>'String' },
    );

    my $errors = validate_input($self->{'params'}->{'options'}, \%validator_metadata);
    if ($errors) {
        return $errors;
    }
} # }}}

# vim: fdm=marker
1;
