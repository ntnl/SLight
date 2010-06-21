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
# use SLight::Common::TUI qw( confess_on_false carp_on_true );

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
        pathhandler_factory => undef,
        protocol_factory    => undef,
        handler_factory     => undef,
        plugin_factory      => undef,
    };

    bless $self, $class;

    # The fun begins now :)

    $self->{'pathhandler_factory'} = CoMe::PathHandlerFactory->new();
    $self->{'protocol_factory'}    = CoMe::ProtocolFactory->new();
    $self->{'handler_factory'}     = CoMe::HandlerFactory->new();
    $self->{'plugin_factory'}      = CoMe::PluginFactory->new();

    # Store in module's space, effectively making this object a singleton.
    return $_handler_object = $self;
} # }}}

# Main Request Pipeline:
# o Make sure required Output module is loaded (load if necesairly)
# o Create a request handler
# o Run request handler
# o Format output
# o Return formated output
sub main { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            url          => { type=>HASHREF },
            options      => { type=>HASHREF },
		    output       => { type=>SCALAR },
            interactive  => { type=>SCALAR, optional=>1, default=>0 },
            default_lang => { type=>SCALAR, optional=>1 },
        }
    );

    Cache_Purge_Request();

    my $access_granted = 0;
    my $r_pkg     = q{};
    my $r_handler = q{};
    my $r_action  = q{};

    my $output_object  = undef;
    my $handler_object = undef;

    my $user_hash = undef;

    # There is no much sense in eval-ing this... if Reqest is unable to make an output object,
    # it will have NO way of reporting the error either :(
    $output_object = $self->{'output_factory'}->make(
        type => $P{'output'}
    );

    # Start session. This way any access (read/write) made trough the request will be atomic.
    # ...and in the case of SQLite - faster.
    CoMe::Core::DB::check();
    CoMe::Core::DB::run_query( query=>'BEGIN TRANSACTION' ); # warn "B";
    
    my $request_language = $P{'default_lang'};

    # Stage I, preparing for the request.
    my $stage_1_ok = eval {
        task_starts("CoMe::Core::Request factoring");
        
        $r_pkg     = $P{'url'}->{'pkg'};
        $r_handler = $P{'url'}->{'handler'};
        $r_action  = $P{'url'}->{'action'};

        # Sanity checks.
        confess_on_false( $r_pkg,     "Request aborted, Package missing.");
        confess_on_false( $r_handler, "Request aborted, Handler missing.");
        confess_on_false( $r_action,  "Request aborted, Action missing.");
        # Safety checks
        confess_on_false( ($r_pkg     =~ m{^[a-zA-Z]+$}s), "Request aborted, Package contains unwelcome haracters.");
        confess_on_false( ($r_handler =~ m{^[a-zA-Z]+$}s), "Request aborted, Handler contains unwelcome haracters.");
        confess_on_false( ($r_action  =~ m{^[a-z\_]+$}s),  "Request aborted, Action contains unwelcome haracters.");

#        use Data::Dumper; warn 'Request.pm Url: '. Dumper $P{'url'};

        # Check, if User is a Guest, or is a known User.
        $user_hash = $self->make_user_hash();

        $access_granted = $self->check_grant(
            user_hash => $user_hash,
            pkg       => $r_pkg,
            handler   => $r_handler,
            action    => $r_action,
            method    => $P{'url'}->{'method'},
        );
        
        # Language selection.
        # First: from URL
        # Second: from session
        # Third: auto-detected (by Interface, default_lang)
        if ($P{'url'}->{'lang'}) {
            $request_language = $P{'url'}->{'lang'};

            $user_hash->{'lang'} = $P{'url'}->{'lang'};

            CoMe::Core::Session::part(
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
            my $langs = CoMe::Core::Config::get_option('lang');

            $request_language = $langs->[0];
        }

        CoMe::Common::L10N::init(
            CoMe::Core::Config::get_option(q{site_root}) .q{l10n/},
            $request_language
        );

        my %handler_factory_params = (
            pkg     => $r_pkg,
            handler => $r_handler,
            action  => ucfirst $r_action,
        );
        $handler_object = $self->{'handler_factory'}->make(%handler_factory_params);

        task_switch("CoMe::Core::Request factoring", "CoMe::Core::Request access");

        # Connect to database, or at least check, if there is a connection.
        CoMe::Core::DB::check();

        task_ends("CoMe::Core::Request access");

        return 'ok';
    };

    my $output_data;
    if ($EVAL_ERROR or not $stage_1_ok) {
        # Request hit a failure :(
        my $error_text = ( $EVAL_ERROR or 'none' );

        print STDERR "Eval error (stage 1): ". $error_text ."\n";

        # DB Session shoule be cancelled, as changes may be inconsistent.
        CoMe::Core::DB::run_query( query=>'ROLLBACK' ); # warn "R";

        $output_data = $self->internal_error($error_text);
    }
    else {
        # Request was properly initialized :)

        # Can move to Stage II - response.

        $output_data = eval {
            if (not $access_granted) {
                # Access to this was NOT granted!
                return $self->access_denied_page();
            }
            else {
                task_starts("CoMe::Core::Request running");

                $output_data = $handler_object->run(
                    options => $P{'options'},

	            	path    => $P{'url'}->{'path'},
                    method  => $P{'url'}->{'method'},
	            	page    => $P{'url'}->{'page'},
    
                    user    => $user_hash,

                    pkg     => $r_pkg,
                    handler => $r_handler,
                    action  => $r_action,

                    lang => $request_language
                );

                task_ends("CoMe::Core::Request running");
            }

            return $output_data;
        };

        if ($EVAL_ERROR or not $output_data) {
            my $error_text = ( $EVAL_ERROR or 'none' );

            # DB Session may be corrupt, and should be rolled-back.
            CoMe::Core::DB::run_query( query=>'ROLLBACK' ); # warn "R2";

            print STDERR "Eval error (stage 2): ". $error_text ."\n";

            $output_data = $self->internal_error($error_text);
        }
        else {
            # DB Session can be finished.
            CoMe::Core::DB::run_query( query=>'COMMIT' ); # warn "E";

            if ($output_data->{'redirect'}) {
                return {
                    'location' => $output_data->{'redirect'}
                };
            }
            elsif ($output_data->{'send_file'}) {
                return {
                    'send_file' => $output_data->{'send_file'}
                };
            }

            task_starts("CoMe::Core::Request plugins");

            # Are we doing an interactive request?
            # If so - we should ass some candy, so the User is happy :)
            if ($P{'interactive'}) {
                $output_data->{'plugins'} = $self->run_plugins(
                    output  => $output_data,
                    options => $P{'options'},
                    url     => $P{'url'},
                    user    => $user_hash,
                    lang    => $request_language
                );
            }

            task_ends("CoMe::Core::Request plugins");
        }
    }

    task_starts("CoMe::Core::Request output");

    my $content = $output_object->process( $output_data );

    task_ends("CoMe::Core::Request output");

    return { content => $content };
} # }}}

# Purpose:
#   Prepare 'user_hash' - data, about our current visitor, either User or Guest.
sub make_user_hash { # {{{
    my ( $self ) = @_;

    my $user_hash = CoMe::Core::Session::part( 'user' );
    if ($user_hash) {
        if ($user_hash->{'login'}) {
            my $user_data = CoMe::Core::User::get_data( user=>$user_hash->{'login'} );

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
    if ($ENV{'COME_SKIP_AUTH'}) {
        return 1;
    }

    # At this point, grants must be checked.
    my %grant = CoMe::Core::User::Access::get_effective_user_access_rights(
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

sub internal_error { # {{{
    my ( $self, $error_text ) = @_;

    my $message = TR('Unhandled internal error has occured.');

    if ($ENV{'REMOTE_ADDR'} and $ENV{'REMOTE_ADDR'} eq q{127.0.0.1}) {
        my $debug = CoMe::Core::Config::get_option('debug');

        $message .= qq{\n};
        if ($debug) {
            $message .= $error_text;
        }
        else {
            $message .= TR("Enable 'debug' config option to see full error message");
        }
    }

    # Load on demand. This IS risky, but benefits seems to be better.
    require CoMe::Response::GenericMessage;

    my $response = CoMe::Response::GenericMessage->new(
        text  => $message,
        class => 'CoMe_Internal_Error'
    );

    return $self->built_in_reply(
        title    => TR('Internal error'),
        response => $response->get_data(),
    );
} # }}}

# vim: fdm=marker
1;
