package SLight::Output::HTML::Template;
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

# Parse HTML templates.
use strict; use warnings; # {{{

use SLight::Output::HTML::Generator;
#use Co\Me::Common::Cache qw( Cache_Fetch_File Cache_Fetch_YAML );

use Carp::Assert::More qw( assert_defined );
use Encode qw( decode_utf8 );
use File::Slurp qw( read_file );
use Params::Validate qw( :all );
use YAML::Syck qw( DumpFile LoadFile Dump );
# }}}

# Template was designed to handle HTML, altrough it should work
# fairy well with plain text or xml-like languages.

# HTML template, when loaded, is analized and stored as a structure
# most suitable for HTML generation.
#
# Once the template has been analyzed, it's structure is saved
# in a cache file (with html replaced by JSON). the second time
# the template is used, it will be loaded as a structure.
#
# Template structure is a hash:
# $template = {
#   'index' => [
#       $token_1,
#       $tonen_2,
#       ...
#       $token_n
#   ],
# };
#
# %token = {
#   type => ( TEXT | PLACEHOLDER | TEMPLATE | BLOCK ),
#       # TEXT
#       #   unchanged textual content, copied 1:1 from template to document.
#       #
#       # PLACEHOLDER
#       #   simple variable
#       #
#       # TEMPLATE
#       #   references another template, that is stored in another file.
#       #
#       # BLOCK
#       #   selected block of tokens, that can have special meaning and handling.
#
#   name => $string,
#       # Code name, needed to fetch items from accumulated data.
#
#   html => $string,
#       # HTML code that does not contain any blocks, nor placeholders.
#
#   template => $block_template
#       # Present only in blocks. Contains the block contents,
#       # as they ware defined in the template.
#       # It's a template object.
# }
#
# Currently only the 'index' object is used. More keys are planned in future.
#
# Data is accumulated as it enters the object.
# The same object can be used to display many different pages,
# based on the same template.
#
# Data types:
#   Variable
#       simple string that replace placeholders
#
#   List
#       Array of hashes containing data, that result in repeating some block sub-template.
#
#   Grid
#       Array of array of hashes, two dimensional list.
#
#   Layout
#       Widget-based layout made from nested array/hash structure.
#       Every widget must be specified in the HTML Template file.
#
# This is because an assumption is made, that raw data weights less then resulting HTML.
#
# To get the final HTML the index must be iterated,
# and it's tokens updated with acumulated data and merged into string again.

# Create Template object.
# Parameters:
#   name - scalar, or array of scalars. First file, that can be accessed is used.
#   dir  - directory, in which templates (and sub templates as well) reside.
sub new { # {{{
    my $class = shift;
    my %P = validate(
        @_,
        {
            name => { type=>SCALAR | ARRAYREF },
            dir  => { type=>SCALAR },
            lang => { type=>SCALAR, optional=>1 },
        }
    );

    my $self = {
        name => q{},
        dir  => $P{'dir'},

        template => undef,

        # Acumulated data that will be added into template.
        var_data    => {},
        list_data   => {},
        grid_data   => {},
        layout_data => {},
    };

    bless $self, $class;

    my @names;
    if (ref $P{'name'}) {
        push @names, @{ $P{'name'} };
    }
    else {
        push @names, $P{'name'};
    }

#    warn "Seeking for template: ". ( join ", ", @names );

    # Load base file. Try, until some file is found.
    foreach my $name (@names, 'Default') {
        # Try to load template matching given language.
        if ($P{'lang'}) {
            # This function will call itself recursively, to append other files.
            $self->{'template'} = $self->load_and_parse(
                name => $name,
                lang => $P{'lang'},
            );

            if ($self->{'template'}) {
                last;
            }
        }

        $self->{'template'} = $self->load_and_parse(
            name => $name,
        );

        if ($self->{'template'}) {
            last;
        }
    }

#    use Data::Dumper; warn Dumper $self->{'template'}->{'has_block'};

    assert_defined($self->{'template'}, "Template file loaded");

    return $self;
} # }}}

# Internal method (rename to _* / FIXME)
# Load and analize a HTML template file.
sub load_and_parse { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            name => { type=>SCALAR },
            lang => { type=>SCALAR, optional=>1, },

            is_part => { type=>SCALAR, optional=>1, },
        }
    );

    my $l10n_part = q{};
    if ($P{'lang'}) {
        $l10n_part = q{-} . $P{'lang'};
    }

    my $html_filename = $self->{'dir'} .q{/}. $P{'name'} . $l10n_part .q{.html};
    my $yaml_filename = $self->{'dir'} .q{/}. $P{'name'} . $l10n_part .q{.yaml};

#    warn 'Is part: ' . ( $P{'is_part'} or 0 );
#    warn 'Trying : ' . $html_filename;
#    warn "YAML   : " . $yaml_filename;
#    warn "Yaml -M  : " . (0 + -M $yaml_filename );
#    warn "Html -M  : " . (0 + -M $html_filename );

#    print `ls -l /home/natanael/Projekty/Perl/SLight/t/1-modules/SLight-Output-HTML-Template/example.*`;

    # Check cache file...
    if ( (-f $html_filename) and (-f $yaml_filename) and (-M $yaml_filename < -M $html_filename )) {
        # Cache file exists, and it was modified LATER then the source - html file.
        # We do not need to load the HTML and parse it - we have it ready from the
        # last run...
        # -M gives You 'days since...' so the biger the number - the older the file.

        if (not $self->{'source'}) {
            $self->{'source'} = 'YAML';
        }

        return $self->parsed_fetch($yaml_filename);
    }

    my $html;
    # If the file does not exist, the function can gracefully return an error message.
    if (-f $html_filename) {
        $html = (
            eval { return read_file( $html_filename ); }
        or
            $html = q{<div class="SL_Template_Error">Error loading template part: "}. $P{'name'} .q{"!</div>}
        );
    }
    elsif ($P{'is_part'}) {
        $html = q{<div class="SL_Template_Error">Error: Template part missing: "}. $P{'name'} .q{"!</div>};
    }
    else {
        return;
    }

    # Only the main template sets the 'source'...
    if (not $self->{'source'}) {
        $self->{'source'} = 'HTML';
    }

    $html = decode_utf8($html);

    my $template = $self->process_html_template(
        html => $html,
    );

    # Save parsed data to cache.
    if (-w $self->{'dir'}) {
        # Directory is writable, we can save tha cache.
        $self->parsed_store($yaml_filename, $template);
    }

#    warn "Template: ". Dump $template;
#    use Data::Dumper; warn "Template: ". Dumper $template;

#    $self->parsed_fetch_index_check($template->{'index'});

    return $template;
} # }}}

sub source { # {{{
    my ( $self ) = @_;

    return ( $self->{'source'} or 'NONE' );
} # }}}

# Analyze HTML string. Results go in the template structure.
sub process_html_template { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            html => { type=>SCALAR },
        }
    );

    my %template = (
        'index' => [],

        'has_var'   => {},
        'has_block' => {},
    );

    # First, extract and handle blocks.
    my @parts = split /(<!--([0-9a-zA-Z\-\_\.]+?)-->\n?(.*?)<!--\/\2-->\n?)/s, $P{'html'};

    # First part will always be a text template, that we need to process.
    my $part = shift @parts;

    $self->extract_placeholders(
        template => \%template,
        html     => $part
    );

#    warn "Blocks: ". Dump \@parts;

    while (my $block = shift @parts) {
        my $block_name    = shift @parts;
        my $block_content = shift @parts;

        if ($block_content) {
            my %token = (
                type     => 'BLOCK',
                name     => $block_name,
                template => $self->process_html_template( html=>$block_content ),
            );

            push @{ $template{'index'} }, \%token;

            $template{'has_block'}->{ $block_name } = 1;
        }
        else {
            $template{'has_var'}->{ $block_name } = 1;
        }

        # Append also the text after the block.
        # It can contain placeholders, so it must be procesed too.
        my $html_part = shift @parts;

        if ($html_part) {
            $self->extract_placeholders(
                template => \%template,
                html     => $html_part
            );
        }
    }

    return \%template;
} # }}}

# Extracts placeholders from given html text, and adds them to the template.
sub extract_placeholders { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            template => { type=>HASHREF },
            html     => { type=>SCALAR },
            lang     => { type=>SCALAR, optional=>1, },
        }
    );

    my @parts = split /~~([0-9a-zA-Z\-\_\.\:]+)~~/s, $P{'html'};

    # First part is in 100% a text :)
    push @{ $P{'template'}->{'index'} }, {
        type => 'TEXT',
        html => shift @parts
    };

    while (my $placeholder = shift @parts) {
        # First - check some special placeholders.
        my $token;
        if ($placeholder =~ m{^(.+?)_part$}s) {
            my $sub_template = $self->load_and_parse(
                name    => $placeholder,
                is_part => 1
            );

            assert_defined ($sub_template, "Sub template: $placeholder found.");

            $self->merge_has_things($P{'template'}, $sub_template);

#            use Data::Dumper; warn Dumper $sub_template->{'has_block'};

            $token = {
                type  => 'TEMPLATE',
                name  => $placeholder,

                template => $sub_template
            };
        }
        else {
            # A generic placeholder
            $token = {
                type  => 'PLACEHOLDER',
                name  => $placeholder,
            };
        }

        push @{ $P{'template'}->{'index'} }, $token;

        # Add the the text after the placeholder.
        push @{ $P{'template'}->{'index'} }, {
            type => 'TEXT',
            html => shift @parts
        };
    }

    return;
} # }}}

sub merge_has_things { # {{{
    my ( $self, $pool, $addition ) = @_;

    foreach my $has_ (qw( has_var has_block )) {
        foreach my $key (keys %{ $addition->{$has_} }) {
            $pool->{$has_}->{$key} = 1;
        }
    }

    return;
} # }}}

# This function will confess, if placeholder/list/grid/form name is invalid.
# This may mean that it contains unwelcome characters and such things.
sub validate_name { # {{{
    my ( $self, $name ) = @_;

    assert_defined(scalar $name =~ m{^([0-9a-zA-Z\-\_\.\:]+)$}s, "Name: $name is valid.");

    return $name;
} # }}}

# Insert one variable into document.
sub set_var { # {{{
    my ( $self, $name, $value ) = @_;

    assert_defined($value, "Define what you want to set");

    $self->validate_name($name);

#    if (not $self->{'template'}->{'has_var'}->{$name}) {
#        warn "Variable: $name does not exist in template\n";
#    }

    return $self->{'var_data'}->{$name} = $value;
} # }}}

# Insert some variables into document.
sub set_vars { # {{{
    my ( $self, %vars ) = @_;

    foreach my $name (keys %vars) {
        $self->validate_name($name);

        $self->{'var_data'}->{$name} = $vars{$name};
    }

    return \%vars;
} # }}}

# Insert list into document
sub set_list { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            name => { type=>SCALAR },
            data => { type=>ARRAYREF },
        }
    );
    
    $self->validate_name($P{'name'});

    return $self->{'list_data'}->{ $P{'name'} } = {
        data => $P{'data'}
    };
} # }}}

# Not used at the moment, uncomment when needed.
#
## Insert grid into document
#sub set_grid { # {{{
#    my $self = shift;
#    my $name  = shift;
#    my $value = shift;
#
#    $self->validate_name($name);
#
#    return $self->{'grid_data'}->{$name} = $value;
#} # }}}

# Insert layout into document
sub set_layout { # {{{
    my ( $self, $name, $value ) = @_;

    assert_defined($value, "Define what you want to set");

    $self->validate_name($name);

#    if (not $self->{'template'}->{'has_block'}->{$name}) {
#        warn "Block: $name does not exist in template\n";
#    }

#    use Data::Dumper; warn Dumper $value;

    return $self->{'layout_data'}->{$name} = $value;
} # }}}

# Returns true (1), if given 'thing' was defined in template.
# If it is not defined, returns false (0).

sub has_var { # {{{
    my ( $self, $name ) = @_;

    if ($self->{'template'}->{'has_var'}->{$name}) {
        return 1;
    }

    return 0;
} # }}}

sub has_block { # {{{
    my ( $self, $name ) = @_;

    if ($self->{'template'}->{'has_block'}->{$name}) {
        return 1;
    }

    return 0;
} # }}}

# Return HTML string, made from joining template and acumulated data.
sub render { # {{{
    my ( $self ) = @_;
    
    return $self->render_template(
        template => $self->{'template'},
        data     => {
            var_data    => $self->{'var_data'},
            list_data   => $self->{'list_data'},
            grid_data   => $self->{'grid_data'},
            layout_data => $self->{'layout_data'},
        }
    );
} # }}}

# Generate HTML from given template.
# In the process, function will recursively generate sub-templates as well.
sub render_template { # {{{
    my $self = shift;
    my %P = validate(
        @_,
        {
            template => { type=>HASHREF },
            data     => { type=>HASHREF },
        }
    );

    my %handlers = (
        TEXT        => 'process_text',
        PLACEHOLDER => 'process_placeholder',
        TEMPLATE    => 'process_template',
        BLOCK       => 'process_block',
    );

    my @html;
    foreach my $token (@{ $P{'template'}->{'index'} }) {
        my $handler = $handlers{ $token->{'type'} };

        my $string = $self->$handler( $token, $P{'data'} );
        if (defined $string) {
            push @html, $string;
        }
    }
    
    return join q{}, @html;
} # }}}

sub process_text { # {{{
    my ( $self, $token, $data ) = @_;

    return $token->{'html'};
} # }}}

sub process_placeholder { # {{{
    my ( $self, $token, $data ) = @_;

    return $data->{'var_data'}->{ $token->{'name'} };
} # }}}

sub process_template { # {{{
    my ( $self, $token, $data ) = @_;

    return $self->render_template( template=>$token->{'template'}, data=>$data );
} # }}}

# Parameters:
#   $self
#   token
#   data
#   force : when set, the block WILL be used, even if it's not defined in *_data
sub process_block { # {{{
    my ( $self, $token, $data, $force ) = @_;

    my $name = $token->{'name'};

#    warn "Procesing block ($name):\n";
#    warn Dump $token ."\n\n";

    if ($data->{'list_data'}->{$name}) {
        return $self->process_list_block($token, $name, $data->{'list_data'}->{$name}, $data);
    }

#    if ($data->{'grid_data'}->{$name}) {
#    }

    if ($data->{'layout_data'}->{$name}) {
        return $self->process_layout_block($token, $name, $data->{'layout_data'}->{$name}, $data);
    }

    if ($force or $data->{'var_data'}->{$name}) {
        # Block defined (or forced) - stays.
        return $self->render_template( template=>$token->{'template'}, data=>$data );
    }

    # Support for the TRUE/FALSE options.
    if ($name =~ m{^(.+?)-(TRUE|FALSE)$}s) {
        # It IS a true/false block.
        my $real_name = $1;
        my $option    = $2;

        if ($option eq 'TRUE' and $data->{'var_data'}->{$real_name}) {
            # Block stays, as it's TRUE => set...

            return $self->render_template( template=>$token->{'template'}, data=>$data );
        }
        elsif ($option eq 'FALSE' and not $data->{'var_data'}->{$real_name}) {
            # Block stays, as it's FALSE => not set...
            return $self->render_template( template=>$token->{'template'}, data=>$data );
        }
    }

    # We have found no reason to let this block stay.
    return q{};
} # }}}

# Extract Block's definition from Template.
sub extract_definition { # {{{
    my ( $self, $token ) = @_;

    my %definition;

    # Extract blocks from the template.
    my @blocks = $self->extract_blocks($token->{'template'}->{'index'});
    foreach my $block_token (@blocks) {
        if ($block_token->{'name'}) {
            $definition{ $block_token->{'name'} } = $block_token;
        }

        if ($block_token->{'template'}) {
            my %sub_def = $self->extract_definition($block_token);

            foreach my $key (keys %sub_def) {
                $definition{$key} = $sub_def{$key};
            }
        }
    }

#    warn "List definition: ". Dump \%definition;
#    warn "List definition items: ". join ", ", keys %definition;

    return %definition;
} # }}}

sub extract_blocks { # {{{
    my ( $self, $index ) = @_;

    my @blocks;

    foreach my $token (@{ $index }) {
        if ($token->{'type'} eq 'BLOCK') {
            push @blocks, $token;
        }
        elsif ($token->{'type'} eq 'TEMPLATE') {
            push @blocks, $self->extract_blocks($token->{'template'}->{'index'});
        }
    }

    return @blocks;
} # }}}

# Specialized BLOCK handlers.

# Parameters:
#    my $self  = 
#    my $token = 
#    my $name  = 
#    my $list  = 
#    my $data  = # Note: this is the TOTAL data of the template.
sub process_list_block { # {{{
    my ( $self, $token, $name, $list, $data ) = @_;

#    warn "List data ($name): ". Dump $list;

    my %definition = $self->extract_definition($token);

    my $html;

    # Add list header, if present.
    if ($definition{'header'}) {
        $html .= $self->process_block($definition{'header'}, $data, 1);
    }

    # Iterate over test items, procesing the same block, with different data.
    foreach my $item (@{ $list->{'data'} }) {
        # Merge global and local item's vars.
        my %item_data = (
            var_data => {
                (
                    %{ $data->{'var_data'} },
                    %{ $item }
                )
            }
        );

        # Recreate this block for every list item...
        $html .= $self->process_block($definition{'item'}, \%item_data, 1);
    }

    # Add list footer, if present.
    if ($definition{'footer'}) {
        $html .= $self->process_block($definition{'footer'}, $data, 1);
    }

    return $html;
} # }}}

sub process_layout_block { # {{{
    my ( $self, $token, $name, $layout ) = @_;

    my %definition = $self->extract_definition($token);

#    use Data::Dumper; warn Dumper $layout;

    my $html = $self->process_layout_element(\%definition, $layout);

#    if ($html eq q{}) { use Data::Dumper; warn Dumper $token; }

    return $html;
} # }}}

my %layout_elements = (
    Action        => { process_sub=>\&process_element_Action        },
    Check         => { process_sub=>\&process_element_Check         },
    Container     => { process_sub=>\&process_element_Container     },
    Counter       => { process_sub=>\&process_element_Counter       },
    Entry         => { process_sub=>\&process_element_Entry         },
    FileEntry     => { process_sub=>\&process_element_FileEntry     },
    Form          => { process_sub=>\&process_element_Form          },
    Grid          => { process_sub=>\&process_element_Grid          },
    GridItem      => { process_sub=>\&process_element_GridItem      },
    Image         => { process_sub=>\&process_element_Image         },
    Label         => { process_sub=>\&process_element_Label         },
    Text          => { process_sub=>\&process_element_Text          },
    Link          => { process_sub=>\&process_element_Link          },
    List          => { process_sub=>\&process_element_List          },
    ListItem      => { process_sub=>\&process_element_ListItem      },
    PasswordEntry => { process_sub=>\&process_element_PasswordEntry },
    ProgressBar   => { process_sub=>\&process_element_ProgressBar   },
    Radio         => { process_sub=>\&process_element_Radio         },
    SelectEntry   => { process_sub=>\&process_element_SelectEntry   },
    Status        => { process_sub=>\&process_element_Status        },
    Table         => { process_sub=>\&process_element_Table         },
    TableCell     => { process_sub=>\&process_element_TableCell     },
    TableRow      => { process_sub=>\&process_element_TableRow      },
    TextEntry     => { process_sub=>\&process_element_TextEntry     },
);
sub process_layout_element { # {{{
    my ( $self, $definition, $element ) = @_;

    assert_defined($element, 'Element is defined');

#    warn "Definitions: ". Dump $definition;
#    print STDERR "\n";

#    warn "Element: ". Dump $element;
#    print STDERR "\n";

#    warn "Definition: ". Dump $definition->{ $element->{'type'} };
#    print STDERR "\n";

    if (not ref $element) {
        # It's a scalar - pass it AS-IS - it does not depend on the template.
        # We do not want someone (by mistake, of course ;) - to abuse this functionality to pass raw HTML,
        # or anything similar, so let's quote it.

        # FIXME: Poor-man's quoting... but it's fast, and should be reliable-enough.
        $element =~ s{&}{&amp;}sg;
        $element =~ s{>}{&gt;}sg;
        $element =~ s{<}{&lt;}sg;

#        warn "QUOTTING!";

        return $element;
    }
    elsif (ref $element eq 'ARRAY') {
        my $html = q{};

        foreach my $sub_elem (@{ $element }) {
            $html .= $self->process_layout_element($definition, $sub_elem);
        }

        return $html;
    }

#    if (not defined $element->{'type'}) {
#        use Data::Dumper; warn Dumper $element;
#    }

    assert_defined($element->{'type'}, 'Type of the element is known');

    if (not $definition->{ $element->{'type'} }) {
        print STDERR "Layout element (". $element->{'type'} .") not defined in template!\n";

        use Data::Dumper; warn Dumper $definition;

        return q{};
    }

    my %element_variables = (
        &{ $layout_elements{ $element->{'type'} }->{'process_sub'} }( ($element->{'data'} or {}) ),
    );
    if ($element->{'class'}) {
        $element_variables{'Class'} = $element->{'class'};
    }
    if ($element->{'id'}) {
        $element_variables{'Id'} = $element->{'id'};
    }

    if ($element->{'content'}) {
        foreach my $child_element (@{ $element->{'content'} }) {
            $element_variables{'Content'} .= $self->process_layout_element($definition, $child_element);
        }
    }

#    if ($element->{'type'} eq 'Link') {
#        use Data::Dumper; warn Dumper $element;
#    }

    # Support for non-string Labels:
    if ($element->{'data'}->{'label'} and ref $element->{'data'}->{'label'}) {
        my $string = q{};

        foreach my $child_element (@{ $element->{'data'}->{'label'} }) {
            $string .= $self->process_layout_element($definition, $child_element);
        }

        $element_variables{'Label'} = $string;
    }

    my $html = $self->process_block($definition->{ $element->{'type'} }, { var_data=>\%element_variables }, 1);

#    warn "Generated HTML: ". $html;

    return $html;
} # }}}

sub process_element_List { # {{{
    my ( $data ) = @_;

    my %placeholders;

    return %placeholders;
} # }}}
sub process_element_GridItem { # {{{
    my ( $data ) = @_;

    my %placeholders;

    return %placeholders;
} # }}}
sub process_element_Grid { # {{{
    my ( $data ) = @_;

    my %placeholders;

    return %placeholders;
} # }}}
sub process_element_TextEntry { # {{{
    my ( $data ) = @_;

    return (
        Name  => ( $data->{'name'} or q{} ),
        Value => ( $data->{'value'} or q{} ),
    );
} # }}}
sub process_element_Status { # {{{
    my ( $data ) = @_;

    return (
        Status => ( $data->{'status'} or q{} )
    );
} # }}}
sub process_element_Entry { # {{{
    my ( $data ) = @_;

    assert_defined($data->{'name'},  "Name defined"); # Name is mandatory for form entries. In most cases, at least.
    assert_defined($data->{'value'}, "Value defined"); # Passing undef here is PROBABLY an error (typo in hash?).

    return (
        Name  => ( $data->{'name'} ),
        Value => ( $data->{'value'} ),
    );
} # }}}
sub process_element_FileEntry { # {{{
    my ( $data ) = @_;

    return (
        Name  => ( $data->{'name'} or q{} ),
    );
} # }}}
sub process_element_PasswordEntry { # {{{
    my ( $data ) = @_;
    
    return (
        Name  => ( $data->{'name'} or q{} ),
        Value => ( $data->{'value'} or q{} ),
    );
} # }}}
sub process_element_Radio { # {{{
    my ( $data ) = @_;

    my %placeholders;

    return %placeholders;
} # }}}
sub process_element_Label { # {{{
    my ( $data ) = @_;

    assert_defined($data->{'label'}, 'Text is defined.');

    return (
        Label => SLight::Output::HTML::Generator::token_to_html($data->{'label'})
    );
} # }}}
sub process_element_Text { # {{{
    my ( $data ) = @_;

    return (
        Text => SLight::Output::HTML::Generator::structure_to_html($data->{'text'})
    );
} # }}}
sub process_element_SelectEntry { # {{{
    my ( $data ) = @_;

    my $options;
    foreach my $item (@{ $data->{'options'} }) {
        my $selected = q{};
        if ($item->[0] eq $data->{'value'}) {
            $selected = q{ selected};
        }

        $options .= sprintf qq{<option value='\%s'\%s>\%s\n}, $item->[0], $selected, $item->[1];
    }
    
    return (
        Name    => ( $data->{'name'} or q{} ),
        Options => $options,
    );
} # }}}
sub process_element_Action { # {{{
    my ( $data ) = @_;

    return (
        Caption => ( $data->{'caption'} or $data->{'href'} or q{...}),
        Href    => ( $data->{'href'} or q{#} ),
    );
} # }}}
sub process_element_Counter { # {{{
    my ( $data ) = @_;

    my %placeholders;

    return %placeholders;
} # }}}
sub process_element_Container { # {{{
    my ( $data ) = @_;

    my %placeholders;

    return %placeholders;
} # }}}
sub process_element_Form { # {{{
    my ( $data ) = @_;

    my %replace = (
        Hidden => q{},
        Action => $data->{'action'},
        Submit => $data->{'submit'},
    );

    if (ref $data->{'hidden'} eq 'HASH') {
        foreach my $field (keys %{ $data->{'hidden'} }) {
            $replace{'Hidden'} .= q{<input type=hidden name="}. $field .q{" value="}. $data->{'hidden'}->{$field} .q{">};
        }
    }

    return %replace;
} # }}}
sub process_element_Link { # {{{
    my ( $data ) = @_;

    return (
        Label => ( $data->{'label'} or $data->{'href'} or q{...} ),
        Href  => ( $data->{'href'} or q{#} ),
    );
} # }}}
sub process_element_Image { # {{{
    my ( $data ) = @_;

    return (
        Label => ( $data->{'label'} or q{}),
        Href  => ( $data->{'href'} or q{#} ),
    );
} # }}}
sub process_element_ProgressBar { # {{{
    my ( $data ) = @_;

    my %pdata = (
        BarClass => $data->{'bar_class'},
        BarRange => $data->{'bar_range'},
        BarValue => $data->{'bar_value'},
    );
    
    if ($pdata{'BarRange'}) {
        $pdata{'Percent'} = sprintf "%d", 100 * $pdata{'BarValue'} / $pdata{'BarRange'};
    }
    else {
        $pdata{'Percent'} = q{};
    }

    return %pdata;
} # }}}
sub process_element_Table { # {{{
    my ( $data ) = @_;

    my %placeholders;

    return %placeholders;
} # }}}
sub process_element_TableRow { # {{{
    my ( $data ) = @_;

    my %placeholders;

    return %placeholders;
} # }}}
sub process_element_TableCell { # {{{
    my ( $data ) = @_;

    return (
        RowSpan => ( $data->{'rowspan'} or 0 ),
        ColSpan => ( $data->{'rowspan'} or 0 ),
    );
} # }}}
sub process_element_Check { # {{{
    my ( $data ) = @_;

    return (
        Name    => ( $data->{'name'} or q{} ),
        Checked => ( $data->{'checked'} or q{} ),
    );
} # }}}
sub process_element_ListItem { # {{{
    my ( $data ) = @_;

    my %placeholders;

    return %placeholders;
} # }}}

# Support for parsed HTML cache.

my %local_cache;

# Fetch parsed HTML from cache.
sub parsed_fetch { # {{{
    my ( $self, $file_path ) = @_;

    if ($local_cache{$file_path}) {
        return $local_cache{$file_path};
    }

#    my $template = Cache_Fetch_YAML( path=>$file_path );
    my $template = LoadFile( $file_path );

    # Re-load includes;
    $self->parsed_fetch_index_check($template->{'index'});

    $local_cache{$file_path} = $template;

    return $template;
} # }}}

# Store parsed HTML into cache.
sub parsed_store { # {{{
    my ( $self, $file_path, $template ) = @_;

    # Note: this is a workaround for YAML::Syck problems with many pointers to single reference.
    # It may not be needed in future.

    my %cloned_template = %{ $template };
    $cloned_template{'index'} = $self->_strip_templates_from_index($template->{'index'});

    # Workaround ends here.

    DumpFile($file_path, $template);

    return;
} # }}}

# Remove contents of 'template' key from TEMPLATE tokent.
# Index itself, and all changed tokens are copied.
sub _strip_templates_from_index { # {{{
    my ( $self, $index ) = @_;

    my @index_copy;
    foreach my $token (@{ $index }) {
        if ($token->{'type'} eq 'TEMPLATE') {
            # Copy is required, as token will be changed.
            my %copied_token = (
                type => $token->{'type'},
                name => $token->{'name'},

                template => {}
            );

            push @index_copy, \%copied_token;
        }
        elsif ($token->{'type'} eq 'BLOCK') {
            # Copy is required, as token will be changed.
            my %copied_token = (
                type => $token->{'type'},
                name => $token->{'name'},

                template => {
                    index => $self->_strip_templates_from_index($token->{'template'}->{'index'}),
                }
            );

            push @index_copy, \%copied_token;
        }
        else {
            # No need to copy.
            push @index_copy, $token;
        }
    }

    return \@index_copy;
} # }}}

# Go trough given index, and re-load any templates, that exist in it.
sub parsed_fetch_index_check { # {{{
    my ( $self, $index ) = @_;

    foreach my $token (@{ $index }) {
        if ($token->{'type'} eq 'TEMPLATE') {
            $token->{'template'} = $self->load_and_parse(
                name    => $token->{'name'},
                is_part => 1
            );
        }
        elsif ($token->{'type'} eq 'BLOCK') {
            $self->parsed_fetch_index_check($token->{'template'}->{'index'});
        }
    }

    return;
} # }}}

# vim: fdm=marker
1;
