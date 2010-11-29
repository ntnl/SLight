package SLight::Core::L10N;
################################################################################
# 
# SLight - Lightweight Content Management System.
#
# Copyright (C) 2010 Bartłomiej /Natanael/ Syguła
#
# This is free software.
# It is licensed, and can be distributed under the same terms as Perl itself.
#
# More information on: http://slight-cms.org/
# 
################################################################################
use strict; use warnings; use utf8; # {{{
use base 'Exporter';

our @EXPORT_OK = qw(
    TR_from_hash
    TF_from_hash
    TR
    TF
);
our %EXPORT_TAGS = ( 'all' => [ @EXPORT_OK ] );

use YAML::Syck qw( LoadFile );

use File::Slurp qw( append_file );
# }}}

my $default_lang = q{en};

# Selects one message from hash containing translated versions.
# Such hash should look like:
#   %hash = (
#       pl => "Treść po polsku",
#       en => "English content",
#   );
#
# If chousen language is not available it will try to return english. If it is also unavailabe, it will return random message from the hash.
#
# If the hash is a scalar - function returns the scalar.
sub TR_from_hash { # {{{
    my ( $hash_ref, $lang ) = @_;

    if (ref $hash_ref ne 'HASH') {
        return $hash_ref;
    }

    if (not $lang) {
        $lang = $default_lang;
    }

    foreach my $lang ($lang, 'en') {
        if ($hash_ref->{$lang}) {
            return $hash_ref->{$lang};
        }
    }

    # 'sort' is good for testing, gives repetative results.
    # This part should no be used much, so performance is not a hudge problem.
    my @langs = sort keys %{ $hash_ref };

    return $hash_ref->{ $langs[0] };
} # }}}

# RC_from_hash and sprintf in one call.
sub TF_from_hash { # {{{
    my ( $hash_ref, $lang, @params ) = @_;

    return sprintf TR_from_hash($hash_ref, ($lang or q{}) ), @params;
} # }}}

# Replace non-latin letters with their Latin-1 equivalents.
sub local_to_latin_characters { # {{{
    my ( $text ) = @_;
    
    my %mapping = (
        # Polish national characters:
        q{á}=>q{a},
        q{ż}=>q{z},
        q{ś}=>q{s},
        q{ź}=>q{z},
        q{ę}=>q{e},
        q{ć}=>q{c},
        q{ń}=>q{n},
        q{ó}=>q{o},
        q{ł}=>q{l},
        
        q{Ą}=>q{A},
        q{Ż}=>q{Z},
        q{Ś}=>q{S},
        q{Ź}=>q{Z},
        q{Ę}=>q{E},
        q{Ć}=>q{C},
        q{Ń}=>q{N},
        q{Ó}=>q{O},
        q{Ł}=>q{L},
    
        # German letters:
        q{ß}=>q{ss},
        q{ä}=>q{aa},
        q{Ä}=>q{Aa},
        q{ö}=>q{oa},
        q{Ö}=>q{Oa},
        q{ü}=>q{ua},
        q{Ü}=>q{Ua},
    );
    $text =~ s{([^a-zA-Z0-9])}{ ($mapping{$1} or $1) }sge;

    return $text;
} # }}}

my $source_directory = q{};
my %sources = ();

# Initialize the L10N module.
sub init { # {{{
    my ( $directory, $lang ) = @_;
    
    $source_directory = $directory;

    $default_lang = $lang;

    if (not $sources{'default'}->{$lang}) {
        load_source('default', $lang);
    }

    return 1;
} # }}}

# Check if given source is loaded, if not load it from given directory.
# Primary translation source files should be named: source-language.yaml
# Secondary translation source files should be named: source-language-extra.yaml
#
# Using two files makes it easy to have built-in defaults with possibility to extend them.
# Extras files can also overwrite the built-in defaults as well.
#
# Returns reference to hash.
sub load_source { # {{{
    my ( $source, $lang ) = @_;

    # If not yet loaded - load now.
    if (not defined $sources{$source}->{$lang}) {
        my $path = sprintf "%s/%s-%s.yaml", $source_directory, $source, $lang;

        # Allow the primary source/language to be missing...
        if (-f $path) {
            $sources{$source}->{$lang} = LoadFile( $path );
        }
        else {
            $sources{$source}->{$lang} = {};
        }

        # Check if we have some additions.
        my $extra_path = sprintf "%s/%s-%s-extra.yaml", $source_directory, $source, $lang;
        if (-f $extra_path) {
            my $extras = LoadFile( $extra_path );

            foreach my $term (keys %{ $extras }) {
                $sources{$source}->{$lang}->{$term} = $extras->{$term};
            }
        }
    }

#    use Data::Dumper; warn Dumper $sources{$source}->{$lang};

    return $sources{$source}->{$lang};
} # }}}

# Purpose:
#   Translate a string using given directory as a source of translation files.
sub TR { # {{{
    my ( $string, $lang ) = @_;

    if (not $lang) {$lang = $default_lang; }

    my $text   = $string;
    my $source = q{default};

    if ($string =~ m{^(.+?)\#(.+?)$}s) {
        $text   = $1;
        $source = $2;
    }

    if (not $sources{$source}->{$lang}) {
        load_source($source, $lang);
    }
    
#    warn "\$sources{$source}->{$lang}->{$text}";

    # This is a debug code.
    # Enable this variable, and SLight will append L10N infromation to file pointed by the variable.
    #
    # By default this code should not be run (on 'production'), since it degrades performance.
    if ($ENV{'SLIGHT_L10N_TRACE'}) {
        append_file($ENV{'SLIGHT_L10N_TRACE'}, $text .qq{\n});
    }
    # End of debug code.

    return ( $sources{$source}->{$lang}->{$text} or $sources{'default'}->{$lang}->{$text} or _detokenize($text) );
} # }}}

# Purpose:
#   Translate a string, and then process it with sprintf.
sub TF { # {{{
    my ( $string, $lang, @params ) = @_;

    return sprintf TR($string, $lang), @params;
} # }}}

# Purpose:
#   Turn token names, possibly unfriendlt to humans, to something that humans will tolerate.
#   This includes:
#       convert underscores to '_'
#       make first letter uppercase
#   Only 'tokens' (stuff with only letters and underscores) are processed!
sub _detokenize { # {{{
    my ( $string ) = @_;

    if ($string =~ m{[^a-zA-Z_]}s) {
        return $string;
    }

    $string =~ s{_}{ }sg;

    return ucfirst lc $string;
} # }}}

# vim: fdm=marker
1;
