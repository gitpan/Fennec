package Fennec::Output::Result;
BEGIN {
  $Fennec::Output::Result::VERSION = '0.032';
}
use strict;
use warnings;

use base 'Fennec::Output';

use Fennec::Util::Accessors;
use Fennec::Runner;
use Fennec::Workflow;
use Try::Tiny;

use Time::HiRes qw/time/;
use Scalar::Util qw/blessed/;
use Fennec::Util::Alias qw/
    Fennec::Runner
/;

our @ANY_ACCESSORS = qw/ skip todo name line /;
our @SIMPLE_ACCESSORS = qw/ pass benchmark finishes testset_name /;
our @PROPERTIES = (
    @SIMPLE_ACCESSORS,
    @ANY_ACCESSORS,
    qw/ stderr stdout workflow_stack testfile timestamp file /,
);
our $TODO;

Accessors @SIMPLE_ACCESSORS;

sub TODO {
    my $class = shift;
    ($TODO) = @_ if @_;
    return $TODO;
}

sub fail { !shift->pass }

sub new {
    my $class = shift;
    my %proto = @_;
    my $pass = delete $proto{ pass };

    return bless(
        {
            $TODO ? ( todo => $TODO ) : (),
            %proto,
            pass => $pass ? 1 : 0,
            timestamp => time,
            $proto{'benchmark'} ? () : (benchmark => Runner->benchmark() || undef),
        },
        $class
    );
}

for my $any_accessor ( @ANY_ACCESSORS ) {
    no strict 'refs';
    *$any_accessor = sub {
        my $self = shift;
        return $self->{ $any_accessor }
            if $self->{ $any_accessor };

        my $meta = $self->testfile
            ? ( $self->testfile->can( 'fennec_meta' )
                ? $self->testfile->fennec_meta
                : undef
            ) : undef;
        my @any = ( $self->testset, $self->workflow, $meta ? $meta : () );
        for my $item ( @any ) {
            next unless $item;
            next unless $item->can( $any_accessor );

            my $found = $item->$any_accessor;
            next unless $found;

            return $found;
        }
    };
}

sub file {
    my $self = shift;
    return $self->{ file } if $self->{ file };

    my $meta = $self->testfile
        ? ( $self->testfile->can( 'fennec_meta' )
            ? $self->testfile->fennec_meta
            : undef
        ) : undef;
    my @any = ( $meta ? $meta : (), $self->testset, $self->workflow );
    my $found;
    for my $item ( @any ) {
        next unless $item;
        next unless $item->can( 'file' );

        $found = $item->file;
        next unless $found;
    }
    while ( ref $found ) {
        if ( $found->can( 'filename' )) {
            $found = $found->filename;
        }
        elsif ( $found->can( 'file' )) {
            $found = $found->file;
        }
        else {
            $found = 'Unknown File';
        }
    }
    $self->{ file } = $found;
}

for my $type ( qw/workflow testset/ ) {
    my $fail = sub {
        my $class = shift;
        my ( $item, @stderr ) = @_;
        $class->new(
            pass => 0,
            $type => $item,
            $item->can( 'name' ) ? ( name => $item->name ) : (),
            stderr => \@stderr,
            finishes => $type,
        )->write;
    };
    my $pass = sub {
        my $class = shift;
        my ( $item, $benchmark, @stderr ) = @_;
        $class->new(
            pass => 1,
            $type => $item,
            name => $item->name,
            benchmark => $benchmark,
            stderr => \@stderr,
            finishes => $type,
        )->write;
    };
    my $skip = sub {
        my $class = shift;
        my ( $item, $reason, @stderr ) = @_;
        $reason ||= $item->skip || "no reason";
        $class->new(
            pass => 1,
            $type => $item,
            name => $item->name,
            skip => $reason,
            stderr => \@stderr,
            finishes => $type,
        )->write;
    };
    no strict 'refs';
    *{ "fail_$type" } = $fail;
    *{ "pass_$type" } = $pass;
    *{ "skip_$type" } = $skip;
}

sub serialize {
    my $self = shift;
    my $data = { map {( $_ => ( $self->$_ || undef ))} @PROPERTIES };
    return {
        bless => ref( $self ),
        data => $data,
    };
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
