package SLight::HandlerUtils::LoginForm;
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
use SLight::Core::URL;
use SLight::Core::L10N qw( TR TF );
# }}}

sub build { # {{{
    my ( $origin, $options, $errors ) = @_;

    my $form = SLight::DataStructure::Form->new(
        class  => 'SL_Login_Form',
        action => SLight::Core::URL::make_url(
            path_handler => q{Authentication},
            path         => [],

            action => 'Login',
            step   => 'authenticate',
        ),
        hidden => {
            origin => $origin,
        },
        submit => TR('Login'),
    );

    $form->add_Entry(
        name    => 'user',
        caption => TR('Login'),
        value   => ( $options->{'user'} or q{} ),
        error   => ( $errors->{'user'} ),
    );
    $form->add_PasswordEntry(
        name    => 'pass',
        caption => TR('Password'),
        value   => q{},
        error   => ( $errors->{'pass'} ),
    );

    $form->add_Link(
        href  => q{/_Authentication/Register.web},
        text  => TR("Register account..."),
        class => 'SL_Register_Action',
    );
    $form->add_Link(
        href  => q{/_Authentication/Register.web},
        text  => TR("Forgot password?"),
        class => 'SL_Password_Action',
    );

    return $form;
} # }}}

# vim: fdm=marker
1;
