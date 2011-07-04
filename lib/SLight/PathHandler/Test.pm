package SLight::PathHandler::Test;
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
use base q{SLight::PathHandler};

my $VERSION = '0.0.4';

use Carp::Assert::More qw( assert_defined );
# }}}

sub analyze_path { # {{{
    my ( $self, $path ) = @_;

    assert_defined($path, "Path is defined");

    # Note:
    #   This Path handler is designed to mess during unit/automated tests.
    #   Please do not forget that :)

    $self->set_template('Default');

    $self->set_title(q{Test for path: /} . (join q{/}, @{ $path }) );

    if (scalar @{ $path }) {
        $self->set_objects(
            {
                t1 => {
                    class    => q{Test::} . $path->[0],
                    oid      => undef,
                    metadata => {},
                },
            }
        );

        $self->set_object_order([qw( t1 )]);

        $self->set_main_object('t1');
    }
    else {
        $self->set_objects(
            {
                ob1 => {
                    class    => 'Test::Foo',
                    oid      => 1,
                    metadata => { 'msg' => 'First test entry' },
                },
                ob2 => {
                    class    => 'Test::Foo',
                    oid      => 2,
                    metadata => { 'msg' => 'Second test entry' },
                }
            },
        );

        $self->set_object_order([qw( ob1 ob2 )]);

        $self->set_main_object('ob1');
    }

    return $self->response_content();
} # }}}

# vim: fdm=marker
1;
