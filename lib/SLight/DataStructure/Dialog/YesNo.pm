package SLight::DataStructure::Dialog::YesNo;
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

# Response made of a Yes/No dialog.
use strict; use warnings; # {{{
use base 'SLight::DataStructure';

use SLight::Core::L10N qw( TR TF );

use Params::Validate qw( :all );
# }}}

sub _new { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            message => { type=>SCALAR },

            yes_href    => { type=>SCALAR },
            yes_caption => { type=>SCALAR, optional=>1 },

            no_href    => { type=>SCALAR },
            no_caption => { type=>SCALAR, optional=>1 },

            class => { type=>SCALAR, optional=>1, default=>'yesno', },
        }
    );

    # Check if captions have been given, if not, set defaults.
    if (not $P{'yes_caption'}) {
        $P{'yes_caption'} = TR('Yes');
    }
    if (not $P{'no_caption'}) {
        $P{'no_caption'} = TR('No');
    }

    $self->set_data(
        {
            type    => 'Container',
            data    => { },
            content => [
                $self->make_Label(
                    text => $P{'message'}
                ),
                {
                    type    => 'Container',
                    data    => { },
                    content => [
                        $self->make_Action(
                            class => 'yes',
                                caption => $P{'yes_caption'},
                                href    => $P{'yes_href'},
                        ),
                        $self->make_Action(
                            class => 'no',
                                caption => $P{'no_caption'},
                                href    => $P{'no_href'},
                        ),
                    ],
                },
            ],
            class => $P{'class'},
        }
    );

    return;
} # }}}


# vim: fdm=marker
1;