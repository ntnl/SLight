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
use utf8;

use SLight::Test::Site;
use SLight::API::Page qw( get_Pages_where );

use English qw( -no_match_vars );
use File::Slurp qw( read_file );
use Test::More;
use Test::FileReferenced;
use Test::Output;
# }}}

plan tests =>
    + 3 # standard options...
    + 3 # --cms-list with all three formats.
    + 3 # --cms-get with all three formats.
    + 2 # --cms-delete
;
# Prepare... # {{{
my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Minimal'
);

use SLight::Maintenance::Manipulate;

my $pepper = q{/tmp/manipulate_out_}. $PID . q{/};
mkdir $pepper;
# }}}



# Check standard options support.
output_like(
    sub { 
        SLight::Maintenance::Manipulate::main();
    },
    qr{Usage},
    undef,
    'Run with no params'
);
output_like(
    sub { 
        SLight::Maintenance::Manipulate::main(q{--help});
    },
    qr{Usage},
    undef,
    'Run with --help'
);
output_like(
    sub { 
        SLight::Maintenance::Manipulate::main(q{--version});
    },
    qr{version}s,
    undef,
    'Run with --version'
);


# If it dies, the test will die too, so why bother to check?
SLight::Maintenance::Manipulate::main(q{--cms-get}, q{/}, q{--format}, q{xml},  q{--output}, $pepper . 'get-xml');
SLight::Maintenance::Manipulate::main(q{--cms-get}, q{/}, q{--format}, q{yaml}, q{--output}, $pepper . 'get-yaml');
SLight::Maintenance::Manipulate::main(q{--cms-get}, q{/}, q{--format}, q{json}, q{--output}, $pepper . 'get-json');

is_referenced_ok(q{}.scalar read_file( $pepper . 'get-xml' ),  '--cms-get to XML');
is_referenced_ok(q{}.scalar read_file( $pepper . 'get-yaml' ), '--cms-get to YAML');
is_referenced_ok(q{}.scalar read_file( $pepper . 'get-json' ), '--cms-get to JSON');



# If it dies, the test will die too, so why bother to check?
SLight::Maintenance::Manipulate::main(q{--cms-list}, q{/}, q{--format}, q{xml},  q{--output}, $pepper . 'list-xml');
SLight::Maintenance::Manipulate::main(q{--cms-list}, q{/}, q{--format}, q{yaml}, q{--output}, $pepper . 'list-yaml');
SLight::Maintenance::Manipulate::main(q{--cms-list}, q{/}, q{--format}, q{json}, q{--output}, $pepper . 'list-json');

is_referenced_ok(q{}.scalar read_file( $pepper . 'list-xml' ),  '--cms-list to XML');
is_referenced_ok(q{}.scalar read_file( $pepper . 'list-yaml' ), '--cms-list to YAML');
is_referenced_ok(q{}.scalar read_file( $pepper . 'list-json' ), '--cms-list to JSON');



# If it dies, the test will die too, so why bother to check?
output_like(
    sub { SLight::Maintenance::Manipulate::main(q{--cms-delete}, q{/Docs/}); },
    qr{status: OK},
    undef,
    "--cms-delete outputs a response."
);
# Check, if the page 'Doc' was really deleted.
is_referenced_ok(get_Pages_where(parent_id=>1), "--cms-delete does it's job");



END {
    system q{rm}, q{-rf}, $pepper;
}

# vim: fdm=marker
