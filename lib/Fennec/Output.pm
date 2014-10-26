package Fennec::Output;
BEGIN {
  $Fennec::Output::VERSION = '0.031';
}
use strict;
use warnings;

use Fennec::Util::Accessors;
use Fennec::Util::Abstract;
use Fennec::Util::Alias qw/
    Fennec::Runner
    Fennec::Util
/;

Accessors qw/ stdout stderr _workflow testset timestamp /;

sub workflow_stack {
    my $self = shift;

    unless ( exists $self->{ workflow_stack }) {
        my @stack = Util->workflow_stack( $self->workflow );
        return unless @stack;
        $self->{ workflow_stack } = \@stack;
    }
    return $self->{ workflow_stack };
}

sub serialize {
    my $self = shift;
    return {
        data => {
            %$self,
            _workflow => undef,
            testset => undef,
            workflow_stack => $self->workflow_stack || undef,
        },
        bless => ref( $self ),
    };
}

sub deserialize {
    my $class = shift;
    my ($serialized) = @_;
    my $bless = $serialized->{ bless };
    my $data = $serialized->{ data };
    eval "require $bless" || die( $@ );
    return bless( $data, $bless );
}

sub write {
    my $self = shift;
    $self->timestamp( time() ) unless $self->timestamp;
    Runner->collector->write( $self );
}

sub testfile {
    my $self = shift;
    return $self->{ testfile } if $self->{ test_file };

    if ( my $workflow = $self->workflow ) {
        return $workflow if $workflow->isa( 'Fennec::TestFile' );
        my $testfile = $workflow->testfile if $workflow->can( 'testfile' );
        return $testfile if $testfile;
    }
    return $self->{ testfile };
}

sub workflow {
    my $self = shift;
    unless( $self->_workflow ) {
        return unless $self->testset;
        $self->_workflow( $self->testset->workflow );
    }
    return $self->_workflow;
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
