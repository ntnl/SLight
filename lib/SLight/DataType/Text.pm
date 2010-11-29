package SLight::DataType::Text;
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

# DataType support for Text.
use strict; use warnings; # {{{

use Carp;
use English qw( -no_match_vars );
use Params::Validate qw{ :all };
use YAML::Syck qw{ Load Dump };
# }}}

# Text:
# Many lines of characters.
#
# Text is stored as a list of strings and tokens.
# Strings represent raw text. Token are responsible for logical and visual formatting.
#
# Text is enclosed in paragraphs. Adding "empty" line will split the text into two paragraphs.
# Warning: markup may not span across many paragraphs.
#
# Lines brakes follow the use of \r, \n or any combination of them.
#
# Additional markup is based on BBCode, as it is described on Wikipedia:
#   http://en.wikipedia.org/wiki/BBCode
#
# Complete reference:
#
#   [b]bolded text[/b]
#       makes the text bold
#
#   [i]italicized text[/i]
#       makes the text italic
#
#   [u]underlined text[/u]
#   [s]strikethrough text[/s]
#   [url]http://example.org[/url]
#       hipertext link
#
#   [url=http://example.com]Example[/url]
#   [img]http://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/Go-home.svg/100px-Go-home.svg.png[/img]
#   [quote]quoted text[/quote]
#       something quotted
#
#   [code]monospaced text[/code]
#       code snipped
#
#   [size=125]Large Text[/size]
#       defines text size in percent
#
#   [color=red]Red Text[/color]
#
# Extensions to BBcode are described bellow:
#
#   [br]
#       line break
#
#   [separate]
#       creates horizontal separator
#
# WIP:
#
#   [progress]10/100[/progress]
#       creates progress bar with defined length
# 
#   [asset]id[/asset]
#       embeds asset with given ID.

sub signature { # {{{
    return {
        asset   => 0,
        entry   => 'Text',
        display => 'Text',

        validator_type => 'Text',
    };
} # }}}

sub validate_data { # {{{
    my %P = validate(
        @_,
        {
            value  => { type=>SCALAR },
            format => { type=>SCALAR },
        }
    );

    # No problems found.
    return;
} # }}}

sub encode_data { # {{{
    my %P = validate(
        @_,
        {
            value  => { type=>SCALAR },
            format => { type=>SCALAR },
        }
    );
    
    # Fix newlines.
    $P{'value'} =~ s{\r\n}{\n}sg;
    $P{'value'} =~ s{\r}{\n}sg;

    # Preprocess:
    $P{'value'} =~ s{^[ \t]+}{}sgm;
    $P{'value'} =~ s{[ \t]+$}{}sgm;
    
    # Split to paragraphs and process each...
    my @paragraphs = split /\n\n+/s, $P{'value'};

#    use Data::Dumper; warn "PARA: ". Dumper \@paragraphs;

    my @encoded;
    foreach my $paragraph ( @paragraphs ) {
        push @encoded, analize_text($paragraph);
    }
    
#    use Data::Dumper; warn "ENC ". $P{'value'} ." => ". Dumper \@encoded;

    return Dump(\@encoded);
} # }}}

sub decode_data { # {{{
    my %P = validate(
        @_,
        {
            value  => { type=>SCALAR },
            format => { type=>SCALAR },
            target => { type=>SCALAR },
        }
    );

    my $value_data = eval { return Load($P{'value'}); };

    # If content does not look like YAML, do the 'safe-mode' thing.
    # Convert it to paragraph of text.
    if ($EVAL_ERROR) {
        print STDERR "Unable to parse following content: ". $P{'value'} ."\nError: ". $EVAL_ERROR;

        $value_data = [
            $P{'value'}
        ];
    }

#    use Data::Dumper; warn "Value text: ". $P{'value'};
#    use Data::Dumper; warn "Value data: ". Dumper $value_data;

    # Backward compatibility ;)
    if (not ref $value_data) {
        return $value_data;
    }

    if ($P{'target'} eq 'FORM') {
        # Serialize to text with BBCode markup.
        return join qq{\n\n}, map { item_to_text($_) } @{ $value_data };
    }
    elsif ($P{'target'} eq 'SNIP') {
        # Serialize first paragraph and remove BBCode markup...
        my $snip = item_to_text($value_data->[0]);

        $snip =~ s{\[/?\w+\]}{}sgi;

        if (length $snip > 64) {
            $snip = substr $snip, 0, 64;

            $snip .= q{...};
        }

        return $snip;
    }
    elsif ($P{'target'} eq 'LIST') {
        # Return just the first paragraph.
        return [ $value_data->[0] ];
    }

    # Return all content.
    return $value_data;
} # }}}

# Private subroutines.

my %single_tags = (
    br       => 1,
    separate => 1
);
my %paired_tags = (
    b     => 1,
    i     => 1,
    u     => 1,
    s     => 1,
    url   => 1,
    img   => 1,
    quote => 1,
    code  => 1,
    size  => 1,
    color => 1,
    
    youtube => 1,
);

sub analize_text { # {{{
    my ( $paragraph ) = @_;

    # Turn newlines to BB-tags.
    $paragraph =~ s/[\s\t]*[\n\r]+[\s\t]*/\[br\]/sg;

    # Current implementation is roether efficient, should be more then sifficient for start.
    # When time comes, a refactoring will be easy, especially,
    # when all important use-cases are covered in tests.
    my @parsable_elements = split m{(?:\[(/)?([^\[\]]+?)(?:\=([^\[\]]+))?\])}s, $paragraph;

#    use Data::Dumper; warn "PE: ". Dumper \@parsable_elements;

    my $structure = slurp_tag_contents( q{}, \@parsable_elements);
    
#    use Data::Dumper; warn "ST: ". Dumper $structure;

    return $structure;
} # }}}

# Return contents of pairable tag.
# May recure, if tags are nested. 
sub slurp_tag_contents { # {{{
    my ( $open_tag, $parsable_elements ) = @_;

    my @result_list;
    
    my $text = shift @{ $parsable_elements };
    if ($text) {
        push @result_list, $text;
    }
    
    while (scalar @{ $parsable_elements }) {
        # Tag part:
        my $is_clousure = shift @{ $parsable_elements };
        my $tag         = shift @{ $parsable_elements };
        my $value       = shift @{ $parsable_elements };

        if ($tag eq $open_tag and $is_clousure) {
            # Found a clousure :)
            if (scalar @result_list > 1) {
                # Return list of things, as there are more of them.
                return \@result_list;
            }
            else {
                # It's just this one thing... return it.
                # There is no need to return the whole array.
                return $result_list[0];
            }
        }
        elsif ($single_tags{$tag}) {
            # Let it flow... just add this to the list...
            push @result_list, { tag => $tag };
        }
        elsif ($paired_tags{$tag}) {
            my $contents = slurp_tag_contents(
                $tag,
                $parsable_elements
            );

            my %tag_token = (
                tag => $tag,
                ct  => $contents
            );
            if ($value) {
                $tag_token{'value'} = $value;
            }

            push @result_list, \%tag_token;
        }
#        else {
#            warn("Unsupported tag: [$tag]!");
#        }

        # After a tag, there is always a text. But, may be undef or empty.
        my $plain_text = shift @{ $parsable_elements };
        if ($plain_text) {
            push @result_list, $plain_text;
        }
    }

    return \@result_list;
} # }}}

sub item_to_text { # {{{
    my ( $item ) = @_;

    if (ref $item eq 'ARRAY') {
        return join q{}, map { item_to_text($_) } @{ $item };
    }
    elsif (ref $item eq 'HASH') {
        # There is one, special use case:
        if ($item->{'tag'} eq 'br') {
            # If it's BR - return as a newline.
            return qq{\n};
        }
        elsif ($item->{'ct'}) {
            # Typical paired tag has begining, content and end:
            my $string = q{[} . $item->{'tag'};

            if ($item->{'value'}) {
                $string .= q{=} . $item->{'value'};
            }
            $string .= q{]}. item_to_text($item->{'ct'}) .q{[/}. $item->{'tag'} .q{]};

            return $string;
        }
        else {
            # Typical single tag has just itself ;)
            return q{[} . $item->{'tag'} . q{]};
        }
    }

    # Anything else - just return
    return $item;
} # }}}

# vim: fdm=marker
1;
