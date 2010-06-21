package SLight::Interface;
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
use Time::HiRes qw( time );
# }}}

# Prepares a new Interface object, returns it.
# Makre a Core::Request object
sub new { # {{{
    my $class = shift;
    my %P = validate(
        @_,
        {
        }
    );
    
    # Prototype of the object:
    my $self = {
        request    => undef,
    };

    bless $self, $class;

    return $self;
} # }}}

# Uses Core::Request to Do The Job (TM)
# Returns string, that may be returned/saved/scrapped...
sub run_request { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            url          => { type=>HASHREF },
            options      => { type=>HASHREF },
            interactive  => { type=>SCALAR, optional=>1 },
            default_lang => { type=>SCALAR, optional=>1 },
        }
    );
    
    my $start_time = time;

#    use Data::Dumper; warn "Running Request: ". Dumper \%P;

    require SLight::Core::Request;

    # The fun begins now :)
    if (not $self->{'request'}) {
        $self->{'request'} = SLight::Core::Request->new();
    }

    # This is easy :)
    my $content = $self->{'request'}->main(%P);

    my $total_run_time = sprintf "%.2f", time - $start_time;

    if ($content->{'content'}) {
        $content->{'content'} =~ s{\$gen_time\$}{$total_run_time}s;
    }

    return $content;
} # }}}

# vim: fdm=marker
1;