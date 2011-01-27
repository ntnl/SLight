package SLight::Output::HTML::Generator;
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

# Generate HTML from Perl data structures describing BBCode-compatible layout.
use strict; use warnings; # {{{

use Carp::Assert::More qw( assert_defined );
use Params::Validate qw( :all );
# }}}

# Generate HTML from data structure.
# If the data structure is:
#   SCALAR
#       ...it is passed as it is (no mangling)
#
#   ARRAYREF
#       ...it's contents (each elemenent) are processed with token_to_html, and each is wrapped with: "<p>" and "</p>".
#
#   HASHREF
#       ...it is processed by token_to_html, and result is returned as it is.
#
#   UNDEF
#       ...returns empty string.
#
# See descriptions of other functions to get complete picture of how HTML is generated from different data structures.
# Also, have a look into test for this module, it has a lot of use-case examples.
#
# Parameters:
#   data_structure : UNDEF | SCALAR | ARRAYREF | HASHREF
sub structure_to_html { # {{{
    my ( $data_structure ) = @_;

    my $data_type = ref $data_structure;

#    warn "Structure_to_html workign on $data_type\n";
#    warn $data_structure;

    if ($data_type eq 'HASH') {
        return token_to_html($data_structure);
    }
    elsif ($data_type eq 'ARRAY') {
        my @html;
        
        foreach my $item (@{ $data_structure }) {
            push @html, q{<p>}, token_to_html($item), "</p>";
        }

        return join q{}, @html;
    }

    return ( $data_structure or q{} );
} # }}}

my %known_tags = (
    'b' => {
        replace     => q{<b class=BBC_Bold>%s</b>},
        has_content => 1,
    },
    'i' => {
        replace     => q{<i class=BBC_Italic>%s</i>},
        has_content => 1,
    },
    'u' => {
        # text-decoration: underline;
        replace     => q{<span class=BBC_Underline>%s</span>},
        has_content => 1,
    },
    's' => {
        # text-decoration: strike-through;
        replace     => q{<span class=BBC_Strike>%s</span>},
        has_content => 1,
    },
    'url' => {
        replace  => q{<a href="%s" class=BBC_Url>%s</a>},
        has_both => 1,
    },
    'img' => {
        replace   => q{<img src="%s" class=BBC_Img>},
        has_value => 1,
    },
    'quote' => {
        replace     => q{<blockquote class=BBC_Quote>%s</blockquote>},
        has_content => 1,
    },
    'code' => {
        replace     => q{<pre class=BBC_Code>%s</pre>},
        has_content => 1,
    },
    'size' => {
        replace  => q{<span style="font-size: %s%%;">%s</span>},
        has_both => 1,
    },
    'color' => {
        replace  => q{<span style="color: %s">%s</span>},
        has_both => 1,
    },

    'br' => {
        replace => qq{<br>\n},
    },
    'separate' => {
        replace     => q{<hr class=BBC_Separate>\n},
    },

    # Example movie ID: qD6AWdqtoj0
    'youtube' => {
        replace   => q{<object width="320" height="265"><param name="movie" value="http://www.youtube.com/v/%1$s&fs=1&rel=0"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/%1$s&fs=1&rel=0" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="320" height="265"></embed></object>},
        has_value => 1,
    },

# WIP:
#    'progress' => {
#        replace => q{<span class=BBC_Progress><span style="width: %s%" class=Bar></span><span class=Label>%s / %s</span></span>},
#        special => 1,
#    },
#    'attach' => {
#    },
);

# Process token. If a token is:
#   HASHREF
#       ...it is processed as a tag.
#       it's contents, if any, are thrown to token_to_html.
#
#   ARRAYREF
#       ...it iterates over it's contents, and processes each element with token_to_html
#
#   SCALAR
#       ...is returned as is.
#
#   UNDEF
#       ...returns empty string.
#
# Parameters:
#   data_token : UNDEF | SCALAR | ARRAYREF | HASHREF
sub token_to_html { # {{{
    my ( $data_token ) = @_;

    my $data_type = ref $data_token;

    if ($data_type eq 'HASH') {
        # A tag?
        if ($data_token->{'tag'} and $known_tags{ $data_token->{'tag'} }) {
            my $info = $known_tags{ $data_token->{'tag'} };

            my ( $content, $value ) = ( q{}, q{} );

            if ($data_token->{'ct'}) {
                $content = token_to_html($data_token->{'ct'});
            }

            if ($data_token->{'value'}) {
                $value = $data_token->{'value'};
            }

            if ($info->{'has_both'}) {
                return sprintf $info->{'replace'}, ( $value or $content or q{} ), ( $content or q{} );
            }
            elsif ($info->{'has_value'}) {
                return sprintf $info->{'replace'}, ( $value or $content );
            }
            elsif ($info->{'has_content'}) {
                return sprintf $info->{'replace'}, $content;
            }

            return $info->{'replace'};
        }
    }
    elsif ($data_type eq 'ARRAY') {
        # A list of tags?
        my @html;

        foreach my $data_item (@{ $data_token }) {
            push @html, token_to_html($data_item);
        }

        return join q{}, @html;
    }

    my $html = q{};

    return ( $data_token or q{} );
} # }}}

# vim: fdm=marker
1;
