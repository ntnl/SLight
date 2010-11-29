package SLight::Test::Site::EmailTemplates;
################################################################################
# 
# SLight - Lightweight Content Management System.
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

# }}}

# This module creates an empty site installation.

sub build { # {{{

    SLight::Test::Site::Builder::make_email(
        'confirmation',
        qq{Dear ~~name~~,\n}.
        qq{\n}.
        qq{This is a verification email sent to address: ~~email~~\n}.
        qq{\n}.
        qq{To use it in on the site, You have to confirm, that You are it's rightful user,\n}.
        qq{by using the following link: ~~confirmation_link~~\n}.
        qq{\n}.
        qq{Thank you,\n}.
        qq{Your SLight Automated Test.\n}.
        qq{\n}.
        qq{PS. This message was triggered by an automated test.\n}.
        qq{If You DID received it, please simply ignore.\n}
    );

    SLight::Test::Site::Builder::make_email(
        'notification',
        qq{Dear ~~name~~,\n}.
        qq{\n}.
        qq{Please, be aware of the following events:\n}.
        qq{\n}.
        qq{~~notifications~~\n}.
        qq{\n}.
        qq{Thank you,\n}.
        qq{Your SLight Automated Test.\n}.
        qq{\n}.
        qq{PS. This message was triggered by an automated test.\n}.
        qq{If You DID received it, please simply ignore.\n}.
        qq{\n}.
        qq{PS2. This email template suits as UTF-8 characters (example: ąćęółńżź) test too :)\n}
    );

    SLight::Test::Site::Builder::make_email(
        'registration',
        qq{Dear ~~name~~,\n}.
        qq{\n}.
        qq{An account has been registered on ~~domain~~ by using the e-mail address ~~email~~.\n}.
        qq{\n}.
        qq{Please validate it by using the following link: ~~confirmation_link~~\n}.
        qq{\n}.
        qq{Thank you,\n}.
        qq{Your SLight Automated Test.\n}.
        qq{\n}.
        qq{PS. This message was triggered by an automated test.\n}.
        qq{If You DID received it, please simply ignore.\n}
    );

    return;
} # }}}

# vim: fdm=marker
1;
