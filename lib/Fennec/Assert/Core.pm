package Fennec::Assert::Core;
BEGIN {
  $Fennec::Assert::Core::VERSION = '0.030';
}
use strict;
use warnings;

our @CORE_LIST = qw/Simple More Exception Warn Anonclass Package/;

sub export_to {
    my $class = shift;
    my ( $dest, $prefix ) = @_;
    for my $item ( map { 'Fennec::Assert::Core::' . $_ } @CORE_LIST ) {
        eval "require $item; 1" || die ($@);
        $item->export_to( $dest, $prefix );
    }
}

sub import {
    my $class = shift;
    my ( $prefix ) = @_;
    my $caller = caller;
    $class->export_to( $caller, $prefix );
}

1;

=head1 NAME

Fennec::Assert::Core - Shortcut to load all core assertion libraries.

=head1 DESCRIPTION

Loads all the following assertion libraries:

=over 4

=item L<Fennec::Assert::Core::Simple>

=item L<Fennec::Assert::Core::More>

=item L<Fennec::Assert::Core::Exception>

=item L<Fennec::Assert::Core::Warn>

=item L<Fennec::Assert::Core::Package>

=item L<Fennec::Assert::Core::Anonclass>

=back

=head1 CLASS METHODS

=over 4

=item $class->export_to( $package )

=item $class->export_to( $package, $prefix )

Export all assertions to the specified package. An optional prefix may be
appended to all assertion names.

=back

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
