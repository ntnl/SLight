package SLight::HandlerBase::SimpleForm;
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

use SLight::DataStructure::Form;
use SLight::DataStructure::Redirect;
use SLight::DataToken qw( mk_Label_token );
use SLight::Validator qw( validate_input );
use SLight::Core::L10N qw( TR );

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

# Purpose:
#   This module can be used as a base for all simple
#   (like: property+value) kinds of forms.

sub handle_view { # {{{
    my ( $self, $oid, $metadata, $errors ) = @_;

    my $form_spec = $self->form_spec($oid, $metadata);

    # TODO: validate if given spec makes any sense...

    $self->set_meta_field('title', $form_spec->{'title'});

    my $form = SLight::DataStructure::Form->new(
        action => $form_spec->{'action'},
        hidden => {},
        submit => $form_spec->{'submit'},
    );

    $self->make_form(
        $oid,
        $metadata,
        $form,
        ( $errors or {} )
    );

    return $self->push_data($form);
} # }}}

sub handle_save { # {{{
    my ( $self, $oid, $metadata ) = @_;

    my $form_spec = $self->form_spec($oid, $metadata);

    my $errors = validate_input(
        $self->{'options'},
        $form_spec->{'validator_metadata'},
    );

#    use Data::Dumper; warn 'Errors: '. Dumper $errors;

    if ($errors) {
        return $self->handle_view($oid, $metadata, $errors);
    }

#    use Data::Dumper; warn 'Options: '. Dumper $self->{'options'};

    my $redirect_url = $self->save_form($oid, $metadata);

#    my $redirect = SLight::DataStructure::Redirect->new( # FIXME: Deprecate SLight::DataStructure::Redirect !!!
#        href => $redirect_url,
#        # Some caption/label maybe?
#    );

    return $self->redirect($redirect_url);
} # }}}

# vim: fdm=marker
1;
