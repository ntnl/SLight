package SLight::Core::Session;
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

our $VERSION = 0.0.3;

use SLight::Core::Config;

use SLight::Core::IO qw( safe_save_YAML );

use Carp;
use Carp::Assert::More qw( assert_defined );
use English qw(-no_match_vars);
use Params::Validate qw( :all );
use YAML::Syck qw( LoadFile );
# }}}

# Session data is stored here:
my $session;
my $session_id;

# Start a new session.
sub start { # {{{
    reset_module();

	$session_id = new_session_id();
    
    # Here we initialize a new, empty, session.
    $session = {
		vars => {
			# session vars - generally ANY Perl data (data, not code references and no objects!).
		},
		expires => time + 3600,
            # By default session expires after an hour.
	};

    return $session;
} # }}}

# Try to load recent session, or spawn new one if that can not be done.
sub restore { # {{{
    my ( $id ) = @_;

    assert_defined($id, "Session ID given");

    reset_module();

    if (not is_valid_session_id($id)) {
        # Someone tried to do something nasty?
        carp "Not a valid session id: '$id', starting new session.\n";
        $session_id = new_session_id();
    }
    else {
        $session_id = $id;
    }

    my $file = session_filename();

    if (-f $file) {
        # We should gracefully fail - session will not work,
        # but system will be at least partially usable.
        $session = LoadFile( $file );
    }

    # If we ware unable to load session, or it contains some garbage - it will be reseted.
    # Expired sessions should also be reseted.

    $session = validate_session($session);

    # Update the 'expires' deadline:
    $session->{'expires'} = time + 3600;

    return $session;
} # }}}

# Validate session (it's hash) and ALWAYS return proper session.
# If something is not right - run start() and return new (valid) session hash.
sub validate_session { # {{{
    my ( $local_session ) = @_;

    if (ref $local_session ne 'HASH') {
        return start();
    }
    elsif (not $local_session->{'expires'} or $local_session->{'expires'} < time) {
        # Note:
        #   In this place Session module could set some flag,
        #   so that others may know, that the session existed, but expired.
        return start();
    }

    # Nothing wrong found...
    return $local_session;
} # }}}

# Store session data on HDD.
sub save { # {{{
    my $file = session_filename();
    
#    # Debug:
#    open my $dh, ">", $file ."-Dumper";
#    use Data::Dumper; print $dh Dumper $session;
#    close $dh;

#    use Data::Dumper; print "Saving to: ". $file .q{: }. Dumper $session;

    safe_save_YAML($file, $session);

    return $session;
} # }}}

# Purpose:
#   Delete all session-related data, making the session non-recoverable.
sub drop { # {{{
    if (not $session_id) {
        return;
    }

    my $file = session_filename();

    if ($file) {
        unlink $file;
    }

    return;
} # }}}

# Return Session ID, so Interfaces can send it to the Client.
sub session_id { # {{{
    return $session_id;
} # }}}

# Returns reference to a session variable.
# Warning:
#   use part_set to set session variables!
sub part { # {{{
    my ( $part_name ) = @_;

    return $session->{$part_name};
} # }}}

# Set given part name to given value.
sub part_set { # {{{
    my ( $part_name, $value ) = @_;

    $session->{$part_name} = $value;

    return $session->{$part_name};
} # }}}

# Deletes a session variable.
sub part_reset { # {{{
    my ( $part_name ) = @_;

    delete $session->{$part_name};

    return;
} # }}}

# Generates a new session ID.
sub new_session_id { # {{{
    return SLight::Core::IO::unique_id();
} # }}}

# Returns true (1) if given string is a valid session ID string.
# Returns false (undef) in other case.
sub is_valid_session_id { # {{{
    my ( $tmp_session_id ) = @_;
    
    # Empty ID is not valid.
    if (not $tmp_session_id) { return; }
    
    my $hex8  = qr{[0-9A-F]{8,8}}s;
    my $hex4  = qr{[0-9A-F]{4,4}}s;
    my $hex12 = qr{[0-9A-F]{12,12}}s;

    # ID looks like UUID.
    if ($tmp_session_id =~ m{^$hex8-$hex4-$hex4-$hex4-$hex12$}s) { return 1; }
    
    return;
} # }}}

# Returns path for the file, in which session is stored.
sub session_filename { # {{{
    return SLight::Core::Config::get_option('data_root') .q{/sessions/}. $session_id .q{.yaml};
} # }}}

# Reset session module before it can handle session in another request.
sub reset_module { # {{{
    $session    = {};
    $session_id = undef;

    return;
} # }}}

# vim: fdm=marker
1;
