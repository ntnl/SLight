package SLight::Core::Factory;
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

use Params::Validate qw( :all );
# }}}

# Make a new Factory object.
sub new { # {{{
    my $class = shift;
    my %P = validate(
        @_,
        {
        }
    );
    
    my $self = {
    };

    bless $self, $class;

    # The fun begins now :)

    return $self;
} # }}}

# Load required module.
# Child factory should provide an interface that validates the input.
sub low_load { # {{{
    my ( $self, $class_array ) = @_;

    validate_pos(@_, { type=>OBJECT }, { type=>ARRAYREF } );

    my $module_path  = ( join q{/}, 'SLight', @{ $class_array } ) . q{.pm};
    my $module_class = join q{::}, 'SLight', @{ $class_array };

    require $module_path;

    my $module = $module_class->new( );

#    warn "Loaded $module_path / $module_class Got: $module";

    return $module;
} # }}}

# vim: fdm=marker
1;
