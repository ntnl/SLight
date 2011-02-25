#!/usr/bin/perl
# Test for Text DataType
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin .q{/../../lib/};
use utf8;

use English qw{ -no_match_vars };

use SLight::Test::DataType;
# }}}

my @validate_tests = (
# Currently validate passes all...
#    {
#        name   => 'With newlines',
#        value  => qq{ Ala\nMa\nKota },
#        expect => q{More then one line},
#    }
);

my @encode_tests = (
    {
        name   => 'Simple, single line text',
        value  => 'FooBar',
        expect =>
            qq{--- \n}.
            qq{- \n}.
            qq{  - FooBar\n},
    },
    {
        name   => 'Remove white characters from simple text',
        value  => ' Foo Bar Baz ',
        expect =>
            qq{--- \n}.
            qq{- \n}.
            qq{  - Foo Bar Baz\n},
    },
    {
        name   => 'Simple newline',
        value  => qq{\n},
        expect =>
            qq{--- \n}.
            qq{- \n}.
            qq{  - \n}.
            qq{    tag: br\n},
    },
    {
        name   => 'Remove white characters from multiline text',
        value  => " Foo Bar Baz \nAla ma Kota \n  Zosia ma Psa  ",
        expect =>
            qq{--- \n}.
            qq{- \n}.
            qq{  - Foo Bar Baz\n}.
            qq{  - \n}.
            qq{    tag: br\n}.
            qq{  - Ala ma Kota\n}.
            qq{  - \n}.
            qq{    tag: br\n}.
            qq{  - Zosia ma Psa\n},
    },
    {
        name   => "Two lines in two paragraphs",
        value  => "Ala ma Kota\n\nOla ma Psa",
        expect =>
            qq{--- \n}.
            qq{- \n}.
            qq{  - Ala ma Kota\n}.
            qq{- \n}.
            qq{  - Ola ma Psa\n},
    },
    {
        name   => "Two paragraphs with BBCode",
        value  => "Ala [b]ma[/b] Kota\n\nOla ma [i]Psa[/i]",
        expect =>
            qq{--- \n}.
            qq{- \n}.
            qq{  - "Ala "\n}.
            qq{  - \n}.
            qq{    ct: ma\n}.
            qq{    tag: b\n}.
            qq{  - " Kota"\n}.
            qq{- \n}.
            qq{  - "Ola ma "\n}.
            qq{  - \n}.
            qq{    ct: Psa\n}.
            qq{    tag: i\n},
    },
    {
        name   => 'Tags with parameters',
        value  => 'Foo [url=http://foo.com]Bar[/url] Baz',
        expect =>
            qq{--- \n}.
            qq{- \n}.
            qq{  - "Foo "\n}.
            qq{  - \n}.
            qq{    ct: Bar\n}.
            qq{    tag: url\n}.
            qq{    value: http://foo.com\n}.
            qq{  - " Baz"\n},
    },
    {
        name   => 'Nested tags - use case 1',
        value  => ' Foo [b][i]Bar[/i][/b] Baz ',
        expect =>
            qq{--- \n}.
            qq{- \n}.
            qq{  - "Foo "\n}.
            qq{  - \n}.
            qq{    ct: \n}.
            qq{      ct: Bar\n}.
            qq{      tag: i\n}.
            qq{    tag: b\n}.
            qq{  - " Baz"\n},
    },
    {
        name   => 'Nested tags - use case 1',
        value  => ' Foo [b]([i]Bar[/i])[/b] Baz ',
        expect =>
            qq{--- \n}.
            qq{- \n}.
            qq{  - "Foo "\n}.
            qq{  - \n}.
            qq{    ct: \n}.
            qq{      - (\n}.
            qq{      - \n}.
            qq{        ct: Bar\n}.
            qq{        tag: i\n}.
            qq{      - )\n}.
            qq{    tag: b\n}.
            qq{  - " Baz"\n},
    },
    {
        name   => 'Rich text in quotes',
        value  => "John said:\n\n[quote]\nThis is a [b]rich[/b] text.\n\nI [i]like[/i] it!\n[/quote]\n\nI agree with John.",
        expect =>
            qq{--- \n}.
            qq{- \n}.
            qq{  - "John said:"\n}.
            qq{- \n}.
            qq{  - \n}.
            qq{    ct: \n}.
            qq{      - "This is a "\n}.
            qq{      - \n}.
            qq{        ct: rich\n}.
            qq{        tag: b\n}.
            qq{      - " text."\n}.
            qq{      - \n}.
            qq{        tag: br\n}.
            qq{      - \n}.
            qq{        tag: br\n}.
            qq{      - "I "\n}.
            qq{      - \n}.
            qq{        ct: like\n}.
            qq{        tag: i\n}.
            qq{      - " it!"\n}.
            qq{    tag: quote\n}.
            qq{- \n}.
            qq{  - I agree with John.\n},
    },
);

my @decode_tests = (
    {
        name       => 'Crash test - handle broken YAML (FORM)',
        value      => "--- \nFooBar: { } : baz",
        expect     => "--- \nFooBar: { } : baz",
        target     => 'FORM'
    },
    {
        name       => 'Backward compatibility - pass strings around as they are (FORM)',
        value_yaml => 'FooBar',
        expect     => 'FooBar',
        target     => 'FORM'
    },
    {
        name       => 'Backward compatibility - pass strings around as they are (LIST)',
        value_yaml => 'FooBar',
        expect     => 'FooBar',
        target     => 'LIST'
    },
    {
        name       => 'Backward compatibility - pass strings around as they are (MAIN)',
        value_yaml => 'FooBar',
        expect     => 'FooBar',
        target     => 'MAIN'
    },
    {
        name       => 'Simple, single line text',
        value_yaml => [
            [
                'FooBar'
            ],
        ],
        expect => 'FooBar',
        target => 'FORM'
    },
    {
        name        => 'Three lines of text',
        value_yaml  => [
            [
                "Foo Bar Baz",
                { tag=>'br' },
                "Ala ma Kota",
                { tag=>'br' },
                "Zosia ma Psa",
            ]
        ],
        expect => "Foo Bar Baz\nAla ma Kota\nZosia ma Psa",
        target => 'FORM'
    },
    {
        name       => "Two lines in two paragraphs",
        value_yaml => [
            [ "Ala ma Kota" ],
            [ "Ola ma Psa" ],
        ],
        expect => "Ala ma Kota\n\nOla ma Psa",
        target => 'FORM'
    },
    {
        name       => "Two lines in two paragraphs - MAIN",
        value_yaml => [
            [ "Ala ma Kota" ],
            [ "Ola ma Psa" ],
        ],
        expect => [
            [ "Ala ma Kota" ],
            [ "Ola ma Psa" ],
        ],
        target => 'MAIN'
    },
    {
        name       => "Two lines in two paragraphs - LIST",
        value_yaml => [
            [ "Ala ma Kota" ],
            [ "Ola ma Psa" ],
        ],
        expect => [
            [ "Ala ma Kota" ],
        ],
        target => 'LIST'
    },
    {
        name       => "Two paragraphs with BBCode - FORM",
        value_yaml => [
            [
                "Ala ", { tag=>'b', ct=>"ma" }, " Kota"
            ],
            [
                "Ola ma ", { tag=>'i', ct=>"Psa" }
            ]
        ],
        expect => "Ala [b]ma[/b] Kota\n\nOla ma [i]Psa[/i]",
        target => 'FORM'
    },
    {
        name       => 'Single tag',
        value_yaml => [
            [
                'Foo',
                { tag=>'separate' },
                'Bar'
            ],
        ],
        expect => 'Foo[separate]Bar',
        target => 'FORM'
    },
    {
        name       => 'Single tag with content and value',
        value_yaml => [
            [
                { tag=>'url', ct=>'http://jakarta.project/', value=>'http://jakarta.project/SuperStar' },
            ],
        ],
        expect => '[url=http://jakarta.project/SuperStar]http://jakarta.project/[/url]',
        target => 'FORM'
    },
);

SLight::Test::DataType::run_tests(
    type => 'Text',

    validate_tests => \@validate_tests,
    encode_tests   => \@encode_tests,
    decode_tests   => \@decode_tests,
);

# vim: fdm=marker
