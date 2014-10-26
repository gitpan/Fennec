package Fennec::TestSet;
BEGIN {
  $Fennec::TestSet::VERSION = '0.031';
}
use strict;
use warnings;

use base 'Fennec::Base::Method';

use Fennec::Parser;
use Fennec::Util::Accessors;
use Fennec::Exporter::Declare;
use Try::Tiny;
use Carp;
use B;

use Fennec::Util::Alias qw/
    Fennec::Runner
    Fennec::Output::Result
    Fennec::Workflow
    Fennec::Util
/;

use Time::HiRes qw/time/;
our $CURRENT;
sub current { $CURRENT };

Accessors qw/ workflow no_result observed created_in /;

export 'tests' fennec {
    my $name = shift;
    my %proto = @_ > 1 ? @_ : (method => shift( @_ ));
    my ( $caller, $file, $line ) = caller;
    $caller->fennec_meta->workflow->add_item(
        __PACKAGE__->new( $name,
            file => $file,
            line => $line,
            %proto
        )
    );
};

sub init {
    my $self = shift;
    $self->created_in( $$ );
}

sub run {
    my $self = shift;
    return Result->skip_testset( $self, $self->skip )
        if $self->skip;

    local $CURRENT = $self;
    try {
        my $start = time;
        $self->run_on( $self->testfile );
        my $end = time;
        Result->pass_testset( $self, [($end - $start)] ) unless $self->no_result;
    }
    catch {
        Result->fail_testset( $self, $_ );
    };
}

sub part_of {
    my $self = shift;
    my ( $search ) = @_;
    return 1 if $self->name eq $search;
    return 0 unless my $workflow = $self->workflow;
    do {
        return 1 if $workflow->name eq $search;
        $workflow = $workflow->parent;
    } while( $workflow && $workflow->isa( 'Fennec::Workflow' ));
    return 0;
}

sub testfile {
    my $self = shift;
    return unless $self->workflow;
    return $self->workflow->testfile;
}

sub skip {
    my $self = shift;
    return $self->SUPER::skip( @_ )
        || $self->workflow->skip;
}

sub todo {
    my $self = shift;
    return $self->SUPER::todo()
        || $self->workflow->todo;
}

sub DESTROY {
    my $self = shift;
    return unless $self->created_in == $$;
    return if $self->observed;
    warn <<EOT
Testset was never observed by the runner:
\tName: @{[ $self->name || "UNKNOWN" ]}
\tFile: @{[ $self->file || "UNKNOWN" ]}
\tLine: @{[ $self->line || "UNKNOWN" ]}

This is usually due to nesting a workflow within another workflow that does not
support nesting.

Workflow stack:
@{[ scalar Util->workflow_stack( $self->workflow )]}
EOT
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
