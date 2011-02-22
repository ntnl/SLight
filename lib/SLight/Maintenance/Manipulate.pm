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
        'output' => \$options{'output'},

        'help'    => \$options{'help'},
        'version' => \$options{'version'},
    );
    
#    use Data::Dumper; warn Dumper \%options;

    if ($options{'version'}) {
        print "\n";
        print "SLight command line manipulation utility.\n";
        print "\n";
        print "SLight version: ". $VERSION ."\n";
        print "\n";
        return 0;
    }

    if ($options{'help'} or not scalar @params) {
        print "\n";
        print "SLight command line manipulation utility.\n";
        print "\n";
        print "Usage:\n";
        print "  slight_manipulate [--option value]\n";
        print "\n";
        print "Options:\n";
        print "\n";
        print "  --cms-list /Path/   List CMS Entities on page /Path/\n";
        print "  --cms-set /Path/    Set CMS Entity on page /Path/ (requires data input)\n";
        print "  --cms-delete /Path/ Delete page /Path/\n";
        print "\n";
        print "  --format zzz  Expect format to be in zzz (one of: XML, JSON or YAML)\n";
        print "  --input file  Read input data from file (default: read from STDIN)\n";
        print "  --output file Put output data into file (default: print to STDOUT)\n";
        print "\n";
        print "  --version Display version and exit.\n";
        print "  --help    Display (this) brief summary.\n";
        print "\n";
    }

    my %functionality = (
        'cms-list'   => \&handle_cms_list,
        'cms-delete' => \&handle_cms_delete,
        'cms-set'    => \&handle_cms_set,
    );

    foreach my $function (keys %functionality) {
        if ($options{$function}) {
            &{ $functionality{$function} }(
                format => $options{'format'},
                input  => $options{'input'},
            );
        }
    }

    # Happy end :)
    return 0;
} # }}}

# Initial implementation should fit one module.
# Later, when more stuff gets added, underlying functionality should probably be moved out.

sub handle_cms_list { # {{{
} # }}}

sub handle_cms_delete { # {{{
} # }}}

sub handle_cms_set { # {{{
} # }}}

# vim: fdm=marker
1;
