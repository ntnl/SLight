#!/usr/bin/perl
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
use FindBin qw( $Bin );
use lib $Bin .'/../../lib/';

use SLight::Test::DataStructure qw( run_datastructure_tests );

use English qw( -no_match_vars );
# }}}

my %tests = (
    'full_blown_example' => {
        params => {
            action  => q{/FormAction/},
            hidden  => {
                test_1 => 'one',
                test_2 => 'two',
            },
            submit  => 'Commit test',
            preview => 'Preview test',
            class   => 'Test_Form_DS',
        },
        tests => [
            {
                name   => q{add_Entry},
                method => q{add_Entry},
                args   => [
                    name    => q{t_string},
                    caption => q{Sample string entry},
                    value   => q{Foo Foo Foo},
                    error   => q{String has issues},
                ],
                expect => 'undef',
            },
            {
                name   => q{add_PasswordEntry},
                method => q{add_PasswordEntry},
                args   => [
                    name    => q{t_password},
                    caption => q{Sample password entry},
                    value   => q{},
                    error   => q{Password has issues},
                ],
                expect => 'undef',
            },
            {
                name   => q{add_TextEntry},
                method => q{add_TextEntry},
                args   => [
                    name    => q{t_text},
                    caption => q{Sample text entry},
                    value   => q{Ala ma cota}, # Means: "Ala has a cat"
                    error   => q{Text has issues},
                ],
                expect => 'undef',
            },
            {
                name   => q{add_SelectEntry},
                method => q{add_SelectEntry},
                args   => [
                    name    => q{t_select},
                    caption => q{Sample select entry},
                    value   => q{Foo},
                    error   => q{Select has issues},
                    options => [
                        [ q{Foo}, q{1: Foo} ],
                        [ q{Bar}, q{2: Bar} ],
                        [ q{Baz}, q{3: Baz} ],
                    ],
                ],
                expect => 'undef',
            },
            {
                name   => q{add_FileEntry},
                method => q{add_FileEntry},
                args   => [
                    name    => q{t_file},
                    caption => q{Sample file entry},
                    error   => q{File has issues},
                ],
                expect => 'undef',
            },
            {
                name   => q{add_Check},
                method => q{add_Check},
                args   => [
                    name    => q{t_check},
                    caption => q{Sample check},
                    checked => 1,
                    error   => q{Check has issues},
                ],
                expect => 'undef',
            },
            {
                name   => q{add_Label},
                method => q{add_Label},
                args   => [
                    text  => q{Sample label},
                    class => q{Normal},
                ],
                expect => 'undef',
            },
            {
                name   => q{add_Action},
                method => q{add_Action},
                args   => [
                    class   => q{Finalize},
                    href    => q{/Foo/Bar/},
                    caption => q{Sample action},
                ],
                expect => 'undef',
            },
        ],
    },
);

run_datastructure_tests(
    tests => \%tests,

    structure => 'Form'
);

# vim: fdm=marker
