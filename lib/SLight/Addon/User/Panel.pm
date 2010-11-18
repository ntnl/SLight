package SLight::Addon::User::Panel;
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
use base q{SLight::Addon};

use SLight::API::User qw( get_User );
use SLight::Core::L10N qw( TR TF );
use SLight::DataToken qw( mk_Label_token mk_Link_token mk_Image_token mk_Container_token );
use SLight::HandlerUtils::LoginForm;
# }}}

sub _process { # {{{
    my ( $self, %P ) = @_;
    
    my @contents;
    my $message    = q{Not logged-in.};
    my $link_label = q{Login};
    my $link_href  = q{};

    if ($self->{'user'}->{'login'}) {
        my $user = get_User($self->{'user'}->{'id'});

        $message    = TF(q{Logged-in as %s.}, undef, ( $user->{'name'} or $user->{'login'} ) );
        $link_label = q{Logout};

        $link_href = SLight::Core::URL::make_url(
            path_handler => 'Authentication',
            path         => [],

            action => 'Logout',

            lang => ( $self->{'lang'} or q{en} ),
        );
        # Fixme: Add an Avatar!
        push @contents, mk_Label_token(
            text => $message,
        );
        push @contents, mk_Link_token(
            href => $link_href,
            text => $link_label,
        );
    }
    else {
        my $form = SLight::HandlerUtils::LoginForm::build(
            q{/}, # Fixme! Make dynamic!
            {},
            {},
        );
        push @contents, $form->get_data();
    }

#    use Data::Dumper; warn Dumper \@contents;

    my $container = mk_Container_token(
        class   => 'SL_UserPanel_Addon',
        content => \@contents,
    );

    return $container;
} # }}}

# vim: fdm=marker
1;