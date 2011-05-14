package SLight::Output::HTML;
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
use base q{SLight::Output};

use SLight::Core::Config;
use SLight::Output::HTML::Template;

use Carp::Assert::More qw( assert_defined );
use English qw( -no_match_vars );
use File::Slurp qw( read_file );
use Params::Validate qw( :all );
# }}}

sub process_object_data { # {{{
    my ( $self, $oid, $data_structure ) = @_;

#    use Data::Dumper; warn q{process_object_data: } . Dumper $oid, $data_structure;

    $self->{'HTML'}->{'objects'}->{$oid} = $data_structure;

    return;
} # }}}

sub process_addon_data { # {{{
    my ( $self, $addon, $data_structure ) = @_;

#    use Data::Dumper; warn q{process_addon_data: } . Dumper $addon, $data_structure;

    my $addon_placeholder = $addon;
    $addon_placeholder =~ s{::}{\.}s;

    $self->{'HTML'}->{'addons'}->{$addon_placeholder} = $data_structure;

    return;
} # }}}

sub serialize { # {{{
    my ( $self, $object_order, $template_code ) = @_;

#    my $template_file = SLight::Core::Config::get_option('site_root') . q{/html/} . $template_code . q{.html};
#
#    my $template = read_file($template_file);

    my $template = SLight::Output::HTML::Template->new(
        name => $template_code,
        dir  => SLight::Core::Config::get_option('site_root') . q{/html/},
    );

    # If no template has been loaded, "do something" (FIXME) maybe auto-generate a template?

    my @main_page_content;
    foreach my $oid (@{ $object_order }) {
        push @main_page_content, $self->{'HTML'}->{'objects'}->{$oid};
    }
    
#    use Data::Dumper; warn Dumper \@main_page_content;

    $template->set_layout(
        'content',
        {
            type    => 'Container',
            class   => 'SLight_Content',
            content => \@main_page_content
        }
    );

    # Process Plugins. Each has it's own Layout block.
    foreach my $addon (keys %{ $self->{'HTML'}->{'addons'} }) {
        if ($self->{'HTML'}->{'addons'}->{$addon}) {
            $template->set_layout(
                q{slight.} . lc($addon) .q{.plugin},
                $self->{'HTML'}->{'addons'}->{$addon},
            );
        }
    }

    # Add some useful page-wide variables.
    if ($self->{'metadata'}->{'title'}) {
        $template->set_var('page_title', $self->{'metadata'}->{'title'});
    }
    $template->set_var('web_root', SLight::Core::Config::get_option('web_root'));
    $template->set_var(
        'basehref',
        q{//} . SLight::Core::Config::get_option('domain') . SLight::Core::Config::get_option('web_root')
    );

    return (
       $template->render(),
        q{text/html; character-set: utf-8}
    );
} # }}}

# vim: fdm=marker
1;
