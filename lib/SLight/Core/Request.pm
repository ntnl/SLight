package SLight::Core::Request;
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

use SLight::AddonFactory;
use SLight::API::User;
use SLight::API::Permissions qw( can_User_access );
use SLight::Core::DB;
use SLight::Core::L10N qw( TR TF );
use SLight::Core::Session;
use SLight::Core::Profiler qw( task_starts task_ends task_switch );
use SLight::HandlerFactory;
use SLight::PathHandlerFactory;
use SLight::ProtocolFactory;

# use SLight::Core::Cache qw( Cache_Purge_Request );

use Carp::Assert::More qw( assert_defined assert_like );
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

my $_handler_object;

# Make a Core::Request object
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
    };

    bless $self, $class;

    # The fun begins now :)

    $self->{'path_handler_factory'} = SLight::PathHandlerFactory->new();
    $self->{'protocol_factory'}     = SLight::ProtocolFactory->new();

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

    # Start session. This way any access (read/write) made trough the request will be atomic.
    # ...and in the case of SQLite - probably faster.
    my $db_is_ok = eval {
        SLight::Core::DB::check();

        SLight::Core::DB::run_query( query=>'BEGIN TRANSACTION' );

        return 1;
    };
    if ($EVAL_ERROR or not $db_is_ok) {
        # Introduce a delay...
        sleep 1;

        # ...disconnect...
        SLight::Core::DB::disconnect();

        # ...and retry.
        $db_is_ok = eval {
            SLight::Core::DB::check();

            SLight::Core::DB::run_query( query=>'BEGIN TRANSACTION' );

            return 1;
        };
        if ($EVAL_ERROR or not $db_is_ok) {
            return $self->stage_error(
                stage => 0,
                ee    => $EVAL_ERROR,
            );
        }
    }

    my $request_language = $P{'default_lang'};

    my $path_handler_object;
    my $protocol_object;
    my $user_hash;

#    use Data::Dumper; warn Dumper $user_hash;

    # Stage I, preparing for the request.
    my $stage_1_complete = eval {
        task_starts("SLight::Core::Request preparation");

        if ($P{'session_id'}) {
            SLight::Core::Session::restore($P{'session_id'});
        }
        else {
            SLight::Core::Session::start();
        }

        my $r_path_handler = $P{'url'}->{'path_handler'};
        my $r_path         = $P{'url'}->{'path'};
        my $r_protocol     = $P{'url'}->{'protocol'};

        # Sanity checks.
        assert_defined( $r_path_handler, "Path Handler - present");
        assert_defined( $r_path,         "Path - present");
        assert_defined( $r_protocol,     "Protocol - present");

        # Safety checks
        assert_like( $r_path_handler, qr{^[A-Z][a-zA-Z_]+$}s, "Path Handler - sane"); ## no critic qw(Variables::ProhibitPunctuationVars)
        assert_like( $r_protocol,     qr{^[a-z_]+$}s,         "Protocol - sane"); ## no critic qw(Variables::ProhibitPunctuationVars)

#        use Data::Dumper; warn 'Request.pm Url: '. Dumper $P{'url'};

        # Check, if User is a Guest, or is a known User.
        $user_hash = $self->make_user_hash();

        # Language selection.
        # First: from URL
        # Second: from session
        # Third: auto-detected (by Interface, default_lang)
        if ($P{'url'}->{'lang'}) {
            $request_language = $P{'url'}->{'lang'};

            $user_hash->{'lang'} = $P{'url'}->{'lang'};

            SLight::Core::Session::part_set(
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

        # Modifying URL's language has some advantages:
        #   - no matter what, always on the URL's language (no matter, how it was set)
        #   - once language is defined, URLs will have them (since new URLs are build using current one)
        $P{'url'}->{'lang'} = $request_language;

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
        return $self->stage_error(
            stage => 1,
            ee    => $EVAL_ERROR,
        );
    }

    # Request was properly initialized :)
    # Can move to Stage II - what was requested?
    my $page_content = eval {
        return $path_handler_object->analyze_path($P{'url'}->{'path'}, $P{'url'}->{'lang'});
    };

    if ($EVAL_ERROR or not $page_content) {
        return $self->stage_error(
            stage => 2,
            ee    => $EVAL_ERROR,
        );
    }

    my $auth_check_ok = eval {
        # Check if User can access main object.
        my $access_main_object = $self->verify_access_to_object(
            $user_hash->{'id'},
            $page_content->{'objects'}->{ $page_content->{'main_object'} },
            $P{'url'}->{'action'},
        );

        # Check, if the User can use aux object from the page.
        if ($access_main_object) {
            foreach my $object_id (keys %{ $page_content->{'objects'} }) {
                if ($object_id eq $page_content->{'main_object'}) {
                    next;
                }

                $self->verify_access_to_object(
                    $user_hash->{'id'},
                    $page_content->{'objects'}->{ $object_id },
                    'View'
                );
            }
        }
        else {
            # Access was denied!
            $P{'url'}->{'action'} = 'View'; # FIXME: Find some more sane way of doing this rewrite!

            $page_content->{'objects'} = {
                $page_content->{'main_object'} => $page_content->{'objects'}->{ $page_content->{'main_object'} },
            };
            $page_content->{'object_order'} = [ $page_content->{'main_object'} ];
        }

        return 1;
    };
    if ($EVAL_ERROR or not $auth_check_ok) {
        return $self->stage_error(
            stage => 3,
            ee    => $EVAL_ERROR,
        );
    }

    # Path seems to be fine.
    # Can move to Stage III - produce response

    my $response_result = eval {
        return $protocol_object->respond(
            user    => ( $user_hash or { login => undef, id => undef } ),
            url     => $P{'url'},
            options => $P{'options'},
            page    => $page_content,
        );
    };

    if ($EVAL_ERROR or not $response_result) {
        return $self->stage_error(
            stage => 4,
            ee    => $EVAL_ERROR,
        );
    }

    my $cleanup_is_ok = eval {
        SLight::Core::Session::save();

        # DB Session can be finished.
        SLight::Core::DB::run_query( query=>'COMMIT' ); # warn "E";
    };
    if ($EVAL_ERROR or not $cleanup_is_ok) {
        print STDERR "Reques did not end cleanly: " . ($EVAL_ERROR or q{unknown problem}) . "\n";
    }

    return $response_result;
} # }}}

# Purpose:
#   Prepare 'user_hash' - data, about our current visitor, either User or Guest.
sub make_user_hash { # {{{
    my ( $self ) = @_;

    my $user_hash = SLight::Core::Session::part( 'user' );

    if ($user_hash and $user_hash->{'login'}) {
        my $user_data = SLight::API::User::get_User_by_login( $user_hash->{'login'} );

#        use Data::Dumper; warn 'User data: ' . Dumper $user_data;

        $user_hash->{'email'} = $user_data->{'email'};
        $user_hash->{'name'}  = $user_data->{'name'};
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

#    use Data::Dumper; warn 'User hash: ' . Dumper $user_hash;

    return $user_hash;
} # }}}

# TODO: Needs some love!
sub stage_error { # {{{
    my ( $self, %P ) = @_;

    print STDERR "Eval error (stage: " . $P{'stage'} . "): ". ( $P{'ee'} or 'none' ) ."\n";

    # DB Session shoule be cancelled, as changes may be inconsistent.
    SLight::Core::DB::run_query( query=>'ROLLBACK' ); # warn "R";

    SLight::Core::DB::disconnect();

#    warn "Stage: ". $P{'stage'};
#    warn $P{'ee'};

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

    return {
        response => 'ERROR',
        content  => TR(q{Internal error. Site is temporarly unavailable.}), # Fixme: write better text here
        debug    => $P{'ee'},
    };
} # }}}

sub verify_access_to_object { # {{{
    my ( $self, $user_id, $object, $action ) = @_;

    my ($pkg, $handler) = ( $object->{'class'} =~ m{^(.+?)::(.+?)$}s );

    my $policy = can_User_access(
        id => $user_id,

        handler_family => $pkg,
        handler_class  => $handler,
        handler_action => $action,

        handler_object => $object->{'oid'},
    );

    if ($policy ne q{GRANTED}) {
        print STDERR "Denied access to $pkg :: $handler :: $action \n";

        $object->{'class'}    = q{Error::AccessDenied};
        $object->{'oid'}      = undef;
        $object->{'metadata'} = {};

        return;
    }

    return 1;
} # }}}

# vim: fdm=marker
1;
