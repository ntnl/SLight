package SLight::Handler::User::Authentication::Login;
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

use SLight::API::User qw( check_User_pass get_User );
use SLight::Core::L10N qw( TR TF );
use SLight::Core::Session;
use SLight::HandlerUtils::LoginForm;
# }}}

sub handle_view { # {{{
    my ( $self, $oid, $metadata ) = @_;

    return $self->_form({});
} # }}}

sub handle_authenticate { # {{{
    my ($self, $oid, $metadata ) = @_;
    
#    warn $self->{'options'}->{'user'}, $self->{'options'}->{'pass'};

    my $user_id = check_User_pass($self->{'options'}->{'user'}, $self->{'options'}->{'pass'});

    if (not $user_id) {
        return $self->_form(
            {
                pass => TR(q{Login/Password combination is incorrect.}),
            }
        );
    }

    my $user = get_User($user_id);

    my %user_hash = (
        login => $user->{'login'},
        id    => $user->{'id'},
    );
    SLight::Core::Session::part_set(
        'user',
        \%user_hash
    );

    $self->redirect(
        $self->build_url(
            path_handler => 'Page',
            path         => [],

            action => 'View',
            step   => 'view'
        ),
    );

    return;
} # }}}

sub _form { # {{{
    my ( $self, $errors ) = @_;

    $self->set_class('SL_User_Login');

    my $form = SLight::HandlerUtils::LoginForm::build(
        q{/},
        $self->{'options'},
        $errors,
    );

    return $self->push_data($form);
} # }}}

# vim: fdm=marker
1;
