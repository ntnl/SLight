package SLight::PathHandlerUtils;
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

use SLight::PathHandlerFactory;

use Carp::Assert::More qw( assert_defined assert_like );
use English qw( -no_match_vars );
use Params::Validate qw( :all );
# }}}

my $_factory = SLight::PathHandlerFactory->new();

sub get_path_target { # {{{
    my ($path_handler, $path) = @_;

    my $path_handler_object = $_factory->make(
        handler => $path_handler
    );
    # Eval is here, because not all PathHandler objects implement this method yet. FIXME later.
    my $target = eval { return $path_handler_object->get_path_target($path); };

    if ($EVAL_ERROR) {
        warn $EVAL_ERROR;
    }

    if ($target) {
        return $target;
    }

    return;
} # }}}

# vim: fdm=marker
1;
