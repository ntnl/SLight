package SLight::HandlerUtils::LoginForm;
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

    return $form;
} # }}}

# vim: fdm=marker
1;
