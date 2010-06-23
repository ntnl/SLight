package SLight::Core::Profiler;
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
use base 'Exporter';
our @EXPORT_OK = qw(
    task_starts
    task_ends
    task_switch
);
our %EXPORT_TAGS = ('all' => [ @EXPORT_OK ]);

use Carp;
use Time::HiRes qw( time );
# }}}

my %tasks = ();

# Mark, when task started.
sub task_starts { # {{{
    my ( $task_id ) = @_;
    
    if (not $task_id ) {
        confess("Missing Task ID");
    }

    $tasks{$task_id}->{'start'} = time;

    return;
} # }}}

# Mark when task ended.
sub task_ends { # {{{
    my ( $task_id ) = @_;
    
    if (not $task_id) {
        confess("Missing Task ID");
    }

    if (not $tasks{$task_id}) {
        confess("Task with ID: $task_id was NOT started!");
    }

    $tasks{$task_id}->{'stop'} = time;

    return;
} # }}}

# Stop task A, start task B, at THE SAME time :)
sub task_switch { # {{{
    my ( $task_A, $task_B ) = @_;

    if (not $task_A) { confess("Missing Task A ID"); }
    if (not $task_B) { confess("Missing Task B ID"); }

    if (not $tasks{$task_A}) {
        confess("Task with ID: $task_A was NOT started!");
    }

    my $time = time;

    $tasks{$task_A}->{'stop'}  = $time;
    $tasks{$task_B}->{'start'} = $time;

    return;
} # }}}

# Return a summary, as HASHREF, with tasks, and time that they took.
sub task_times { # {{{
    my %task_times;

    foreach my $task_id (keys %tasks) {
        $task_times{$task_id} = ($tasks{$task_id}->{'stop'} or time) - $tasks{$task_id}->{'start'};
    }

    return \%task_times;
} # }}}

# Format task times into something looknig not-so-bad.
sub format_task_times { # {{{
    my ( $task_times ) = @_;

    my $string = qq{Task times:\n};
    foreach my $task_id (sort keys %{ $task_times }) {
        $string .= sprintf " %-45s : %.5fs\n", $task_id, $task_times->{$task_id};
    }

    return $string;
} # }}}

# vim: fdm=marker
1;
