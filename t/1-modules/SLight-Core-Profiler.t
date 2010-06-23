#!/usr/bin/perl
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
use FindBin qw{ $Bin };
use lib $Bin .'/../../lib/';

use Test::More;
use Test::Exception;
use utf8;
# }}}

use SLight::Core::Profiler qw(
    task_starts
    task_ends
    task_switch
);

plan tests =>
    + 2 # task_starts
    + 4 # task_switch
    + 3 # task_ends
;

lives_ok {
    task_starts('Test 1');
} "task_start - usable";
dies_ok {
    task_starts();
} "task_start - crash test";


lives_ok {
    task_switch('Test 1', 'Test 2');
} "task_switch - usable";
dies_ok {
    task_switch('Test 1');
} "task_switch - crash test - missing second id";
dies_ok {
    task_switch();
} "task_switch - crash test - missing first id";
dies_ok {
    task_switch('Test A', 'Test B');
} "task_switch - crash test - bad id";


lives_ok {
    task_ends('Test 2');
} "task_ends - usable";
dies_ok {
    task_ends();
} "task_ends - crash test - no input";
dies_ok {
    task_ends('Test foo');
} "task_ends - crash test - bad id";

# vim: fdm=marker
