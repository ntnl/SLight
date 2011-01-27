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
use FindBin qw{ $Bin };
use lib $Bin . q{/../../lib/};

use Test::More;
use SLight::Test::Runner qw( run_tests );
# }}}

use SLight::Output::HTML::Generator;

my @tests = (
    # Tests for tructure_to_html
    {
        name     => 'structure_to_html: \'undef\' handling',
        callback => \&SLight::Output::HTML::Generator::structure_to_html,
        args     => [ undef ],
    },
    {
        name     => 'structure_to_html: string handling',
        callback => \&SLight::Output::HTML::Generator::structure_to_html,
        args     => [ "Foo - the test string of tommorow" ],
    },
    {
        name     => 'structure_to_html: One simple line',
        callback => \&SLight::Output::HTML::Generator::structure_to_html,
        args     => [ [ 'foo' ] ],
    },
    {
        name     => 'structure_to_html: One simple paragtaph',
        callback => \&SLight::Output::HTML::Generator::structure_to_html,
        args     => [ [ [ 'foo' ] ] ],
    },
    {
        name     => 'structure_to_html: Two simple paragtaphs',
        callback => \&SLight::Output::HTML::Generator::structure_to_html,
        args     => [ [ [ 'foo' ], [ 'bar' ] ] ],
    },
    {
        name     => 'structure_to_html: One paragraph with two lines',
        callback => \&SLight::Output::HTML::Generator::structure_to_html,
        args     => [ [ [ 'foo', { tag=>'br' }, 'bar' ] ] ],
    },
    {
        name     => 'structure_to_html: Single token',
        callback => \&SLight::Output::HTML::Generator::structure_to_html,
        args     => [ { tag=>'url', ct=>'www.foo.com', value=>'http://www.foo.com/index.html' } ],
    },

    # Tests for token_to_html
    {
        name     => 'token_to_html: Undef',
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ undef ],
    },
    {
        name     => 'token_to_html: String',
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ 'Foo' ],
    },
    {
        name     => 'token_to_html: Two strings in array',
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ [ 'Foo', 'Bar' ] ],
    },

    # Unit testing of all supported BBCode tags.
    {
        name => "token_to_html: unit test: b",
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ { tag=>'b', ct=>"Lorem Ipsum" } ],
    },
    {
        name => "token_to_html: unit test: i",
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ { tag=>'i', ct=>"Lorem Ipsum" } ],
    },
    {
        name => "token_to_html: unit test: u",
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ { tag=>'u', ct=>"Lorem Ipsum" } ],
    },
    {
        name => "token_to_html: unit test: s",
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ { tag=>'s', ct=>"Lorem Ipsum" } ],
    },
    {
        name => "token_to_html: unit test: url (value)",
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ { tag=>'url', ct=>'Bar homepage', value=>'http://bar.baz/' } ],
    },
    {
        name => "token_to_html: unit test: url (content)",
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ { tag=>'url', ct=>'http://bar.baz/' } ],
    },
    {
        name => "token_to_html: unit test: img (value)",
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ { tag=>'img', value=>'http://foo.com/img.gif' } ],
    },
    {
        name => "token_to_html: unit test: img (content)",
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ { tag=>'img', ct=>'http://foo.com/img.gif' } ],
    },
    {
        name => "token_to_html: unit test: quote",
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ { tag=>'quote', ct=>'Lorem ipsum lorem est' } ],
    },
    {
        name => "token_to_html: unit test: code",
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ { tag=>'code', ct=>q{$foo = $bar + 1;} } ],
    },
    {
        name => "token_to_html: unit test: size",
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ { tag=>'size', value=>'100', ct=>"Lorem Ipsum" } ],
    },
    {
        name => "token_to_html: unit test: color",
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ { tag=>'color', value=>'blue', ct=>"Lorem Ipsum" } ],
    },
    {
        name => "token_to_html: unit test: br",
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ { tag=>'br' } ],
    },
    {
        name => "token_to_html: unit test: separate",
        callback => \&SLight::Output::HTML::Generator::token_to_html,
        args     => [ { tag=>'separate' } ],
    },
);

run_tests(
    tests => \@tests,
);

# vim: fdm=marker
