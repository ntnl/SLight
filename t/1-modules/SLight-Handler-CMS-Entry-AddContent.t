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
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use SLight::Test::Site;
use SLight::Test::Handler qw( run_handler_tests );

use English qw( -no_match_vars );
# }}}

my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Minimal'
);

my @tests = (
    {
        'name' => q{AddContent invitation},
        'url'  => q{/About/AddContent.web},
    },



    {
        'name' => q{AddContent form - as New},
        'url'  => q{/About/AddContent-form.web},
        'cgi'  => {
            target  => 'New',
            spec_id => 1,
        }
    },
    {
        'name' => q{Submit form - New},
        'url'  => q{/About/AddContent-save.web},
        'cgi'  => {
            'target'  => 'New',
            'spec_id' => 1,

            'page.path'     => q{Test1},
            'page.template' => q{},

            'meta.email' => q{agnes@test.test},

            'content.title'   => 'New primary content',
            'content.article' => 'This is new content.',

            'meta.comment_write_policy' => 0,
            'meta.comment_read_policy'  => 0,
        }
    },
    
    
    
    {
        'name' => q{AddContent form - as Current},
        'url'  => q{/About/AddContent-form.web},
        'cgi'  => {
            target  => 'Current',
            spec_id => 1,
        }
    },
    {
        'name' => q{Submit form - Current},
        'url'  => q{/About/AddContent-save.web},
        'cgi'  => {
            'target'  => 'Current',
            'spec_id' => 1,

            'meta.email' => q{agnes@test.test},

            'content.title'   => 'New extra content',
            'content.article' => 'This is extra content.',

            'meta.comment_write_policy' => 0,
            'meta.comment_read_policy'  => 0,
        }
    },
);

run_handler_tests(
    tests => \@tests,
    
    strip_dates => 1,
);

# vim: fdm=marker
