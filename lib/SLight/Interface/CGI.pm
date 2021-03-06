package SLight::Interface::CGI;
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
use base q{SLight::Interface};

use SLight::Core::URL;
use SLight::Core::Config;
use SLight::Core::Session;

use Carp;
use Carp::Assert::More qw( assert_defined assert_hashref assert_exists );
use CGI::Minimal;
use Cwd qw( getcwd );
use Encode qw( decode_utf8 encode_utf8 );
use English qw( -no_match_vars );
use File::Slurp qw( read_file );
use Params::Validate qw( :all );
# }}}

my $session_cookie = 'SLightSesId';

sub init { # {{{
    my ( $self ) = @_;

    # Set-up CGI library, so We can mix GET and POST style parameters...
    CGI::Minimal::allow_hybrid_post_get(1);

    # Load configuration
    SLight::Core::Config::initialize( getcwd() );

    # Load low-level 'Maintenance' and 'Error' responses.
    my $site_root = SLight::Core::Config::get_option(q{site_root});
    foreach my $type (qw( Error Maintenance )) {
        foreach my $proto (qw( web yaml )) {
            my $source_path = $site_root . q{/response/} . $type .q{.}. $proto;

            if (-f $source_path) {
                my $content = read_file($source_path);

                $self->{'internal_response'}->{$type}->{$proto} = decode_utf8($content);
            }
        }
    }

    return;
} # }}}

sub main { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            url => { type=>SCALAR },
            bin => { type=>SCALAR },
        }
    );

#    use Data::Dumper; warn Dumper \%ENV;

    # Check and react to maintenance flag as soon as possible.
    my $maintenance_file_path = SLight::Core::Config::get_option('data_root') . q{var/maintenance.txt};
    if (-f $maintenance_file_path) {
        #
        # Maintenance mode is enabled.
        #
        my $mode = read_file($maintenance_file_path);

        if ($mode eq 'EXT') {
            # This is just the external maintenance.

            # As you can see, this mode is not implemented yet.
        }
        else {
            # Full maintenance.
            return $self->internal_maintenance_response($P{'url'}, q{});
        }
    }

    my %pass = (
        ERROR    => 'pass_ERROR',
        CONTENT  => 'pass_CONTENT',
        FILE     => 'pass_FILE',
        REDIRECT => 'pass_REDIRECT',
    );

    my $body = eval {
        my $main_response = $self->safe_main($P{'url'});

        assert_hashref($main_response, 'Response is a hashref');

        assert_exists(\%pass, $main_response->{'response'}, 'Response is supported');

        my $pass_method = $pass{ $main_response->{'response'} };

        my $body = $self->$pass_method($P{'url'}, $main_response);

        return $body;
    };
    if ($EVAL_ERROR or not defined $body) {
        carp "Eval error: ". ( $EVAL_ERROR or 'none' );

        my $msg = q{};
        if (SLight::Core::Config::get_option('debug')) {
            $msg = $EVAL_ERROR;
        }

        return $self->internal_error_response($P{'url'}, $msg);
    }

    return $self->headers_string() . qq{\n} . encode_utf8( $body or q{} );
} # }}}

# 'application/octet-stream'

# Purpose:
#   Return a built-in notification about an internal error.
#
# Note:
#   This is the worst thing that can happen!
#   Avoid this response at all cost!
sub pass_ERROR { # {{{
    my ( $self, $url, $result ) = @_;

    $self->set_header(
        name  => q{Status},
        value => q{500}
    );
    $self->set_header(
        name  => "content-type",
        value => q{text/plain; character-set: UTF-8}
    );

    return $self->internal_error_response('Internal error');
} # }}}

sub pass_REDIRECT { # {{{
    my ( $self, $url, $result ) = @_;

    $self->set_header(
        name  => "status",
        value => "302 Moved"
    );
    $self->set_header(
        name  => "location",
        value => $result->{'location'},
    );

    return "Location: " . $result->{'location'};
} # }}}

sub pass_CONTENT { # {{{
    my ( $self, $url, $result ) = @_;

    assert_defined($result->{'mime_type'}, q{Result's mime-type is defined.});
    assert_defined($result->{'content'},   q{Content is defined.});

    $self->set_header(
        name  => "content-type",
        value => $result->{'mime_type'}
    );

    return $result->{'content'};
} # }}}

sub pass_FILE { # {{{
    my ( $self, $url, $result ) = @_;

    assert_defined($result->{'mime_type'}, q{Result's mime-type is defined.});
    assert_defined($result->{'path'},      q{File's path is defined.});

    $self->set_header(
        name  => "content-type",
        value => $result->{'mime_type'}
    );

    return read_file($result->{'path'});
} # }}}

# Purpose:
#   This is the eval-protected part of the 'main' subroutine.
sub safe_main { # {{{
    my ( $self, $raw_url ) = @_;

    my $url_string  = q{/Content/};

    my $web_root = SLight::Core::Config::get_option(q{web_root});

    my $cgi = CGI::Minimal->new();
    if ($cgi->truncated) {
        return $self->internal_error_response($raw_url, "Form data has been truncated.");
    }

#    use Data::Dumper; warn Dumper $cgi;

    # Initialize our internal data storage.
    $self->{'CGI'} = {
        cgi         => $cgi,
        headers     => {},
        got_cookies => {},
        set_cookies => {},
    };

    # Look for cookies.
    $self->parse_cookies();

    # Check if there ware Server Side Image Map coordinates.
    # If so, append them to options.
    my %options = $self->check_for_ssim();

    foreach my $param ($cgi->param()) {
        $options{ $param .q{-filename} } = decode_utf8( $cgi->param_filename($param) or q{} );

        if ($options{ $param .q{-filename} }) {
            # It was a data file. Leave, as is.
            $options{$param} = $cgi->param($param);
        }
        else {
            $options{$param} = decode_utf8($cgi->param($param));
        }
    }

#    print "URL: ". $raw_url ."\n";
#    print "WRU: ". $web_root ."\n";
#    use Data::Dumper; warn Dumper \%ENV;
#     use Data::Dumper; warn Dumper \%options;

    # Can we replace defaults with something sane?
    if ($raw_url =~ m{^$web_root}s) {
        $url_string = $raw_url;
    }

    # Try to parse URL string.
    my $url_hash = SLight::Core::URL::parse_url($url_string);

#    use Data::Dumper; print Dumper $url_hash;

    # Use default location, if parsing fails.
    if (not $url_hash) {
        $url_hash = SLight::Core::URL::parse_url('/Content/');
    }

    # Define the default language.
    # Request will use this value only, if it can not find any beter choice.
    my $default_language = $self->default_language_from_browser($ENV{'HTTP_ACCEPT_LANGUAGE'});

    # And finally: run request.
    my $request_result = $self->run_request(
        session_id   => $self->{'CGI'}->{'got_cookies'}->{$session_cookie}->{'value'},
        url          => $url_hash,
        options      => \%options,
        default_lang => $default_language,
    );

#    use Data::Dumper; warn 'safe_main R: '. Dumper $request_result;

    $self->set_cookie(
        name  => $session_cookie,
        value => SLight::Core::Session::session_id(),
    );

    return $request_result;
} # }}}

################################################################################
# HTTP Cookies support.
################################################################################

# Parse Cookies, if we got them from the server.
sub parse_cookies { # {{{
    my ( $self ) = @_;

    if ($ENV{'HTTP_COOKIE'}) {
        foreach my $cookie (split /;\s*/s, $ENV{'HTTP_COOKIE'}) {
            my ($n, $v) = split /=/s, $cookie;
            $n  =~ s/ //sg;
            $v  =~ s/ //sg;

            $n = $self->{'CGI'}->{'cgi'}->url_decode($n);
            $v = $self->{'CGI'}->{'cgi'}->url_decode($v);

            $self->{'CGI'}->{'got_cookies'}->{$n}->{'value'} = $v;
        }
    }
    
#    use Data::Dumper; warn Dumper $self->{'CGI'}->{'got_cookies'};

    return;
} # }}}

# Set some cookie in the response.
sub set_cookie { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            name  => { type=>SCALAR },
            value => { type=>SCALAR },
        }
    );
    
    $self->{'CGI'}->{'set_cookies'}->{ $P{'name'} }->{'value'} = $P{'value'};

    return;
} # }}}

################################################################################
# HTTP Headers interface.
################################################################################

# Set one HTTP header.
sub set_header { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            name  => { type=>SCALAR },
            value => { type=>SCALAR },
        }
    );

    return $self->{'CGI'}->{'headers'}->{ lc $P{'name'} } = $P{'value'};
} # }}}

# Returns headers, that should be sent to the browser, as a string.
# If there ware any Cookies set, they will also be included.
#
# Quote things, that should be quotted!
sub headers_string { # {{{
    my ( $self ) = @_;

    my $headers_string = q{};

    foreach my $name (keys %{ $self->{'CGI'}->{'headers'} }) {
        if (defined $self->{'CGI'}->{'headers'}->{$name}) {
            $headers_string .= $name .q{: }. $self->{'CGI'}->{'headers'}->{$name} .qq{\n};
        }
    }

    foreach my $name (sort keys %{ $self->{'CGI'}->{'set_cookies'} }) {
        $headers_string .= 'Set-Cookie: '. $self->{'CGI'}->{'cgi'}->url_encode($name) .q{=}. $self->{'CGI'}->{'cgi'}->url_encode($self->{'CGI'}->{'set_cookies'}->{$name}->{'value'}) ."; path=/\n"; # fixme: path!
    }

#    warn "Headers string:".  $headers_string;

    return $headers_string;
} # }}}

################################################################################
# Other utility functions.
################################################################################

# Check if there are Server Side Image Map coordinates.
# If yes, return them as '_x_' and '_y_' cgi parameters.
#
# Function always returns hash (either WITH or WITHOUT the options).
sub check_for_ssim { # {{{
    my ( $self ) = @_;

    my %params;

    # Extract server-side-image-map coordinates, if they ware given.
    if ($ENV{'QUERY_STRING'} and $ENV{'QUERY_STRING'} =~ s/^([0-9]+),([0-9]+)$//s) {
        $params{'_x_'} = $1;
        $params{'_y_'} = $2;
    }

    return %params;
} # }}}

# Analize HTTP_ACCEPT_LANGUAGE to get the best language for request.
# This picks the first language, it should pick a list. Possible improvement.
# Other possibility would be to check if language is supported by L10N, and repear the check,
# untill some supported language is found.
#
# Example input:
#   pl,en-us;q=0.7,en;q=0.3
#
# Returns:
#   language code, example: 'en', 'pl', 'foo'.
sub default_language_from_browser { # {{{
    my ( $self, $accept_language ) = @_;
    
    if ($accept_language and $accept_language =~ m{^([a-zA-Z]+)}s) {
        my $lang = $1;

        return lc $lang;
    }

    return 'en';
} # }}}

################################################################################
# Corner case (crash, maintenance, server overload) handling.
################################################################################

sub internal_maintenance_response { # {{{
    my ( $self, $url, $msg ) = @_;

    $self->set_header(
        name  => q{Status},
        value => q{503 Site under maintenance},
    );
    $self->set_header(
        name  => q{Content-type},
        value => 'text/html',
    );

    my $out = $self->_customized_internal_response('Maintenance', $url, $msg);
    if ($out) {
        return $out;
    }

    $out .= "\n";
    $out .= "<html>";
    $out .= "<head><title>Site under maintenance</title></head>\n";
    $out .= "<body style='background-color: silver;'>";
    $out .= "<div style='border: 1px solid #777; background-color: white; padding: 10px; margin: 10px;'>";
    $out .= "503 - <b>Site under maintenance</b> - please return at later time.";

    if ($msg) {
        $out .= q{<br><br><pre>}. $msg .q{</pre>};
    }

    $out .= "</div>";
    $out .= "</html>";

    return $out;
} # }}}

sub internal_error_response { # {{{
    my ( $self, $url, $msg ) = @_;

    $self->set_header(
        name  => q{Status},
        value => q{500 Internal Server error},
    );
    $self->set_header(
        name  => q{Content-type},
        value => 'text/html',
    );

    my $home_email = SLight::Core::Config::get_option('mailback');
    if ($home_email and $ENV{'REMOTE_ADDR'} and $ENV{'REMOTE_ADDR'} ne '127.0.0.1') {
        # Try to inform "HQ" that We have an internal error here..
        eval {
            require SLight::API::Email;

            SLight::API::Email::send_notification(
                email         => $home_email,
                name          => q{Webmaster},
                notifications => [
                    q{Internal error happened!},
                ],
            );
        };
    }

    my $out = $self->_customized_internal_response('Error', $url, $msg);
    if ($out) {
        return $out;
    }

    $out .= "<html>";
    $out .= "<head><title>Internal Server Error</title></head>\n";
    $out .= "<body style='background-color: silver;'>";
    $out .= "<div style='border: 1px solid #777; background-color: white; padding: 10px; margin: 10px;'>";
    $out .= "500 - <b>Internal Server Error</b> - please retry.";

    if ($msg) {
        $out .= q{<br><br><pre>}. $msg .q{</pre>};
    }

    $out .= "</div>";
    $out .= "</html>";

    return $out;
} # }}}

sub _customized_internal_response { # {{{
    my ( $self, $type, $url, $msg ) = @_;

    my $proto = 'web';
    if ($url =~ m{\.(web|json)$}s) {
        $proto = $1;
    }

    if (not $self->{'internal_response'}->{$type}->{$proto}) {
        return;
    }

    my $out = $self->{'internal_response'}->{$type}->{$proto};

    if (defined $msg) {
        # If message was provided, replace it in the "template".
        $out =~ s{<!--\s*message_goes_here\s*-->}{$msg}gis;
    }
    else {
        # Clear any message placeholders that are present in the "template".
        $out =~ s{<!--\s*message_goes_here\s*-->}{}gi;
    }

    my %mime_map = (
        web  => 'text/html; character-set: utf-8',
        json => 'application/json; character-set: utf-8',
    );

    $self->set_header(
        name  => q{Content-type},
        value => ($mime_map{$proto} or 'text/html')
    );

    return $out;
} # }}}

# vim: fdm=marker
1;
