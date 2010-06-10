package SLight::Core::Config;
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

$YAML::Syck::ImplicitUnicode = 1; ## no critic qw(ProhibitPackageVars)

use Carp::Assert::More qw( assert_defined );
use Params::Validate qw( :all );
use YAML::Syck qw( LoadFile );
use File::Slurp qw( read_dir );
# }}}

our $VERSION = '0.0.1';

# Defaults:
my %config = (
    name          => q{SLight},
    domain        => q{localhost},
    web_root      => q{/},
    site_root     => q{./},
    test_site_dir => q{./fake_site/},
    lang          => [qw( en )],
    debug         => 0, # Set to 1, to see more verbose error messages.
    lib           => undef,
);

my $initialized = 0;

sub initialize { # {{{
    my ( $path ) = @_;

    if ($initialized) {
        return;
    }

    find_and_load($path);

    # Do some auto-initialization here.

    # Add additional library locations.
    if ($config{'lib'} and ref $config{'lib'} eq 'ARRAY') {
        push @INC, @{ $config{'lib'} };
    }

    # Check, if 'packages' are configured. Autoconfigure, if not.
    if (not $config{'packages'}) {
        $config{'packages'} = _auto_detect_packages();
    }

    # Now, that We have packages - register them.
    _register_packages($config{'packages'});

    return $initialized = 1;
} # }}}

# Try to find and load configuration.
sub find_and_load { # {{{
    my ( $path ) = @_;

    my @directories = split m{\/}s, $path;

    while (scalar @directories) {
        my $config_path = (join q{/}, @directories) . '/SLight.yaml';

#        warn "SLight::Config - inspecting path: $config_path\n";

        if (-f $config_path) {
            my $loaded_config = LoadFile( $config_path );

#            warn "SLight::Config - loading: $config_path\n";

            foreach my $option (keys %config) {
                if (defined $loaded_config->{$option}) {
                    $config{$option} = $loaded_config->{$option};
                }
            }
            last;
        }

        pop @directories;
    }

#    use Data::Dumper; warn Dumper \%config;

    return { %config };
} # }}}

sub set_option { # {{{
    my ( $option, $value ) = @_;

    confess_on_false( defined $config{$option}, "Option: $option is undefined!");

    return $config{$option} = $value;
} # }}}

sub get_option { # {{{
    my ( $option ) = @_;
    
    return $config{$option};
} # }}}

# vim: fdm=marker
1;
