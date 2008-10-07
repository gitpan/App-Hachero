use strict;
use warnings;
use Test::More;
use App::Hachero;
use File::Spec;

BEGIN {
    if ($ENV{HACHERO_TEST_FTP}) {
        plan tests => 2;
        use_ok('App::Hachero::Plugin::Fetch::FTP');
    } else {
        plan skip_all => 'set "TEST_HACHERO_FTP" to run this test.';
        exit 0;
    }
}

my $config = {
    plugins => [
        {
            module => 'Fetch::FTP',
            config => {
                host => 'ftp.riken.jp',
                username => 'anonymous',
                file => '/lang/CPAN/README',
            }
        }
    ],
    global => {
        work_path => 't/work',
    },
};
my $app = App::Hachero->new({config => $config});
$app->initialize;
$app->run_hook('fetch');

my $log = File::Spec->catfile( qw( t work README ) );
ok -e $log;

END {
    my $log = File::Spec->catfile( qw( t work README ) );
    unlink $log;
}

1;