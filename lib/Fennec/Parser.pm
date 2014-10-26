package Fennec::Parser;
BEGIN {
  $Fennec::Parser::VERSION = '0.030';
}
use strict;
use warnings;

use Devel::Declare::Interface;
use base 'Exporter::Declare::Export';
BEGIN { Devel::Declare::Interface::register_parser( 'fennec' )};

our %NAMELESS;
sub nameless { $NAMELESS{ $_[-1] }++ }
sub is_nameless { $NAMELESS{ shift->name }}

sub args {(qw/name/)}

sub inject {
    my $self = shift;
    return if $self->is_nameless;
    return if $self->has_fat_comma;
    return ('my $self = shift');
}

sub rewrite {
    my $self = shift;

    return 1 if $self->is_nameless;

    $self->strip_prototype;
    $self->_check_parts;

    my $is_arrow = $self->parts->[1]
                && ($self->parts->[1] eq '=>' || $self->parts->[1] eq ',');
    if ( $is_arrow && $self->parts->[2] ) {
        my $is_ref = ref( $self->parts->[2] );
        my $is_sub = $is_ref ? $self->parts->[2]->[0] eq 'sub' : 0;

        if ( !$is_ref ) {
            $self->new_parts([ $self->parts->[0], $self->parts->[2] ]);
            return 1;
        }
        elsif ( $is_sub ) {
            $self->new_parts([ $self->parts->[0] ]);
            return 1;
        }
        else {
            $self->bail( 'oops' );
        }
    }

    my ( $names, $specs ) = $self->sort_parts();
    $self->new_parts([
        @$names,
        @$specs
            ? (
                ( map { $_->[0] } @$specs ),
                ['method']
            )
            : ()
    ]);

    1;
}


1;

__END__

=head1 NAME

Devel::Declare::Parser::Export - The parser behind the export() magic.

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

Devel-Declare-Parser is free software; Standard perl licence.

Devel-Declare-Parser is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the license for more details.
