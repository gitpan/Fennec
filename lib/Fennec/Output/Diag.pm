package Fennec::Output::Diag;
BEGIN {
  $Fennec::Output::Diag::VERSION = '0.026';
}
use strict;
use warnings;

use base 'Fennec::Output';

sub new {
    my $class = shift;
    return bless( { @_ }, $class );
}

1;

=head1 NAME

Fennec::Output::Diag - Represents a diagnostics output object.

=head1 DESCRIPTION

See L<Fennec::Output>

=head1 SYNOPSIS

    use Fennec::Output::Diag;
    $diag = Fennec::Output::Diag->new( stderr => \@messages );

=head1 MANUAL

=over 2

=item L<Fennec::Manual::Quickstart>

The quick guide to using Fennec.

=item L<Fennec::Manual::User>

The extended guide to using Fennec.

=item L<Fennec::Manual::Developer>

The guide to developing and extending Fennec.

=item L<Fennec::Manual>

Documentation guide.

=back

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2010 Chad Granum

Fennec is free software; Standard perl licence.

Fennec is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the license for more details.
