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
use lib $Bin .'/../../lib/';

use Test::More;
# }}}

use SLight::Output::HTML::Template;

plan tests =>
    + 2 # Load template, parse HTML.
    + 2 # Render empty template
    + 4 # Add various data
    + 2 # Render full template
    
    + 2 # check if fetching from cache works...

# Broken!
#    + 4 # has_*

    # Simple tests for different features/use cases.
    + 2 # Static html test.
    + 2 # No blocks html test.
    + 2 # TRUE/FALSE

    # Smoke-testing advanced layout making.
    + 1 # process_element_GridItem
    + 1 # process_element_Grid
    + 1 # process_element_Form
    + 1 # process_element_ProgressBar
    + 2 # process_element_TextEntry
    + 1 # process_element_FileEntry
    + 2 # process_element_Status
    + 1 # process_element_Radio
    + 1 # process_element_SelectEntry
    + 1 # process_element_Image
    + 1 # process_element_Check

    # Problematic use cases:
    + 2 # no blocks, placeholders and includes.
;

# This will force the template to parse HTML.
if (-f $Bin .'/SLight-Output-HTML-Template/example.yaml') {
    unlink $Bin .'/SLight-Output-HTML-Template/example.yaml';
}

my $template_1 = SLight::Output::HTML::Template->new(
    name => 'example',
    dir  => $Bin .'/SLight-Output-HTML-Template',
);
isa_ok($template_1, 'SLight::Output::HTML::Template', "Template object created");
is ($template_1->source(), 'HTML', 'Was loaded from html');

my $result = $template_1->render();

ok($result, 'Result - empty generated');
is (
    $result,
    "<html>
    <head>
        <title></title>
    </head>
    <body>

    Addition starts here.



Block 1: 
Block 2: 

Nested blocks:


Addtion ends here.



    Small placeholders: 

    </body>
</html>
",
    "Result - is empty"
);

ok ($template_1->set_var( 'block1', 'Block IS IN template' ), 'Adding single var');
ok ($template_1->set_var( 'title', 'Test template' ), 'Adding title');

ok ($template_1->set_vars(A=>"First\n", B=>"Second\n", C=>"Third\n"), 'Adding many vars');

ok(
    $template_1->set_list(
        name => 'list_A',
        data => [
            {
                first  => 'yes',
                second => 'no',

                left => 1,
            },
            {
                first  => 'no',
                second => 'yes',
                
                right => 1,
            }
        ]
    ),
    'Adding list'
);

$result = $template_1->render();

ok($result, 'Result - full generated');
is (
    $result,
    "<html>
    <head>
        <title>Test template</title>
    </head>
    <body>

    Addition starts here.

    This is block 1.

    Block IS IN template


Block 1: Block IS IN template
Block 2: 

Nested blocks:


Addtion ends here.


    Header A.
        Item A.
    First var: yes
    Second var: no

    Left!
        Item A.
    First var: no
    Second var: yes

    Right!
        Footer A.
    
    Small placeholders: First
Second
Third


    </body>
</html>
",
    "Result - is full"
);

# In this case, missing 'foo' should be ignored, existing 'example' loaded, and 'bar' skipped.
my $template_2 = SLight::Output::HTML::Template->new(
    name => [ 'foo', 'example', 'bar' ],
    dir  => $Bin .'/SLight-Output-HTML-Template',
);
isa_ok($template_2, 'SLight::Output::HTML::Template', "Template object created, cached");
is ($template_2->source(), 'YAML', 'Was loaded from yaml');

#is ($template_2->has_var('zzbbzz'),  0, 'has_var negative');
#is ($template_2->has_list('zzbbzz'), 0, 'has_list negative');
#is ($template_2->has_grid('zzbbzz'), 0, 'has_grid negative');
#is ($template_2->has_form('zzbbzz'), 0, 'has_form negative');

# Static HTML test.
my $template_3 = SLight::Output::HTML::Template->new(
    name => [ 'example3' ],
    dir  => $Bin .'/SLight-Output-HTML-Template',
);
isa_ok($template_3, 'SLight::Output::HTML::Template', "Static HTML - object OK");
$result = $template_3->render();
is($result, '<html>
    <head><title>Static HTML</title></head>
    <body>There are no dynamic parts here.</body>
</html>
', "Static HTML - result OK");

# No blocks HTML test.
my $template_4 = SLight::Output::HTML::Template->new(
    name => [ 'example4' ],
    dir  => $Bin .'/SLight-Output-HTML-Template',
);
isa_ok($template_4, 'SLight::Output::HTML::Template', "No blocks HTML - object OK");
$template_4->set_var( 'title', 'No blocks HTML' );
$result = $template_4->render();
is($result, '<html>
    <head><title>No blocks HTML</title></head>
    <body>There are no dynamic parts here.</body>
</html>
', "Static HTML - result OK");

# TRUE/FALSE
my $template_5 = SLight::Output::HTML::Template->new(
    name => [ 'example5' ],
    dir  => $Bin .'/SLight-Output-HTML-Template',
);
isa_ok($template_5, 'SLight::Output::HTML::Template', "TRUE/FALSE - object OK");
$template_5->set_var( 'value1', 1 );
$template_5->set_var( 'value2', 0 );
$result = $template_5->render();
is($result, '<html>
    <head><title>TRUE/FALSE</title></head>
    <body>
Value 1 is true.
Value 2 is false.
    </body>
</html>
', "Static HTML - result OK");

# process_element_SelectEntry
is_deeply (
    {
        SLight::Output::HTML::Template::process_element_SelectEntry(
            {
                name    => 'foo',
                options => [ [ 1, 'Bar' ], [ 2, 'Baz' ], [ 3, 'Bzz' ] ],
                value   => 2,
            }
        )
    },
    {
        Name    => q{foo},
        Options => qq{<option value='1'>Bar\n<option value='2' selected>Baz\n<option value='3'>Bzz\n},
    },
    'process_element_SelectEntry'
);
# process_element_SelectEntry
is_deeply (
    {
        SLight::Output::HTML::Template::process_element_FileEntry(
            {
                name    => 'foo',
            }
        )
    },
    {
        Name => q{foo},
    },
    'process_element_FileEntry'
);

# process_element_Form
is_deeply (
    {
        SLight::Output::HTML::Template::process_element_Form(
            {
                action => '/Foo.cgi',
                submit => 'Save',
                hidden => {
                    Ala  => 'Kota',
                    Jola => 'Misio',
                }
            }
        )
    },
    {
        Action => '/Foo.cgi',
        Submit => 'Save',
        Hidden => q{<input type=hidden name="Ala" value="Kota"><input type=hidden name="Jola" value="Misio">},
    },
    'process_element_Form'
);
# process_element_Check
is_deeply (
    { SLight::Output::HTML::Template::process_element_Check( { checked=>1, name=>'Foo' } ) },
    {
        Name    => 'Foo',
        Checked => 1,
    },
    'process_element_Check'
);

# process_element_Radio
is_deeply (
    { SLight::Output::HTML::Template::process_element_Radio( {} ) },
    {},
    'process_element_Radio'
);

# process_element_Image
is_deeply (
    { SLight::Output::HTML::Template::process_element_Image( { href=>'/Foo/Bar/Baz', label=>'Foo Bar' } ) },
    {
        Href  => '/Foo/Bar/Baz',
        Label => 'Foo Bar'
    },
    'process_element_Image'
);

# process_element_GridItem
is_deeply (
    { SLight::Output::HTML::Template::process_element_GridItem( {} ) },
    {},
    'process_element_GridItem'
);

# process_element_Grid
is_deeply (
    { SLight::Output::HTML::Template::process_element_Grid( {} ) },
    {},
    'process_element_Grid'
);

# process_element_ProgressBar
is_deeply (
    {
        SLight::Output::HTML::Template::process_element_ProgressBar(
            {
                bar_class => 'Running',
                bar_range => '255',
                bar_value => '128',
            }
        )
    },
    {
        BarClass => 'Running',
        BarRange => '255',
        BarValue => '128',
        Percent  => '50',
    },
    'process_element_ProgressBar'
);

# process_element_TextEntry
is_deeply (
    { SLight::Output::HTML::Template::process_element_TextEntry( {} ) },
    { Name=>q{}, Value=>q{} },
    'process_element_TextEntry (1)'
);
is_deeply (
    { SLight::Output::HTML::Template::process_element_TextEntry( {name=>'Foo', value=>'Bar'} ) },
    { Name=>'Foo', Value=>'Bar' },
    'process_element_TextEntry (2)'
);

# process_element_Status
is_deeply (
    { SLight::Output::HTML::Template::process_element_Status( {} ) },
    { Status=>q{} },
    'process_element_Status (1)'
);
is_deeply (
    { SLight::Output::HTML::Template::process_element_Status( {status=>'OK'} ) },
    { Status=>'OK' },
    'process_element_Status (2)'
);

# Problematic use cases

# 'no blocks, placeholders and includes'
my $template_6 = SLight::Output::HTML::Template->new(
    name => [ 'example2' ],
    dir  => $Bin .'/SLight-Output-HTML-Template',
);
$template_6->set_vars(A=>"First\n", B=>"Second\n", C=>"Third\n");

$result = $template_6->render();

ok($result, 'no blocks, placeholders and includes - generated');
is (
    $result,
    "<html>
    <head>
        <title></title>
    </head>
    <body>

    Small Addition.


    Small placeholders: First

    Second

    Third


    </body>
</html>
",
    "no blocks, placeholders and includes - is OK"
);

# vim: fdm=marker
