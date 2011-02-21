package SLight::Maintenance::Manipulate;
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

my $VERSION = '0.0.3';

use English qw( -no_match_vars );
use Getopt::Long 2.36 qw( GetOptionsFromArray );
# }}}

sub main { # {{{
    my ( @params ) = @_;

    my %options = (
        'cms-list'   => q{},
        'cms-delete' => q{},
        'cms-set'    => q{},
    );

    GetOptionsFromArray(
        \@params,

        'cms-list'   => \$options{'cms-list'},
        'cms-delete' => \$options{'cms-delete'},
        'cms-set'    => \$options{'cms-set'},
        
        'format' => \$options{'format'},
        'input'  => \$options{'input'},

        'help'    => \$options{'help'},
        'version' => \$options{'version'},
    );
    
    use Data::Dumper; warn Dumper \%options;

    # Happy end :)
    return 0;
} # }}}

# vim: fdm=marker
1;
