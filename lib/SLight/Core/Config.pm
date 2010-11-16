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

our $VERSION = '0.0.2';

# Defaults:
my %config = (
    name          => q{SLight},
    domain        => q{localhost},
    web_root      => q{/},
    site_root     => q{./SLight_Site/}, # Site's RO files, managed by webmaster or a site admin, for the site to use.
    data_root     => q{./SLight_Data/}, # Site's RW files, or data files, managed by the website itself.
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

    return $initialized = 1;
} # }}}

# Try to find and load configuration.
sub find_and_load { # {{{
    my ( $path ) = @_;

    assert_defined($path, q{Top search directory is defined});

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

    assert_defined( $config{$option}, "Option: $option is defined.");

    return $config{$option} = $value;
} # }}}

sub get_option { # {{{
    my ( $option ) = @_;

    return $config{$option};
} # }}}

# vim: fdm=marker
1;
