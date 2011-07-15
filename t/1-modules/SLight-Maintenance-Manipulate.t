#!/usr/bin/perl
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
use FindBin qw{ $Bin };
use lib $Bin .'/../../lib/';
use utf8;

use Test::MockTime qw( :all );

use SLight::Test::Site;
use SLight::API::Content qw( get_Contents_where );
use SLight::API::Page qw( get_Pages_where );

use English qw( -no_match_vars );
use File::Slurp qw( read_file write_file );
use Test::More;
use Test::FileReferenced;
use Test::Output;
# }}}

plan tests =>
    + 3 # standard options...
    + 3 # --cms-list with all three formats.
    + 3 # --cms-get with all three formats.
    + 6 # --cms-set with all three formats, in such use-cases:
        #   XML  = update page + add content
        #   YAML = add page and content
        #   JSON = update content
    + 2 # --cms-delete
;
# Prepare 'Minimal' site... # {{{
my $site_root = SLight::Test::Site::prepare_fake(
    test_dir => $Bin . q{/../},
    site     => 'Minimal'
);

use SLight::Maintenance::Manipulate;

my $pepper = q{/tmp/manipulate_out_}. $PID . q{/};
mkdir $pepper;
# }}}


# Check standard options support.
output_like(
    sub { 
        SLight::Maintenance::Manipulate::main();
    },
    qr{Usage},
    undef,
    'Run with no params'
);
output_like(
    sub { 
        SLight::Maintenance::Manipulate::main(q{--help});
    },
    qr{Usage},
    undef,
    'Run with --help'
);
output_like(
    sub { 
        SLight::Maintenance::Manipulate::main(q{--version});
    },
    qr{version}s,
    undef,
    'Run with --version'
);


# If it dies, the test will die too, so why bother to check?
SLight::Maintenance::Manipulate::main(q{--cms-get}, q{/}, q{--format}, q{xml},  q{--output}, $pepper . 'get-xml');
SLight::Maintenance::Manipulate::main(q{--cms-get}, q{/}, q{--format}, q{yaml}, q{--output}, $pepper . 'get-yaml');
SLight::Maintenance::Manipulate::main(q{--cms-get}, q{/}, q{--format}, q{json}, q{--output}, $pepper . 'get-json');

is_referenced_ok(q{}.scalar read_file( $pepper . 'get-xml' ),  'Option --cms-get to XML');
is_referenced_ok(q{}.scalar read_file( $pepper . 'get-yaml' ), 'Option --cms-get to YAML');
is_referenced_ok(q{}.scalar read_file( $pepper . 'get-json' ), 'Option --cms-get to JSON');



# If it dies, the test will die too, so why bother to check?
SLight::Maintenance::Manipulate::main(q{--cms-list}, q{/}, q{--format}, q{xml},  q{--output}, $pepper . 'list-xml');
SLight::Maintenance::Manipulate::main(q{--cms-list}, q{/}, q{--format}, q{yaml}, q{--output}, $pepper . 'list-yaml');
SLight::Maintenance::Manipulate::main(q{--cms-list}, q{/}, q{--format}, q{json}, q{--output}, $pepper . 'list-json');

is_referenced_ok(q{}.scalar read_file( $pepper . 'list-xml' ),  'Option --cms-list to XML');
is_referenced_ok(q{}.scalar read_file( $pepper . 'list-yaml' ), 'Option --cms-list to YAML');
is_referenced_ok(q{}.scalar read_file( $pepper . 'list-json' ), 'Option --cms-list to JSON');



# If it dies, the test will die too, so why bother to check?
output_like(
    sub {
        eval {
            SLight::Maintenance::Manipulate::main(q{--cms-delete}, q{/Docs/});
        };
    },
    qr{status: OK},
    undef,
    "Options --cms-delete outputs a response."
);
# Check, if the page 'Doc' was really deleted.
is_referenced_ok(get_Pages_where(parent_id=>1), "Option --cms-delete does it's job");


set_fixed_time(1299511545);

# FIXME: write with some UTF-8!!!
write_file($pepper . q{set-xml}, q{<?xml version="1.0" encoding="utf-8" ?>
<SLightRPC>
    <Body>
        <Page>
            <template>Feedback</template>
        </Page>
        <Content>
            <comment_read_policy>0</comment_read_policy>
            <Content_Spec_id>1</Content_Spec_id>
            <on_page_index>0</on_page_index>\n
            <status>V</status>
            <comment_write_policy>0</comment_write_policy>
            <metadata/>
            <Email_id>5</Email_id>
            <Data>
                <en>
                    <article>Authors await your feedback ;)</article>
                    <title>Give Us feedback.</title>
                </en>
                <pl>
                    <article>Autorzy oczekuja na feedback ;)</article>
                    <title>Przeslijcie nam feedback!</title>
                </pl>
            </Data>
        </Content>
    </Body>
</SLightRPC>
});
#SLight::Maintenance::Manipulate::main(q{--cms-set}, q{/About/Authors/Feedback/}, q{--format}, q{xml}, q{--input}, $pepper . q{set-xml});
output_like(
    sub {
        eval {
            SLight::Maintenance::Manipulate::main(q{--cms-set}, q{/About/Authors/Feedback/}, q{--format}, q{xml}, q{--input}, $pepper . q{set-xml});
        };
    },
    qr{\<status\>OK\<\/status\>},
    undef,
    "Option --cms-set outputs a response."
);
is_referenced_ok(
    get_Contents_where(Page_Entity_id => 6),
    q{Option --cms-set XML - data OK}
);

write_file($pepper . q{set-yaml}, q{--- 
Body:
  Page:
    - template: Form
  Content:
    - comment_read_policy: 0
      Content_Spec_id: 1
      on_page_index: 0
      status: V
      comment_write_policy: 0
      metadata: \{ \}
      Email_id: 5
      Data:
        en:
          article: Please fill the form
          title: Feedback form.
        pl:
          article: Prosimy wypelnij formularz
          title: Formularz.
});

#warn "YAML:";
#SLight::Maintenance::Manipulate::main(q{--cms-set}, q{/About/Authors/Feedback/Form/}, q{--format}, q{yaml}, q{--input}, $pepper . q{set-yaml});
#warn "YAML OK";

output_like(
    sub {
        eval {
            SLight::Maintenance::Manipulate::main(q{--cms-set}, q{/About/Authors/Feedback/Form/}, q{--format}, q{yaml}, q{--input}, $pepper . q{set-yaml});
        };
    },
    qr{status: OK},
    undef,
    "Option --cms-set YAML outputs a response."
);

is_referenced_ok(
    get_Contents_where(Page_Entity_id => 7),
    q{Option --cms-set YAML - data OK}
);



write_file($pepper . q{set-json}, '{ 
  "Body": {
    "Page": [
      {
        "template": "Form"
      }
    ],
    "Content": [
      {
        "id" : 4,
        "comment_read_policy" : 0,
        "Content_Spec_id" : 1,
        "on_page_index" : 0,
        "status" : "A",
        "comment_write_policy" : 0,
        "metadata" : { },
        "Data" : {
          "en" : {
            "article" : "Please fill the feedback form",
            "title" : "Feedback form."
          },
          "pl" : {
            "article" : "Prosimy wypelnij formularz komentarza",
            "title" : "Formularz."
          }
        }
      }
    ]
  }
}
');

#warn "JSON:";
#SLight::Maintenance::Manipulate::main(q{--cms-set}, q{/About/Authors/Feedback/Form/}, q{--format}, q{json}, q{--input}, $pepper . q{set-json});
#warn "JSON OK";

#SLight::Maintenance::Manipulate::main(q{--cms-set}, q{/About/Authors/Feedback/Form/}, q{--format}, q{json}, q{--input}, $pepper . q{set-json});

output_like(
    sub {
        eval {
            SLight::Maintenance::Manipulate::main(q{--cms-set}, q{/About/Authors/Feedback/Form/}, q{--format}, q{json}, q{--input}, $pepper . q{set-json});
        };
    },
    qr{"status":"OK"},
    undef,
    "Option --cms-set JSON outputs a response."
);

is_referenced_ok(
    get_Contents_where(Page_Entity_id => 7),
    q{Option --cms-set JSON - data OK}
);




END {
    system q{rm}, q{-rf}, $pepper;
}

# vim: fdm=marker
