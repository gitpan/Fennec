package Fennec::Util::Alias;
BEGIN {
  $Fennec::Util::Alias::VERSION = '0.031';
}
use strict;
use warnings;
use Carp;

sub import {
    my $class = shift;
    my $caller = caller;

    for my $import ( @_ ) {
        eval "require $import; 1" || croak( $@ );
        my $name = $import;
        $name =~ s/.*\::([^:]+)$/$1/;
        no strict 'refs';
        *{ $caller . '::' . $name } = sub {
            my $alias = $import->can( 'alias' );
            return $import unless $alias;

            my @caller = caller;
            return $import->alias( \@caller, @_ );
        };
    }
}

1;

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 NAME

Fennec::Util::Alias - Require packages and alias the package name.

=head1 DESCRIPTION

Load a list of modules and alias the package name to the last portion of the
package name. Packages can implement an alias() method to override the behavior
of the alias.

=head1 SYNOPSIS

    package MyPackage;
    use Fennec::Util::Alias qw/
        Fennec::Output::Result
        Fennec::Output::Diag
    /;

    Result->new();
    Diag->new();

    1;

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
