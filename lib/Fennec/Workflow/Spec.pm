package Fennec::Workflow::Spec;
BEGIN {
  $Fennec::Workflow::Spec::VERSION = '0.025';
}
use strict;
use warnings;
use Fennec::Parser;

use Fennec::Workflow qw/:subclass/;

use Fennec::Util::Alias qw/
    Fennec::Workflow
    Fennec::TestSet
    Fennec::TestSet::SubSet
    Fennec::TestSet::SubSet::Setup
    Fennec::Runner
    Fennec::Util::Accessors
/;

Accessors qw/ before_each before_all after_each after_all /;

sub init {
    my $self = shift;
    $self->$_([]) for qw/ before_each before_all after_each after_all /;
}

build_with 'describe';

export( 'it', 'fennec', sub {
    my $caller = caller;
    no strict 'refs';
    goto &{ $caller . '::tests' };
});

for my $name ( qw/ before_each before_all after_each after_all /) {
    Fennec::Parser->nameless( $name );
    export( $name, 'fennec', sub(&) {
        my ($sub) = @_;
        my ( $caller ) = caller;
        $caller->fennec_meta->workflow->add_item(
            Setup->new( $name => $sub )
        );
    });
}

sub testsets {
    my $self = shift;
    my @sets;
    my @_sets = ( @{ $self->_testsets }, map {( $_->testsets )} $self->workflows );

    if ( @{ $self->before_each } || @{ $self->after_each }) {
        for my $test ( @_sets ) {
            my $subset = SubSet->new(
                name => $self->name . ' (Setup/Teardown wrapper)',
                workflow => $self,
                file => $self->file,
                no_result => 1,
            );
            push @{ $subset->{tests} } => $test;
            $subset->setups( $self->before_each );
            $subset->teardowns( $self->after_each );
            push @sets => $subset;
        }
    }
    else {
        @sets = @_sets;
    }

    return @sets unless @{ $self->before_all } || @{ $self->after_all };

    my $subset = SubSet->new(
        name => $self->name,
        workflow  => $self,
        file => $self->file,
    );
    $subset->tests( \@sets );
    $subset->setups( $self->before_all );
    $subset->teardowns( $self->after_all );
    return ( $subset );
}

sub add_setup {
    my $self = shift;
    my ( $setup ) = @_;
    my $type = $setup->name;
    push @{ $self->$type } => $setup;
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
