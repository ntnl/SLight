package SLight::HandlerMeta;
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

use Carp;
use English qw( -no_match_vars );
use File::Slurp qw( read_dir );
use Params::Validate qw( :all );
# }}}

# Purpose:
#   Meta information related to Handlers.

my $_cached_handlers_list;

sub get_handlers_list { # {{{
    if ($_cached_handlers_list) {
        return $_cached_handlers_list;
    }

    return $_cached_handlers_list = _find_handlers();
} # }}}

sub _find_handlers { # {{{
    my %handler_action_pool;

    foreach my $path (@INC) {
        if (not -d $path) {
            next;
        }

        my @dirs = read_dir($path);

        foreach my $item (@dirs) {
            if ($item eq 'SLight' and -d $path .q{/}. $item .q{/Handler}) {
                _harvest_handler_actions($path .q{/}. $item, \%handler_action_pool);
            }
        }
    }

    my @handlers_list;
    foreach my $handler (keys %handler_action_pool) {
        my $handler_entry = {
            class   => $handler,
            objects => [],
        };

        foreach my $object (keys %{ $handler_action_pool{$handler} }) {
            my $object_entry = {
                class   => $object,
                actions => $handler_action_pool{$handler}->{$object}->{'actions'},
            };

            push @{ $handler_entry->{'objects'} }, $object_entry;
        }

        push @handlers_list, $handler_entry;
    }

#    use YAML::Syck; warn Dump \@handlers_list;

    return \@handlers_list;
} # }}}

sub _harvest_handler_actions { # {{{
    my ( $dir, $pool ) = @_;

    my @handlers = read_dir($dir .q{/Handler});

    foreach my $handler (@handlers) {
        if (not -d $dir .q{/Handler/} . $handler) {
            next;
        }

        my @objects = read_dir($dir .q{/Handler/} . $handler);

        foreach my $object (@objects) {
            if (not -d $dir .q{/Handler/} . $handler . q{/} . $object) {
                next;
            }

            if (not $pool->{$handler}->{$object}->{'actions'}) {
                $pool->{$handler}->{$object}->{'actions'} = [];
            }

            my @actions = read_dir($dir .q{/Handler/} . $handler . q{/} . $object);

            foreach my $action (@actions) {
                if ($action =~ m{^(.+?)\.pm$}s) {
                    my $class = $1;

                    push @{ $pool->{$handler}->{$object}->{'actions'} }, $class;
                }
            }
        }
    }

    return;
} # }}}

# vim: fdm=marker
1;
