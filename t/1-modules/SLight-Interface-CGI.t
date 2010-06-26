#!/usr/bin/perl
use strict; use warnings; # {{{
use FindBin qw( $Bin );
use lib $Bin . q{/../../lib/};

use Test::More;
use utf8;
# }}}

use SLight::Interface::CGI;

plan tests =>
    + 1 # smoke test, normal
    + 1 # smote test, broken URL
#    + 1 # smote test, relocation
#    + 1 # smote test, internal error
#    + 1 # smote test, cookie parsing
#    + 2 # smote test, sending file
#    + 1 # Test, if truncated form data will trigger error
;

open STDIN, q{<}, $Bin . q{/../query_string.txt};

my $interface = SLight::Interface::CGI->new();

# There are OTHER tests, that check this:
$ENV{'SLIGHT_SKIP_AUTH'} = 1;

my $html = $interface->main(
    url => '/_Test/',
    bin => $Bin,
);

ok($html, 'html was generated');

# From this point CGI will analize language configuration sent from browser.
$ENV{'HTTP_ACCEPT_LANGUAGE'} = q{foo,bar-baz;q=0.7,en;q=0.3};

$html = $interface->main(
    url => '/---',
    bin => $Bin,
);

ok($html, 'html was generated (broken URL)');

=pod

Temporarly disabled.

$html = $interface->main(
    url => '/Content/delete.tht',
    bin => $Bin,
);

ok($html, 'html was generated (relocation)');

# Check error handling.

$ENV{'CONFESS_IN_TEST'} = 1;

diag("You will see an error message - it's a part of the test. If the test passes - everything is OK");

$html = $interface->main(
    url => '/Test/overview.test',
    bin => $Bin,
);
diag("Now, the test...");

like($html, qr{Internal Server error}, 'html was generated (confess)');

delete $ENV{'CONFESS_IN_TEST'};

# Check HTTP Cookie support.
# Two false, and one session cookie.

$ENV{'HTTP_COOKIE'} = q{Foo=Bar; SLightSesId=379A7C9E-B1CD-11DD-88FF-FF22071AC5A9; Baz=Rot};

# This should also trigger the SSIM support.
$ENV{'QUERY_STRING'} = q{123,456};

$html = $interface->main(
    url => '/Test/Test/',
    bin => $Bin,
);

like($html, qr{Set-Cookie: SLightSesId=.+?; path=/}, 'Cookie and SSIM usable');

$ENV{'SEND_FILE_IN_TEST'} = $Bin .q{/../Foo.txt};

$html = $interface->main(
    url => '/Test/Test/',
    bin => $Bin,
);
like($html, qr{test/file}, "send file: mime set");
like($html, qr{\nFoo$}s, "send file: contents OK");

delete $ENV{'SEND_FILE_IN_TEST'};

# Check if 'form was truncated' does not go without an error!
open STDIN, q{<}, $Bin .q{/../query_string_too_big.txt};

CGI::Minimal::reset_globals();

$ENV{'REQUEST_METHOD'} = 'POST';
$ENV{'CONTENT_LENGTH'} = 102400;

$html = $interface->main(
    url => '/Test/Test/',
    bin => $Bin,
);
like($html, qr{Form data has been truncated}, "Internal error after form truncated");

=cut

# vim: fdm=marker
