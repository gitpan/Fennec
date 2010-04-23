package Fennec::Assert::Interceptor;
use strict;
use warnings;

use Fennec::Assert;

use Fennec::Util::Alias qw/
    Fennec::Collector::Interceptor
    Fennec::Runner
/;

util capture => sub(&) {
    my ( $code ) = @_;
    my $collector = Interceptor->new;
    Runner->run_with_collector( $collector, $code );
    return $collector->intercepted;
};

util ln => sub {
    my ( $diff ) = @_;
    my ( undef, undef, $line ) = caller;
    return $line + $diff;
};

tester result_line_numbers_are => sub {
    my ( $results, @numbers ) = @_;
    result(
        pass => 0,
        name => "result+line counts match",
        stderr => "Number of results, and number of line numbers do not match"
    ) unless @$results == @numbers;

    my $count = 0;
    for my $result ( @$results ) {
        result_line_number_is(
            $result,
            $numbers[$count],
            "Line number for result #$count is " . $numbers[$count]
        );
        $count++;
    }
};

tester 'result_line_number_is';
sub result_line_number_is {
    my ( $result, $number, $name ) = @_;
    my $pass = $number == $result->line ? 1 : 0;
    result(
        pass => $pass,
        name => $name,
        $pass ? () : (stderr => [ "Got: " . $result->line, "Wanted: $number" ]),
    );
};

1;

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2010 Chad Granum

Fennec is free software; Standard perl licence.

Fennec is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the license for more details.
