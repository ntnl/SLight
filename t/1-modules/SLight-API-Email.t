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

use Test::More;
use FindBin qw( $Bin );
use lib $Bin .q{/../../lib/};

use SLight::Core::Email;
use SLight::Test::Site;

use YAML::Syck qw( Dump );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin .q{/../},
    site     => 'EmailTemplates',
);

use SLight::API::Email;

plan tests =>
    + 1 # send_confirmation
    + 1 # send_registration
    + 1 # send_notification
;

@SLight::Core::Email::_unsent_stack = ();

SLight::API::Email::send_confirmation(
    email             => q{confirmation@email.test},
    name              => q{Fake User},
    confirmation_link => q{http://foo.test/bar/confirm},
);

is(
    $SLight::Core::Email::_unsent_stack[0]->{'Parts'}->[0]->{'Data'},
    "Dear Fake User,\n\nThis is a verification email sent to address: confirmation\@email.test\n\nTo use it in on the site, You have to confirm, that You are it's rightful user,\nby using the following link: http://foo.test/bar/confirm\n\nThank you,\nYour SLight Automated Test.\n\nPS. This message was triggered by an automated test.\nIf You DID received it, please simply ignore.\n",
    "send_confirmation"
);

@SLight::Core::Email::_unsent_stack = ();

SLight::API::Email::send_registration(
    email             => q{registration@email.test},
    domain            => q{foo.test},
    name              => q{Fake User},
    confirmation_link => q{http://foo.test/bar/register},
);

#warn Dump @SLight::Core::Email::_unsent_stack[0]->{'Parts'}->[0];

is(
    $SLight::Core::Email::_unsent_stack[0]->{'Parts'}->[0]->{'Data'},
    "Dear Fake User,\n\nAn account has been registered on foo.test by using the e-mail address registration\@email.test.\n\nPlease validate it by using the following link: http://foo.test/bar/register\n\nThank you,\nYour SLight Automated Test.\n\nPS. This message was triggered by an automated test.\nIf You DID received it, please simply ignore.\n",
    "send_registration"
);

@SLight::Core::Email::_unsent_stack = ();

SLight::API::Email::send_notification(
    email         => q{notification@email.test},
    name          => q{Fake User},
    notifications => [
        q{I am a first notification},
        q{I'm the second},
    ],
);

#warn Dump @SLight::Core::Email::_unsent_stack[0]->{'Parts'}->[0];

is(
    $SLight::Core::Email::_unsent_stack[0]->{'Parts'}->[0]->{'Data'},
    "Dear Fake User,\n\nPlease, be aware of the following events:\n\nI am a first notification\nI'm the second\n\nThank you,\nYour SLight Automated Test.\n\nPS. This message was triggered by an automated test.\nIf You DID received it, please simply ignore.\n\nPS2. This email template suits as UTF-8 characters (example: \xC4\x85\xC4\x87\xC4\x99\xC3\xB3\xC5\x82\xC5\x84\xC5\xBC\xC5\xBA) test too :)\n",
    "send_notification"
);

# vim: fdm=marker
