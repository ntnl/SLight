package SLight::API::Email;
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

use SLight::Core::Config;
use SLight::Core::Email;
use SLight::Core::L10N qw( TR );

use File::Slurp qw( read_file );
use Params::Validate qw( :all );
# }}}

# Purpose:
#   High-level routines for sending emails to Users.

# Purpose:
#   Send message, which is used to validate email address, before it can be used elsewhere.
#   This applies to situations, where already registered user wants to change it's email addres.
sub send_confirmation { # {{{
    my %P = validate(
        @_,
        {
            email             => { type=>SCALAR },
            name              => { type=>SCALAR },
            confirmation_link => { type=>SCALAR },
        }
    );

    my $text = _load_template(q{confirmation});

    foreach my $field (qw( email name confirmation_link )) {
        my $value = $P{$field};

        $text =~ s{~~$field~~}{$value}sg;
    }

    return SLight::Core::Email::send_to_email(
        email => $P{'email'},
        title => TR(q{Confirm email account}),
        text  => $text,
    );
} # }}}

# Purpose:
#   Send message, which is used to check email addres of an User, that want's to create an account.
sub send_registration { # {{{
    my %P = validate(
        @_,
        {
            email             => { type=>SCALAR },
            domain            => { type=>SCALAR },
            name              => { type=>SCALAR },
            confirmation_link => { type=>SCALAR },
        }
    );

    my $text = _load_template(q{registration});

    foreach my $field (qw( email domain name confirmation_link )) {
        my $value = $P{$field};

        $text =~ s{~~$field~~}{$value}sg;
    }

    return SLight::Core::Email::send_to_email(
        email => $P{'email'},
        title => TR(q{Confirm account registration}),
        text  => $text,
    );
} # }}}

# Purpose:
#   Send generic notifications, such as:
#       - "someone posted a comment"
#       - "someone replied to Your comment"
#       - "server is low on disk space"
sub send_notification { # {{{
    my %P = validate(
        @_,
        {
            email         => { type=>SCALAR },
            name          => { type=>SCALAR },
            notifications => { type=>ARRAYREF },
        }
    );
    
    my $text = _load_template(q{notification});

    $P{'notifications'} = join "\n", @{ $P{'notifications'} };

    foreach my $field (qw( email name notifications )) {
        my $value = $P{$field};

        $text =~ s{~~$field~~}{$value}sg;
    }

    return SLight::Core::Email::send_to_email(
        email => $P{'email'},
        title => TR(q{Notification}),
        text  => $text,
    );
} # }}}

# Purpose:
#   Load specified email template.
sub _load_template { # {{{
    my ($name) = @_;

    my $text = decode('utf8', read_file(SLight::Core::Config::get_option('site_root') . q{email/} . $name . q{.txt}));

    return $text;
} # }}}

# vim: fdm=marker
1;
