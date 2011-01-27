package SLight::Interface;
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
            session_id   => { type=>SCALAR | UNDEF },
            url          => { type=>HASHREF },
            options      => { type=>HASHREF },
            default_lang => { type=>SCALAR, optional=>1 },
        }
    );

    my $start_time = time;

    # Module is loaded at runtime. If it fails - interface handler can
    # still return a nice error message.
    # Even compilation errors can be handled this technique.
    require SLight::Core::Request;

#    use Data::Dumper; warn "Running Request: ". Dumper \%P;

    # The fun begins now :)
    if (not $self->{'request'}) {
        $self->{'request'} = SLight::Core::Request->new();
    }

    # This is easy :)
    my $content = $self->{'request'}->main(%P);

    # Replace generated time placeholder with some real value, but only if We are doing some text-based response.
    # Running regexp on some binary data could have bad consequences.
    if ($content->{'mime_type'} =~ m{^text/}s) {
        my $total_run_time = sprintf "%.2f", time - $start_time;

        if ($content->{'content'}) {
            $content->{'content'} =~ s{\$gen_time\$}{$total_run_time}sg;
        }
    }

    return $content;
} # }}}

# vim: fdm=marker
1;
