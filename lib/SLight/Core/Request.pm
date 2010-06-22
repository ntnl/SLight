package SLight::Core::Request;
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

use SLight::PathHandlerFactory;
use SLight::ProtocolFactory;
use SLight::HandlerFactory;
use SLight::AddonFactory;

use SLight::Core::Session;
use SLight::Core::User;
use SLight::Core::User::Access;

use SLight::Common::TaskProfiler qw( task_starts task_ends task_switch );
use SLight::Common::L10N qw( TR TF );

# use CoMe::Common::Cache qw( Cache_Purge_Request );

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

my $_handler_object;

# Makre a Core::Request object
sub new { # {{{
    my $class = shift;
    my %P = validate(
        @_,
        {
        }
    );

    if ($_handler_object) {
        return $_handler_object;
    }

    # Prototype of the object:
    my $self = {
        path_handler_factory => undef,
        protocol_factory     => undef,
        handler_factory      => undef,
        addon_factory        => undef,
    };

    bless $self, $class;

    # The fun begins now :)

    $self->{'path_handler_factory'} = SLight::PathHandlerFactory->new();
    $self->{'protocol_factory'}     = SLight::ProtocolFactory->new();
    $self->{'handler_factory'}      = SLight::HandlerFactory->new();
    $self->{'addon_factory'}        = SLight::AddonFactory->new();

    # Store in module's space, effectively making this object a singleton.
    return $_handler_object = $self;
} # }}}

# Main Request Pipeline:
#   Stage 1:
#       Prepare Path Handler object
#       Prepare Protocol object
#   Stage 2:
#       Find objects referenced by path
#   Stage 3:
#       Handle objects found in stage 3.
#
# Returns:
#   $request_result = {
#       response => CONTENT | ERROR | FILE | REDIRECT
#
#       content   => $data,      # Data to return.
#       mime_type => $mime_type, # MIME type of the $data.
#       path      => $file_path,
#       debug     => $debug,     # Additional debuging information.
#       location  => $url,       # Valid for redirect response.
#   };
#   # ERROR   - Problem description. Content is always plain text.
#   # CONTENT - Data with well-defined mime-type.
#   # FILE    - Date pointed by $file_path. Mime-type must be determined by interface.
sub main { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            session_id   => { type=>SCALAR | UNDEF },
            url          => { type=>HASHREF },
            options      => { type=>HASHREF },
            interactive  => { type=>SCALAR, optional=>1, default=>0 },
            default_lang => { type=>SCALAR, optional=>1 },
        }
    );

#    Cache_Purge_Request();
    
    if ($P{'session_id'}) {
        SLight::Core::Session::restore($P{'session_id'});
    }
    else {
        SLight::Core::Session::start();
    }

    # Start session. This way any access (read/write) made trough the request will be atomic.
    # ...and in the case of SQLite - probably faster.
    SLight::Core::DB::check();
    SLight::Core::DB::run_query( query=>'BEGIN TRANSACTION' );
    
    my $request_language = $P{'default_lang'};

    my $path_handler_object;
    my $protocol_object;
    my $user_hash = undef;

    # Stage I, preparing for the request.
    my $stage_1_complete = eval {
        task_starts("SLight::Core::Request preparation");

        my $r_path_handler = $P{'url'}->{'path_handler'};
        my $r_path         = $P{'url'}->{'path'};
        my $r_protocol     = $P{'url'}->{'protocol'};

        # Sanity checks.
        assert_defined( $r_path_handler, "Path Handler - present");
        assert_defined( $r_path,         "Path - present");
        assert_defined( $r_protocol,     "Protocol - present");

        # Safety checks
        assert_like( $r_path_handler, qr{^[A-Z][a-zA-Z]+$}s, "Path Handler - sane");
        assert_like( $r_protocol,     qr{^[A-Z][a-zA-Z]+$}s, "Protocol - sane");

#        use Data::Dumper; warn 'Request.pm Url: '. Dumper $P{'url'};

# Planed for M4
#        # Check, if User is a Guest, or is a known User.
#        $user_hash = $self->make_user_hash();

# Planed for M4
#        $access_granted = $self->check_grant(
#            user_hash => $user_hash,
#            pkg       => $r_pkg,
#            handler   => $r_handler,
#            action    => $r_action,
#            method    => $P{'url'}->{'method'},
#        );
        
        # Language selection.
        # First: from URL
        # Second: from session
        # Third: auto-detected (by Interface, default_lang)
        if ($P{'url'}->{'lang'}) {
            $request_language = $P{'url'}->{'lang'};

            $user_hash->{'lang'} = $P{'url'}->{'lang'};

            SLight::Core::Session::part(
                'user',
                $user_hash
            );
        }
        elsif ($user_hash->{'lang'}) {
            $request_language = $user_hash->{'lang'};
        }
        elsif (not $request_language) {
            # Default language was not supplied by the Interface.
            # Have to make a default by our own...
            my $langs = SLight::Core::Config::get_option('lang');

            $request_language = $langs->[0];
        }

# Planed for M3
#        SLight::Core::L10N::init(
#            SLight::Core::Config::get_option(q{site_root}) .q{l10n/},
#            $request_language
#        );
        
        task_switch("SLight::Core::Request preparation", "SLight::Core::Request path handling");

        $path_handler_object = $self->{'path_handler_factory'}->make(
            handler => $P{'url'}->{'path_handler'}
        );

        task_switch("SLight::Core::Request path handling", "SLight::Core::Request protocol handling");

        $protocol_object = $self->{'protocol_factory'}->make(
            protocol => $P{'url'}->{'protocol'}
        );

        task_ends("SLight::Core::Request protocol handling");

        return 1;
    };

    if ($EVAL_ERROR or not $stage_1_complete) {
        # Request hit a failure :(
        my $debug_text = ( $EVAL_ERROR or 'none' );

        print STDERR "Eval error (stage 1): ". $debug_text ."\n";

        # DB Session shoule be cancelled, as changes may be inconsistent.
        SLight::Core::DB::run_query( query=>'ROLLBACK' ); # warn "R";

        return {
            response => 'ERROR',
            content  => $self->internal_error(
                TR(q{Internal error. Site is temporarly unavailable.}), # Fixme: write better text here
                $debug_text
            ),
        };
    }
    
    # Request was properly initialized :)
    # Can move to Stage II - what was requested?
    my $response_content = eval {
        return $path_handler_object->analyze_path($P{'url'}->{'path'});
    };

    if ($EVAL_ERROR or not $response_content) {
        carp("Bad path!"); # Fixme!
    }
    
    # Path seems to be fine.
    # Can move to Stage III - produce response

    my $response_result = eval {
        return $protocol_object->respond(
            url => $P{'url'},
        );
    };

    if ($EVAL_ERROR or not $response_result) {
        # Request hit a failure :(
        my $debug_text = ( $EVAL_ERROR or 'none' );

        print STDERR "Eval error (stage 3): ". $debug_text ."\n";

        # DB Session shoule be cancelled, as changes may be inconsistent.
        SLight::Core::DB::run_query( query=>'ROLLBACK' ); # warn "R";

        return {
            response => 'ERROR',
            content  => $self->internal_error(
                TR(q{Internal error. Site is temporarly unavailable.}), # Fixme: write better text here
                $debug_text
            ),
        };
    }

    SLight::Core::Session::save();

    # DB Session can be finished.
    SLight::Core::DB::run_query( query=>'COMMIT' ); # warn "E";

    return $response_result;
} # }}}

# Purpose:
#   Prepare 'user_hash' - data, about our current visitor, either User or Guest.
sub make_user_hash { # {{{
    my ( $self ) = @_;

    my $user_hash = SLight::Core::Session::part( 'user' );
    if ($user_hash) {
        if ($user_hash->{'login'}) {
            my $user_data = SLight::Core::User::get_data( user=>$user_hash->{'login'} );

            $user_hash->{'email'} = $user_data->{'email'};
            $user_hash->{'name'}  = $user_data->{'name'};
        }
    }
    else {
        $user_hash = {
            class => 'guest',
            login => q{},
            name  => 'Guest',
            lang  => q{},
            email => undef,
        };
    }

    return $user_hash;
} # }}}

# Check if User can access handler/action.
# Returns true (1) if he CAN, and false (0) if this is not allowed.
sub check_grant { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            user_hash => { type=>HASHREF },

            pkg       => { type=>SCALAR },
            handler   => { type=>SCALAR },
            action    => { type=>SCALAR },
            method    => { type=>SCALAR },
        }
    );

#    use Data::Dumper; warn Dumper \%P;
    
#    warn "Remove this hack!"; return 1;
    
    $P{'action'} = ucfirst $P{'action'};

    # In some tests, there is no need to check this...
    # Setting this variable will bypass authorization routines.
    if ($ENV{'SLIGHT_SKIP_AUTH'}) {
        return 1;
    }

    # At this point, grants must be checked.
    my %grant = SLight::Core::User::Access::get_effective_user_access_rights(
        login   => $P{'user_hash'}->{'login'},

        pkg     => $P{'pkg'},
        handler => $P{'handler'},
        action  => $P{'action'},
    );

    if ($grant{ ucfirst lc $P{'method'} }) {
        # Granted - can use this method :)
        return 1;
    }

    # There is no reason, to allow this User to access the page...
    return 0;
} # }}}

sub run_plugins { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            output   => { type=>HASHREF },
            options  => { type=>HASHREF },
            url      => { type=>HASHREF },
            user     => { type=>HASHREF },
            lang     => { type=>SCALAR },
        }
    );

    my %plugins_data;

    my $response = CoMe::Response->new();

    foreach my $plugin (qw( ContentMenu ContentSubMenu PathBar Notification Toolbox Language Handlers Output UserPanel SysInfo Pager )) {
        # Error in a single plugin should not take the whole subsystem down.
        $plugins_data{$plugin} = eval {
            my $plugin_object = $self->{'plugin_factory'}->make(
                type => $plugin
            );

            return $plugin_object->process(
                %P,
                response => $response,
            );
        };

        carp_on_true($EVAL_ERROR, "Plugin error: ". $EVAL_ERROR);
    }

#    use Data::Dumper; warn "Plugin Data: ". Dumper \%plugins_data;

    return \%plugins_data;
} # }}}

# Standard, built-in, replies.

sub built_in_reply { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            title    => { type=>SCALAR },
            response => { type=>HASHREF },
        }
    );

    return {
        meta => {
            title => $P{'title'},
        },

        primary   => $P{'response'},
        secondary => {},

        template => 'Default',
        redirect => q{},
    };
} # }}}

sub access_denied_page { # {{{
    my $self = shift;

    require CoMe::Response::GenericMessage;

    my $response = CoMe::Response::GenericMessage->new(
        text  => TR('You are not permited to enter this part of the page.'),
        class => 'CoMe_Access_Error'
    );

    return $self->built_in_reply(
        title    => TR('Access denied'),
        response => $response->get_data(),
    );
} # }}}

# Todo: Needs serious fixing!
sub internal_error { # {{{
    my ( $self, $error_text, $debug_text ) = @_;

    carp("Unimplemented!");
    
#    my $message = TR('Unhandled internal error has occured.');
#
#    if ($ENV{'REMOTE_ADDR'} and $ENV{'REMOTE_ADDR'} eq q{127.0.0.1}) {
#        my $debug = SLight::Core::Config::get_option('debug');
#
#        $message .= qq{\n};
#        if ($debug) {
#            $message .= $error_text;
#        }
#        else {
#            $message .= TR("Enable 'debug' config option to see full error message");
#        }
#    }
#
#    return $self->built_in_reply(
#        title    => TR('Internal error'),
#        response => $response->get_data(),
#    );
} # }}}

# vim: fdm=marker
1;
