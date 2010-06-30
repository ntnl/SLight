package SLight::Core::Email;
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

use SLight::Core::L10N qw( TR );
use SLight::Core::Config;

use Encode qw( decode encode );
use File::Slurp qw( read_file );
use MIME::Lite;
use Params::Validate qw( :all );
# }}}

# Purpose:
#   Send textual message to given email address (wrapper for MIME::Lite, for internal use).
#
# Parameters:
#   email : Email address
#   title : Message title
#   text  : Message content
sub send_to_email { # {{{
    my %P = validate(
        @_,
        {
            email => { type=>SCALAR }, 
            title => { type=>SCALAR }, 
            text  => { type=>SCALAR },
        }
    );

#    print STDERR "Email : " . $P{'email'} . "\n";
#    print STDERR "Title : " . $P{'title'} . "\n";
#    print STDERR "Text  : " . $P{'text'} . "\n";

    # Without those, MIME::Lite throws an error on UTF-8 (2010-05-31)
#    utf8::encode($P{'email'});
#    utf8::encode($P{'title'});
#    utf8::encode($P{'text'});

	my $lite_message = MIME::Lite->new(
		From    => 'mailer@'. SLight::Core::Config::get_option('domain'),
		To      => encode('utf8', $P{'email'}),
		Subject => encode('utf8', $P{'title'}),
		Type    => 'multipart/mixed'
	);

	# Część tekstowa:
	my $part = $lite_message->attach(
		Type     => 'text/plain',
		Encoding => 'quoted-printable',
		Data     => encode('utf8', $P{'text'}),
	);
    $part->attr('content-type.charset' => 'UTF-8');

    # In future it would be nice to add attachments.

#    warn "Sending mail to: $P{'email'}\n";

#    warn $lite_message->as_string();

    return send_lite($lite_message);
} # }}}

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

    return send_to_email(
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

    return send_to_email(
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

    return send_to_email(
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

#                           Guts.

my $_clear_to_send = 1;

# Purpose:
#   Block email messages from being sent.
#   Intended to be used in unit tests.
sub debug_disable_sending { # {{{
    return $_clear_to_send = 0;
} # }}}

# Purpose:
#   Re-enable sending email messages.
#   Intended to be used in unit tests.
sub debug_enable_sending { # {{{
    return $_clear_to_send = 1;
} # }}}

our @_unsent_stack; ## no critic (Variables::ProhibitPackageVars)

# Purpose:
#   This function is here, so it is easy to overwrite it in tests.
sub send_lite { # {{{
    my ( $lite_message ) = @_;

    if ($_clear_to_send) {
        return $lite_message->send();
    }

    push @_unsent_stack, $lite_message;

    return;
} # }}}



# vim: fdm=marker
1;
