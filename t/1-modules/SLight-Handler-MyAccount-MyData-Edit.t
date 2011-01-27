#!/usr/bin/perl
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
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use SLight::API::EVK qw( get_EVK );
use SLight::Test::Site;
use SLight::Test::Handler qw( run_handler_tests );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

# Sending REAL emails in automated tests does not seem to be smart ;)
SLight::Core::Email::debug_disable_sending();

my $ev_cgi = {};

my @tests = (
    {
        'name'    => q{Open My Data form},
        'url'     => q{/_MyAccount/MyData/Edit.web},
        'session' => {
            user => {
                id    => 1,
                login => 'aga',
            },
        },
    },
    {
        'name' => q{Send My Data form (bad input)},
        'url'  => q{/_MyAccount/MyData/Edit-update.web},
        'cgi'  => {
            name  => q{1234567890qwertyuiopasdfghjklzxcvbnm1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik9ol0p},
            email => q{sweet @_@ stuff},
        },
    },
    {
        'name' => q{Send My Data form (good input)},
        'url'  => q{/_MyAccount/MyData/Edit-update.web},
        'cgi'  => {
            name  => q{Agnieszka Testowa},
            email => q{agnieszka@agnieszka.test},
        },
    },
    {
        'name'     => q{Check: Verification email was sent},
        'callback' => sub {
            return $SLight::Core::Email::_unsent_stack[0]->{'Parts'};
        },
        expect => 'arrayref',
    },
    {
        'name'    => q{Email information page},
        'url'     => q{/_MyAccount/MyData/Edit-emailinfo.web},
    },
    {
        'name' => q{Email verification},
        'url'  => q{/_MyAccount/MyData/Edit-emailcheck.web},
        'cgi'  => $ev_cgi,

        'call_before' => sub {
            my $evk = get_EVK(1);

            $ev_cgi->{'email'} = $evk->{'email'};
            $ev_cgi->{'key'}   = $evk->{'key'};

            return $evk;
        },
    },
    {
        'name'    => q{Email verified},
        'url'     => q{/_MyAccount/MyData/Edit-emailchanged.web},
    },
);

run_handler_tests(
    tests => \@tests,
    
#    strip_dates => 1,

    skip_permissions => 1,
);

package Data::UUID;
my $ct = 0;

no warnings;

sub to_string { # {{{
    $ct++;

# Some valid UUIDs:
#    4162F712-1DD2-11B2-B17E-C09EFE1DC403
#    2BC9E9A0-F3E7-11DF-91F2-D6145CFB52DF

    my $fake_id = uc sprintf q{%08x-%04x-%04x-%04x-%012x}, 333*$ct, 22*$ct, $ct, 22*$ct, 4444*$ct;

    return $fake_id;
} # }}}

# vim: fdm=marker
