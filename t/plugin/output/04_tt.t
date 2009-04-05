use strict;
use warnings;
use Test::Base;
use App::Hachero;
use App::Hachero::Result;
use File::Spec;

BEGIN {
    eval {require 'Template'};
    if ($!) {
        plan skip_all => 'Template not available so skip this test';
    } else {
        plan tests => 1 * blocks;
        use App::Hachero::Plugin::Output::TT;
    }
}

filters {
    config => [qw(yaml)],
    result => [qw(yaml)],
    template => [qw(chomp)],
};

my $template = File::Spec->catfile(qw(t work template.tt));
my $out = File::Spec->catfile(qw(t work tt.out));

my $config = {
    plugins => [
        {
            module => 'Output::TT',
            config => {
                template => $template,
                out => $out,
            }
        },
    ],
};
my $app = App::Hachero->new({config => $config});

run {
    my $block = shift;
    $app->result({});
    for my $result (keys %{$block->result}) {
        my $r = App::Hachero::Result->new;
        for (@{$block->result->{$result}}) {
            $r->primary([keys %{$_}]) unless $r->primary;
            $r->push($_);
        }
        $app->result->{$result} = $r;
    }
    open my $fh_tt, '>', $template;
    print $fh_tt $block->template;
    close $fh_tt;
    $app->run_hook('output');
    open my $fh_out, '<', $out;
    my $output = do {local $/; <$fh_out>};
    close $fh_out;
    is $output, $block->expected;
    unlink $template;
    unlink $out;
}

__END__
===
--- config
plugins:
    - module: Output::TT
      config:
        template: t/work/template.tt
        out: t/work/tt.out
--- result
Hoge:
    - key: hooo
    - key: hooo
    - key: bar
    - key: bar
    - key: hooo
--- template
[% FOR r IN result -%]
[% r.key %]
[% FOR i IN r.value.values -%]
[% FOR k IN i.keys -%]
[% k %]: [% i.value(k) %]
[% END -%]
[% END -%]
[% END -%]
--- expected
Hoge
key: bar
count: 2
key: hooo
count: 3

