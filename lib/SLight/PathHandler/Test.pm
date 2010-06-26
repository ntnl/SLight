package SLight::PathHandler::Test;
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
use base q{SLight::PathHandler};

my $VERSION = '0.0.1';

use Carp::Assert::More qw( assert_defined );
# }}}

sub analyze_path { # {{{
    my ( $self, $path ) = @_;

    assert_defined($path, "Path is defined");

    # Note:
    #   This Path handler is designed to mess during unit/automated tests.
    #   Please do not forget that :)

    $self->set_template('Default');

    return $self->response_content();
} # }}}

# vim: fdm=marker
1;
