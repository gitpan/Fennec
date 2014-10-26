package Fennec::Workflow::Case;
BEGIN {
  $Fennec::Workflow::Case::VERSION = '0.030';
}
use strict;
use warnings;

use Fennec::Workflow qw/:subclass/;

use Fennec::Util::Alias qw/
    Fennec::Workflow
    Fennec::TestSet
    Fennec::TestSet::SubSet
    Fennec::TestSet::SubSet::Setup
    Fennec::Runner
    Fennec::Util::Accessors
/;

Accessors qw/ cases /;

sub init {
    my $self = shift;
    $self->$_([]) for qw/ cases /;
}

build_with 'cases';
build_with( 'case', Setup );

sub testsets {
    my $self = shift;
    my @sets = @{ $self->_testsets };
    my @cases = @{ $self->cases };
    my @out;

    for my $case ( @cases ) {
        for my $test ( @sets ) {
            my $subset = SubSet->new(
                name => $case->name . " x " . $test->name,
                workflow => $self,
                file => $self->file,
            );
            push @{ $subset->{tests} } => $test;
            $subset->setups([ $case ]);
            push @out => $subset;
        }
    }

    return @out;
}

sub add_setup {
    my $self = shift;
    my ( $setup ) = @_;
    push @{ $self->cases } => $setup;
}

sub add_item {
    my $self = shift;
    my ( $item ) = @_;

    return $self->add_setup( $item )
        if $item->isa( Setup() );

    return $self->SUPER::add_item( $item );
}

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
