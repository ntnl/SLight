#!/usr/bin/perl
################################################################################
# 
# SLight - Lightweight Content Management System.
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
use FindBin qw( $Bin );
use lib $Bin . '/../lib/';

# }}}

# Change directory to trunk.
chdir $Bin . q{/../};

# Run coverage test:
system _which(q{prove_cover}), q{-j}, 2, q{-r}, q{--no_report}, q{t/};

# Generate report:
system _which(q{cover_report}),
    q{--criterion}, q{statement},
    q{--criterion}, q{branch},
    q{--criterion}, q{condition},
    q{--criterion}, q{subroutine},

    q{--report}, q{summary},
    q{--report}, q{index},
    q{--report}, q{coverage},
    q{--report}, q{runs},
    q{--report}, q{vcs},

    q{--exclude_dir}, q{blib},
    q{--include_dir}, q{lib};

# Push report to 'production':
system q{rsync},
    q{-e}, q{ssh}, q{-z}, q{-r}, q{--delete}, q{--no-implied-dirs}, q{-v},
    q{--exclude}, q{runs}, q{--exclude}, q{structure},
    q{cover_db/}, q{slight-cms.org@slight-cms.org:~/public_html/static/devel/test_coverage_report/};

sub _which { # {{{
    my ( $cmd ) = @_;

    my $fh;
    open $fh, q{-|}, qq{which $cmd};
    my $path = <$fh>;
    close $fh;

    chomp $path;

    return $path;
} # }}}

# vim: fdm=marker

