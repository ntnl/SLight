package SLight::Validator::Disk;
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

use SLight::Core::L10N qw( TR TF );
# }}}

# Accept characters, that can be used as file or directory name.
sub v_FileName { # {{{
    my ( $value ) = @_;
    
    if ($value =~ m{[^A-Za-z0-9\-\_\.]}s) {
        return TR("Contains some not allowed characters.");
    }

    return;
} # }}}

# vim: fdm=marker
1;
