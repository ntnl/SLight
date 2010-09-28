package SLight::Devel::SmokeTests;
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

# Routines performing various smoke tests on the codebase.
use strict; use warnings; # {{{

use SLight::Core::IO qw( find_files slurp_pipe );

use Carp;
use Carp::Assert::More qw( assert_lacks );
use English qw{ -no_match_vars };
use File::Slurp qw( read_file );
use Params::Validate qw( :all );
use Test::More;
use YAML::Syck qw( LoadFile DumpFile );
# }}}

# Purpose:
#   Check if Perl files compile.
#   Looks into every file bellow given path.
#
# Parameters:
#   start_path : Start searching from this path
sub compilation_test { # {{{
    my ( $start_path ) = @_;

    # Get list of files that we will be testing.
    my @files = find_files($start_path, '\.(pl|pm|t|cgi)$', 'files');

    plan tests => scalar @files;

    my $failed = 0;
    foreach my $file_path (@files) {
        $failed += compilation_test_file($file_path);
    }

    return $failed;
} # }}}

# Purpose:
#   Check if given file is usable: compiles, and can be loaded - if it is a module.
#   Returns 1 on success, and 0 on failure.
sub compilation_test_file { # {{{
    my ( $file_path ) = @_;
 
    if ($file_path =~ m{pm$}s) {
        # File is a module, we extract it's package name and use it in 'use_ok'
        my $contents = read_file($file_path);

        if ($contents =~ m{package\s+([a-zA-Z0-9:_]+);}s) {
            my $package = $1;

            if (not use_ok($package)) {
                return 1;
            }
        }
        else {
            fail("File: $file_path has no package inside.");

            return 1;
        }
    }
    else {
        # Plik jest skryptem, więc trzeba go przepiścić przez interpreter perla.
        my $result = slurp_pipe("perl -c $file_path 2>&1");

        if (not like($result, qr/syntax OK/s, "perl -c $file_path")) {
            return 1;
        }
    }

    # File passed, ZERO problems
    return 0;
} # }}}

# Purpose:
#   Check if Perl modules have tests made just for them.
#
# Parameters:
#   start_path : Start searching from this path
sub per_class_test { # {{{
    my ( $start_path, $test_basedir ) = @_;

    # Get list of files that we will be testing.
    my @files = find_files($start_path, '\.(pm)$', 'files');

    plan tests => scalar @files;

    my $failed = 0;
    foreach my $file_path (@files) {
        my ( $package ) = ( $file_path =~ m{(SLight[^.]*?)\.pm}s );

        $package =~ s{/}{-}sg;

        my $dedicated_test = $test_basedir .q{1-modules/}. $package . q{.t};

#        warn $dedicated_test . "\n\n";

        ok (-f $dedicated_test, q{Test exists: t/1-modules/} . $package . q{.t});
    }

    return $failed;
} # }}}

# Check if Perl files pass critic test.
# Looks into every file bellow given path.
# Parameters:
#   start_path : Start searching from this path
sub perl_critic_test { # {{{
    my ( $start_path, $cache_file ) = @_;

    # Use when needed.
    require Perl::Critic;
    require Digest::MD5::File;

    # Get list of files that we will be testing.
    my @files = find_files($start_path, '(pl|pm)$', 'files');

    plan tests => scalar @files;

    # Initialize critic:
    my @excluded = qw(
        RequireCheckedClose
        RequireExtendedFormatting
        RequireLineBoundaryMatching
        RequirePodSections
        RequireRcsKeywords
        RequireVersionVar
        RequireArgUnpacking
        RequireBriefOpen
        Subroutines::ProhibitUnusedPrivateSubroutines
        Variables::RequireLocalizedPunctuationVars

        ProhibitMagicNumbers
    );
    my $critic = Perl::Critic->new(-severity => 2, -exclude => \@excluded);

    # Initialize cache:
    my $critic_cache;
    if (-f $cache_file) {
        $critic_cache = LoadFile($cache_file);
    }

    my $failed = 0;
    foreach my $file_path (@files) {
        # Prepare checksum of the file.
        my $md5_sum = Digest::MD5::File::file_md5_hex($file_path);

        my $source = q{};

        my @problems;
        if ($critic_cache->{$file_path} and $critic_cache->{$file_path}->{'md5'} eq $md5_sum and ref $critic_cache->{$file_path}->{'problems'} eq 'ARRAY') {
            @problems = @{ $critic_cache->{$file_path}->{'problems'} };
        
            $source = '(cached)';
        }
        else {
            @problems = $critic->critique($file_path);

            # Re-load the cache, before we change it:
            if (-f $cache_file) {
                $critic_cache = LoadFile($cache_file);
            }

            # do the changes:
            $critic_cache->{$file_path}->{'md5'}      = $md5_sum;
            $critic_cache->{$file_path}->{'problems'} = \@problems;
        
            # Dump the cache for later use.
            DumpFile($cache_file, $critic_cache);
        }

        if (not is(scalar @problems, 0, "perlcritic 2 $file_path $source") ) {
            print "# Problems:\n# - ". (join "# - ", @problems);
            $failed++;
        }
    }

    return $failed;
} # }}}

# vim: fdm=marker
1;
