package SLight::Core::URL;
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
use base 'Exporter';

use SLight::Core::Config;

use Params::Validate qw( :all );
use URI::Escape;
# }}}

our $VERSION = '0.0.1';

our @EXPORT_OK = qw(
    parse_url
    make_url
);

# Two no-critic's bellow are critic bugs :( there are no punctation vars, yet perlcritic sees them :(
my $re_language    = qr{ ^ ( [a-z] [a-z] ( _ [a-z] [a-z] )? )? $ }xs;
my $re_perl_module = qr{ [A-Z] [a-z] [A-Za-z]+ }xs;
my $re_step        = qr{ ^ [a-z]{3,} $ }xs;

# SLight Nice url:
# 
#   /_Page/bar/baz/Action-step-pl-page.web
#   |  1  |   2   |        3
#
#   1: Path Handler package
#       Optional.
#       Default: 'Page'
#       Leading underscore is ignored.
#       Maps 1:1 to a Perl module from SLight::PathHandler::*
#       Defines which module will be responsible to define page contents (object classes and IDs).
#
#   2: Path
#       Meaning varies, depending on the PathHandler.
#       Default: '/'
#
#   3: Page component
#       Optional.
#       Default: Overview.web
#
#       Foo-bar-pl-1.web
#        |   |  |  |  '--- Protocol handler. Mandatory.
#        |   |  |  '--- Optional. Page. Default: 1
#        |   |  '--- Optional. Language. Default - first language from the config.
#        |   '--- Optional. Step - method (handle_*) from the Action.
#        '--- Action - what Handler object to use.
#
# Returned data structure: SLight URL Hash
# {
#   path_handler => string,
#   path         => array,
#
#   action => string,
#   step   => string,
#   lang   => string,
#   page   => integer,
#
#   protocol => string,
# }
#
# If URL can not be parsed, return 'undef'.
sub parse_url { # {{{
    my ( $string ) = @_;

    # Discard any CGI_QUERY, it is handled in smart way.
    $string =~ s{\?.*}{}s;

    # Remove Web Root from the URL
    my $web_root = SLight::Core::Config::get_option('web_root');
    $string =~ s{^$web_root/?}{/}s;

    #               2 ---.                          5 ---..--- 6
    #            1 ---.  |             3 ---..--- 4      ||         .--- 7
    #                 |  |                  ||           ||         |
#    if ($string =~ m{^(/_($re_perl_module))?((/[^/]+)*)}s) {
    if ($string =~ m{^(/_($re_perl_module))?((/[^/]+)*)/(([^\.]+)\.([^\.]+))?$}s) {
#        warn "1($1) 2(". ($2 or q{}) .") 3($3) 4(". ($4 or q{}) .") 5($5)";

        my %url_hash = (
            path_handler => ( $2 or 'Page' ),
            path         => [ split /\//s, $3 ],

            # Defaults:
            action => 'Overview',
            step   => 'view',
            lang   => q{},
            page   => 1,

            protocol => ( $7 or 'web' ),
        );
        shift @{ $url_hash{'path'} };

        if ($5) {
            my $action_part = $6;

            my @action_parts = split /\-/s, $action_part;
            foreach my $part (@action_parts) {
                if ($part =~ $re_perl_module) {
                    $url_hash{'action'} = $part;

                    next;
                }

                if ($part =~ m{^\d+$}s) {
                    $url_hash{'page'} = $part;

                    next;
                }

                if ($part =~ $re_step) {
                    $url_hash{'step'} = $part;

                    next;
                }

                if ($part =~ $re_language) {
                    $url_hash{'lang'} = $part;

                    next;
                }
            }
        }

        return \%url_hash;
    }

    return carp("Unable to parse URL: ". $string);
} #  }}}

# Return an URL, as a string, that is made from given options.
sub make_url { # {{{
    my %P = validate(
        @_,
        {
            path_handler => { type=>SCALAR,   optional=>1, default=>'Page' },
            path         => { type=>ARRAYREF, optional=>1, default=>[] },

            action => { type=>SCALAR,  regex=>$re_perl_module, optional=>1, default=>'Overview'},
            step   => { type=>SCALAR,  regex=>$re_step,        optional=>1, default=>'view' },
            lang    => { type=>SCALAR, regex=>$re_language,    optional=>1 },
            page    => { type=>SCALAR, regex=>qr{^\d+$}s,      optional=>1 }, ## no critic qw(Variables::ProhibitPunctuationVars)

            protocol => { type=>SCALAR, optional=>1, default=>'web' },

            options => { type=>HASHREF, optional=>1 },

            add_domain => { type=>SCALAR, optional=>1 },

            debug_switch => { type=>HASHREF, optional=>1, },
        }
    );

    # Normally, hostname and protocol are not needed..
    my $base = q{};
    if ($P{'add_domain'}) {
        $base = q{http://} . SLight::Core::Config::get_option('domain');
    }

    my $url = $base . SLight::Core::Config::get_option('web_root');

    if ($P{'path_handler'} and $P{'path_handler'} ne 'Page') {
        $url .= q{_} . $P{'path_handler'} . q{/};
    }
    
    if (scalar @{ $P{'path'} }) {
        $url .= join q{/}, @{ $P{'path'} };
        $url .= q{/};
    }

    my @file_parts;
    if ($P{'action'} and $P{'action'} ne 'Overview') {
        push @file_parts, $P{'action'};
    }

    if ($P{'step'} and $P{'step'} ne 'view') {
        push @file_parts, $P{'step'};
    }

    if ($P{'lang'}) {
        push @file_parts, $P{'lang'};
    }

    if ($P{'page'} and $P{'page'} > 1) {
        push @file_parts, $P{'page'};
    }

    my $file_string = 'Overview';
    if (scalar @file_parts) {
        $file_string = join q{-}, @file_parts;
    }

    $file_string .= q{.};

    $file_string .= lc $P{'protocol'};

    if ($file_string ne 'Overview.web') {
        $url .= $file_string;
    }

    if ($P{'debug_switch'}) {
        $P{'options'}->{'D'} = join q{-}, sort grep { $P{'debug_switch'}->{$_} } keys %{ $P{'debug_switch'} };
    }

    # Add CGI options?
    if ($P{'options'}) {
        my @pairs;
        foreach my $name (keys %{ $P{'options'} }) {
            push @pairs, uri_escape_utf8($name) . q{=} . uri_escape_utf8($P{'options'}->{$name});
        }

        if (scalar @pairs) {
            $url .= q{?} . join q{&}, @pairs;
        }
    }

    return $url;
} # }}}

# vim: fdm=marker
1;
