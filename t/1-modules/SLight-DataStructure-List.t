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
use lib $Bin .'/../../lib/';

use SLight::Test::DataStructure qw( run_datastructure_tests );
use SLight::DataToken qw( mk_Link_token );

use English qw( -no_match_vars );
# }}}

my %tests = (
    'full_blown_example' => {
        params => {
            class   => 'Test_List_DS',
            columns => [
                {
                    caption => q{Column 1},
                    name    => q{c1},
                    class   => q{name},
                },
                {
                    caption => q{Column II},
                    name    => q{c2},
                    class   => q{surname},
                },
                {
                    caption => q{Column three},
                    name    => q{c3},
                    class   => q{nickname},
                },
                {
                    caption => q{Column $},
                    name    => q{c4},
                    class   => q{website},
                },
            ],
        },
        tests => [
            {
                name   => q{Add first row},
                method => q{add_Row},
                args   => [
                    class => q{First Odd},
                    data  => {
                        c1 => q{Beata},
                        c2 => q{Zlublina},
                        c3 => q{Beti},
                        c4 => [
                            mk_Link_token(
                                href => q{http://website.of.beti.pl},
                                text => 'Website of Beti',
                            ),
                        ],
                    },
                ],
                expect => 'undef',
            },
            {
                name   => q{Add second row},
                method => q{add_Row},
                args   => [
                    class => q{Second Evel},
                    data  => {
                        c1 => q{Ela},
                        c2 => q{Gwinner},
                        c3 => q{Crea},
                        c4 => [
                            mk_Link_token(
                                href => q{http://www.ela.pl},
                                text => 'www-ELA-pl',
                            ),
                        ],
                    },
                ],
                expect => 'undef',
            },
        ],
    },
);

run_datastructure_tests(
    tests => \%tests,

    structure => 'List'
);

# vim: fdm=marker
