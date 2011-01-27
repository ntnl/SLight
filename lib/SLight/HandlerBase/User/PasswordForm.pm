package SLight::HandlerBase::User::PasswordForm;
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
use SLight::Core::L10N qw( TR );
use SLight::Validator qw( validate_input );
# }}}

sub password_form { # {{{
    my ( $self, $admin, $errors ) = @_;
    
    my $form = SLight::DataStructure::Form->new(
        hidden => {},
        submit => TR('Update'),
        action => $self->build_url(
            step => 'save',
        ),
    );

    $form->add_PasswordEntry(
        caption => TR('Password') . q{:},
        name    => 'pass',
        value   => q{},
        error   => $errors->{'pass'},
    );
    $form->add_PasswordEntry(
        caption => TR('Password (repeat)') . q{:},
        name    => 'pass-repeat',
        value   => q{},
        error   => q{},
    );

    $self->push_data($form);

    return;
} # }}}

sub validate_form { # {{{
    my ( $self, $new ) = @_;

    my %meta = (
        'pass' => { type => 'Password', max_length => 128, extras=>{ 'pass-repeat'=>$self->{'options'}->{'pass-repeat'} } },
    );

    return validate_input(
        $self->{'options'},
        \%meta,
    );
} # }}}

# vim: fdm=marker
1;
