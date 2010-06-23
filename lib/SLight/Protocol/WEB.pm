package SLight::Protocol::WEB;
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
use base q{SLight::Protocol};

use SLight::Core::Config;

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use File::Slurp qw( read_file );
use Params::Validate qw( :all );
# }}}

sub respond { # {{{
    my ( $self, %P ) = @_;

    assert_defined($P{'page'}, 'Page defined');
    assert_defined($P{'url'},  'URL defined');

    my $template_file = SLight::Core::Config::get_option('site_root') . q{/html/} . $P{'page'}->{'template'} . q{.html};

    my $template = read_file($template_file);

    return $self->response_CONTENT(
        $template,
        q{text/html; character-set: utf-8}
    );
} # }}}

# vim: fdm=marker
1;
