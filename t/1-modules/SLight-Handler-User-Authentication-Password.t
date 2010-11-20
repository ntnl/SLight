#!/usr/bin/perl
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
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use SLight::API::EVK qw( get_EVK );
use SLight::Core::Session;
use SLight::Test::Site;
use SLight::Test::Handler qw( run_handler_tests );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Users'
);

my $step_2_cgi = {};
my $step_3_cgi = {};

# Sending REAL emails in automated tests does not seem to be smart ;)
SLight::Core::Email::debug_disable_sending();

my @tests = (
    {
        'name' => q{Display password recovery form},
        'url'  => q{/_Authentication/Password.web},
    },
    {
        'name' => q{Submit password recovery form},
        'url'  => q{/_Authentication/Password-request.web},
        'cgi'  => {
            'login' => q{nataly},
            'email' => q{natka@test.test},
        }
    },
    {
        'name'     => q{Check: Verification email was sent},
        'callback' => sub {
            return $SLight::Core::Email::_unsent_stack[0]->{'Parts'};
        },
        expect => 'arrayref',
    },
    {
        'name'     => q{Check: EVK was set-up.},
        'callback' => sub {
            my $evk = get_EVK(1);

            $step_2_cgi->{'key'}   = $evk->{'key'};
            $step_2_cgi->{'login'} = $evk->{'metadata'}->{'login'};

            return $evk;
        },
    },
    {
        'name' => q{Display request confirmation page},
        'url'  => q{/_Authentication/Password-requested.web},
    },
    {
        'name' => q{Display new password form},
        'url'  => q{/_Authentication/Password-entry.web},
        'cgi'  => $step_2_cgi,
    },
    {
        'name'      => 'Check: password before changed',
        'sql_query' => [ 'SELECT * FROM User_Entity WHERE id = 4' ],
    },
    {
        'name' => q{Submit password change form},
        'url'  => q{/_Authentication/Password-change.web},
        'cgi'  => $step_3_cgi,

        'call_before' => sub {
            
            $step_3_cgi->{'key'}   = $step_2_cgi->{'key'};
            $step_3_cgi->{'login'} = $step_2_cgi->{'login'};

            $step_3_cgi->{'pass'}        = q{!@45&*};
            $step_3_cgi->{'pass-repeat'} = q{!@45&*};
        }
    },
    {
        'name'      => 'Check: password is changed',
        'sql_query' => [ 'SELECT * FROM User_Entity WHERE id = 4' ],
    },
);

run_handler_tests(
    tests => \@tests,
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
