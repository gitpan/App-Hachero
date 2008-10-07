package App::Hachero::Plugin::OutputLine::HadoopMap;
use strict;
use warnings;
use base qw(App::Hachero::Plugin::Base);
use Data::Dumper;

sub output_line : Hook {
    my ($self, $context) = @_;
    my $fh = \*STDOUT;
    local $Data::Dumper::Indent = 0;
    local $Data::Dumper::Terse = 0;
    for my $prime_key (keys %{$context->result}) {
        my $result = $context->result->{$prime_key}->data;
        for my $second_key (keys %{$result}) {
            my $value = Dumper $result->{$second_key};
            printf $fh "%s-%s\t%s\n", $prime_key, $second_key, $value;
        }
    }
    $context->result( {} );
}

1;
__END__

=pod

=encoding utf8

=head1 NAME

App::Hachero::Plugin::OutputLine::HadoopMap - outputs results with hadoop format

=head1 SYNOPSYS

  ---
  plugins:
    - module: OutputLine::HadoopMap

=head1 DESCRIPTION

outputs results with hadoop format

=head2 implemented hooks

=over 4
    
=item * output_line

=back

=head1 AUTHOR

Nobuo Danjou <nobuo.danjou@gmail.com>

=head1 SEE ALSO

L<App::Hachero>

L<http://hadoop.apache.org>

=cut