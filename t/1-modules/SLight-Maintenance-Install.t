#!/usr/bin/perl
use strict; use warnings; # {{{
use FindBin qw{ $Bin };
use lib $Bin .'/../../lib/';
use utf8;

use SLight::Test::Site;

use English qw( -no_match_vars );
use Test::More;
# }}}

use SLight::Maintenance::Install;

plan tests =>
    + 2 # make_site smoke test
    + 4 # make_site dirs created
    + 1 # make_site sql created
;

my $site_root = SLight::Test::Site::prepare_place(
    test_dir => $Bin . q(/../),
);

my @output;

ok(
    SLight::Maintenance::Install::make_site(
        $site_root,
        sub { my $msg = shift; push @output, $msg; },
        $Bin .'/../../sql/0.0/',
    ),
    "smoke test"
);

is(scalar @output, 5, "Output test");



ok (-d $site_root . q{users},    'data dir: users');
ok (-d $site_root . q{sessions}, 'data dir: sessions');
ok (-d $site_root . q{assets},   'data dir: assets');
ok (-d $site_root . q{cache},    'data dir: users');
        


ok (-f $site_root . q{db/slight.sqlite}, 'sqlite db created');

# vim: fdm=marker
