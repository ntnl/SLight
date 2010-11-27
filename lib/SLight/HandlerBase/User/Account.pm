package SLight::HandlerBase::User::Account;
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
use SLight::Core::L10N qw( TR );
use SLight::Validator qw( validate_input );
# }}}

sub account_form { # {{{
    my ( $self, $new, $data, $errors ) = @_;

    my $form = SLight::DataStructure::Form->new(
        hidden => {},
        submit => TR('Create'),
        action => $self->build_url(
            step => 'save',
        ),
    );

    if ($new) {
        $form->add_Entry(
            caption => TR('Login') . q{:},
            name    => 'login',
            value   => ( $data->{'login'} or q{} ),
            error   => $errors->{'login'},
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
    }

    $form->add_SelectEntry(
        caption => TR('Status') . q{:},
        name    => 'status',
        value   => ( $data->{'status'} or q{} ),
        options => [
            [
                q{Disabled},
                TR('Disabled'),
            ],
            [
                q{Guest},
                TR('Guest'),
            ],
            [
                q{Enabled},
                TR('Enabled'),
            ],
        ],
        error => $errors->{'status'},
    );
    $form->add_Entry(
        caption => TR('Name') . q{:},
        name    => 'name',
        value   => ( $data->{'name'} or q{} ),
        error   => $errors->{'name'},
    );
    $form->add_Entry(
        caption => TR('Email') . q{:},
        name    => 'email',
        value   => ( $data->{'email'} or q{} ),
        error   => $errors->{'email'},
    );

    $self->push_data($form);

    return;
} # }}}

sub validate_form { # {{{
    my ( $self, $new ) = @_;

    my %meta = (
        email => { type => 'Email',  max_length => 256 },
        name  => { type => 'String', max_length => 64, optional => 1 },
    );

    if ($new) {
        $meta{'login'} = { type => 'NewLogin', max_length => 64 };
        $meta{'pass'}  = { type => 'Password', max_length => 128, extras=>{ 'pass-repeat'=>$self->{'options'}->{'pass-repeat'} } },
    }

    return validate_input(
        $self->{'options'},
        \%meta,
    );
} # }}}

# vim: fdm=marker
1;
