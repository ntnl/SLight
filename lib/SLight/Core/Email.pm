package SLight::Core::Email;
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

use SLight::Core::Config;
use SLight::Core::DB;
use SLight::Core::L10N qw( TR );

use Carp;
use Encode qw( decode encode );
use File::Slurp qw( read_file );
use MIME::Lite;
use Params::Validate qw( :all );
use YAML::Syck qw( DumpFile LoadFile );
# }}}

# Purpose:
#   SLight's internal Email address handling and Email sending.

################################################################################
#                       Email ID support functions                             #
################################################################################

# Purpose:
#   Get email and login, using Email_id.
#   If login is not defined, it means that it belongs to some un-registered Guest.
sub get_by_id { # {{{
    my ( $Email_id ) = @_;

    my $sth = SLight::Core::DB::run_query(
        query => [ 'SELECT email, login FROM Email LEFT JOIN User_Entity ON User_Entity.email_id = Email.id WHERE Email.id = ', $Email_id ],
        debug => 0,
    );
    if (my ($email, $login) = $sth->fetchrow_array()) {
        return ($email, $login);
    }

    return;
} # }}}

# Purpose:
#   Return email's ID asociated to some email address,
#   or 'undef' if email address is not yet known in the system.
#
#   Optionally, entry might be auto-created on demand,
#   if email is not found.
sub get_email_id { # {{{
    my ( $email, $auto_create ) = @_;

    my $sth = SLight::Core::DB::run_query(
        query => ['SELECT id FROM Email WHERE email=', $email],
        debug => 0,
    );

    my $email_id = $sth->fetchrow_array();

    if (not $email_id and $auto_create) {
        return add_email($email);
    }

    return $email_id;
} # }}}

# Purpose:
#   Return login of the User owning given email.
#   If given email is not known in the system or it is not attached to any User,
#   'undef' will be returned.
sub get_user { # {{{
    my ( $email, $auto_create ) = @_;

    my $sth = SLight::Core::DB::run_query(
        query => ['SELECT login FROM Email, User_Entity WHERE Email.id=User_Entity.email_id AND email=', $email],
        debug => 0,
    );
    return $sth->fetchrow_array();
} # }}}

# Purpose:
#   Return user logins for given list of emails.
#   If some emails are not known, or they are not attached to any Users,
#   they will not be returned in the hash.
#
# Returns:
#   hashref with emails as keys and user logins as values.
sub get_email_login_map { # {{{
    my ( @emails ) = @_;
    
    my $sth = SLight::Core::DB::run_query(
        query => [ 'SELECT email, login FROM Email, User_Entity WHERE Email.id=User_Entity.email_id AND email IN ', \@emails ],
        debug => 0,
    );
    my %email_login_map;
    while (my ($email, $login) = $sth->fetchrow_array()) {
        $email_login_map{$email} = $login;
    }

    return \%email_login_map;
} # }}}

# Purpose:
#   Add email to the Email dictionary.
#   Will die, if email already exists!
#
# Returns:
#   Email's ID
sub add_email { # {{{
    my ( $email ) = @_;

    SLight::Core::DB::run_query(
        query => ['INSERT INTO Email (email, status) VALUES (', $email, q{, }, 'A', q{)}],
        debug => 0,
    );

    return SLight::Core::DB::last_insert_id();
} # }}}

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

    # Archive the email in logs, in case something-is-wrong.
    # ...and it aids development.
    # Will be an option in 1.0 version.
    print STDERR $lite_message->as_string();

    return send_lite($lite_message);
} # }}}

################################################################################
#                                   Guts.                                      #
################################################################################

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

# Purpose:
#   Assign User ID to an email.
sub set_user_id { # {{{
    my ( $email, $user_id ) = @_;

    SLight::Core::DB::run_query(
        query => ['UPDATE Email SET user_id = ', $user_id, ' WHERE email = ', $email ],
        debug => 0,
    );

    # Fixme: would be nice, to actually check if We did anything ;)

    return;
} # }}}

# vim: fdm=marker
1;
