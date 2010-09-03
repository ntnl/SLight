package SLight::Output::HTML;
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
use base q{SLight::Output};

use SLight::Core::Config;

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use File::Slurp qw( read_file );
use Params::Validate qw( :all );
# }}}

sub process_object_data { # {{{
    my ( $self ) = @_;

    return;
} # }}}

sub serialize { # {{{
    my ( $self, $object_data, $object_order, $template_code ) = @_;

    my $template_file = SLight::Core::Config::get_option('site_root') . q{/html/} . $template_code . q{.html};

    my $template = read_file($template_file);

    return (
       $template,
        q{text/html; character-set: utf-8}
    );
} # }}}

# vim: fdm=marker
1;