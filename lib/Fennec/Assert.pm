package Fennec::Assert;
BEGIN {
  $Fennec::Assert::VERSION = '0.026';
}
use strict;
use warnings;

use Fennec::Util::Alias qw/
    Fennec::Runner
    Fennec::Output::Result
    Fennec::Output::Diag
    Fennec::Output::Note
/;

use Try::Tiny;
use Fennec::Util::TBOverride;
use Carp qw/confess croak carp cluck/;
use Scalar::Util 'blessed';
use Exporter::Declare ':extend';
use Fennec::Util qw/test_caller/;

our @EXPORT = qw/tb_wrapper result diag test_caller note/;
our @CARP_NOT = qw/ Try::Tiny Benchmark /;

our $TB_RESULT;
our @TB_DIAGS;
our @TB_NOTES;
our $TB_OK = 0;

export util export;
sub util { goto &export }

sub _name_sub_and_assert_class_from_args {
    my ( $name, $sub, $assert_class );

    $sub = pop( @_ ) if ref( $_[-1] ) && ref( $_[-1] ) eq 'CODE';
    $assert_class = shift( @_ ) if @_ > 1 && defined( $_[1] );
    ( $name ) = @_;
    $assert_class = blessed( $assert_class ) || $assert_class || caller(1);
    $sub ||= $assert_class->can( $name );
    return (
        $name || undef,
        $sub || undef,
        $assert_class || undef,
    );
}

export tester export;
sub tester {
    my ( $name, $sub, $assert_class ) = _name_sub_and_assert_class_from_args( @_ );
    croak( "No code found in '$assert_class' for exported sub '$name'" )
        unless $sub;
    croak( "You must provide a name to tester()" )
        unless $name;

    my $wrapsub = sub {
        my @args = @_;
        my %caller = test_caller();
        return try {
            return _process_wrapped_results(
                \@args,
                _wrap_results( $sub, $assert_class, \@args )
            );
        }
        catch {
            my $err = [ "$name died: $_" ];
            return result( pass => 0, %caller, stderr => $err );
        };
    };

    $assert_class->export(
        $name,
        _wrap_with_proto( $wrapsub, prototype( $sub ))
    );
}

sub _wrap_results {
    my ( $sub, $assert_class, $args ) = @_;
    my @outresults;

    no warnings 'redefine';
    no strict 'refs';
    local *{ $assert_class . '::result' } = sub {
        shift( @_ ) if blessed( $_[0] );
        push @outresults => { @_ };
    };

    $sub->( @$args );
    return @outresults;
}

sub _process_wrapped_results {
    my ( $args, @outresults ) = @_;
    my %caller = test_caller();
    my $return = 1;

    for my $outresult ( @outresults ) {
        # Try to provide a minimum diag for failed tests that do not provide
        # their own.
        if ( !$outresult->{ pass } && !$outresult->{ stderr }) {
            my @diag = ("Assertion arguments were:");
            $outresult->{ stderr } = \@diag;
            for my $i ( 0 .. (@$args - 1)) {
                my $arg = $args->[$i];
                next if defined $arg
                     && "$arg" eq $outresult->{ name } || "";
                $arg = defined( $arg ) ? "'$arg'" : 'undef';
                push @diag => "\t$i: $arg";
            }
        }

        $return &&= result(
            %caller,
            %$outresult
        ) if $outresult;
    }

    return $return;
}

sub diag {
    shift( @_ ) if blessed( $_[0] )
                && blessed( $_[0] )->isa( __PACKAGE__ );
    Fennec::Output::Diag->new( stderr => \@_ )->write;
}

sub note {
    shift( @_ ) if blessed( $_[0] )
                && blessed( $_[0] )->isa( __PACKAGE__ );
    Fennec::Output::Note->new( stdout => \@_ )->write;
}

sub result {
    shift( @_ ) if blessed( $_[0] )
                && blessed( $_[0] )->isa( __PACKAGE__ );
    return unless @_;
    my %proto = @_;
    my $res = Result->new(
        @proto{qw/file line/} ? () : test_caller(),
        _current_conditions(),
        %proto,
    );
    $res->write;
    return $res->pass;
}

sub _current_conditions {
    my $current = Fennec::TestSet->current;
    return unless $current;
    my %out;
    $out{ todo } = $current->todo if $current->todo;
    $out{ skip } = $current->skip if $current->skip;
    $out{ workflow_stack } = [ Fennec::Util->workflow_stack( $current->workflow )];
    $out{ testset_name } = $current->name;
    return %out;
}

sub tb_wrapper(&) {
    shift( @_ ) if blessed( $_[0] )
                && blessed( $_[0] )->isa( __PACKAGE__ );
    my ( $orig ) = @_;
    my $wrapper = sub {
        my @args = @_;
        local $Fennec::Assert::TB_OK = 1;
        local $Fennec::Assert::TB_RESULT;
        local @Fennec::Assert::TB_DIAGS;
        local @Fennec::Assert::TB_NOTES;
        $orig->( @args );
        return diag( @TB_DIAGS ) unless $TB_RESULT;
        return result(
            pass      => $Fennec::Assert::TB_RESULT->[0],
            name      => $Fennec::Assert::TB_RESULT->[1],
            stderr    => \@Fennec::Assert::TB_DIAGS,
            stdout    => \@Fennec::Assert::TB_NOTES,
        );
    };
    return _wrap_with_proto( $wrapper, prototype( $orig ));
}

sub _wrap_with_proto {
    my ( $sub, $proto ) = @_;
    return $sub unless $proto;
    return eval "sub($proto) { \$sub->( \@_ )}"
        || die($@);
}
1;

=head1 DESCRIPTION

Fennec::Assert - Assertions (tester functions) for Fennec.

=head1 SEE ALSO

B<The synopsys and most of the other usage documentation has been moved, this
doc has been reduced to API documentation.>

L<Fennec::Manual::Assertions>

=over 4

=item $newsub = tb_wrapper( sub { ... })

=item $newsub = tb_wrapper( \&function_name )

Wrap a Test::Builder function (such as is_deeply()) with a Fennec wrapper that
provides extra information such as diagnostics, benchmarking, and scope/caller
information to generated results.

The wrapper function will be defined with the same prototype as the function
being wrapped. If the original was defined as sub($$) {...} then $newsub will
also have the ($$) prototype.

=item tester( 'name' )

=item tester( name => sub { ... })

In the first form you export a package sub as a tester by name. In the second
form you create a new export with an anonymous sub. Note: Your function will be
wrapped inside another function that provides extra information such as
diagnostics, benchmarking, and scope/caller information to generated results.

The wrapper function will be defined with the same prototype as the function
being wrapped. If the original was defined as sub($$) {...} then $newsub will
also have the ($$) prototype.

=item util( 'name' )

=item util( name => sub { ... })

In the first form you export a package sub as a util by name. In the second
form you create a new export with an anonymous sub. Note: Utility functions are
not wrapped like tester functions are, this means no free diagnostics, scope,
or caller. However unlike tester() a util can produce any number of results, or
no results at all.

=item %line_and_filename = test_caller()

Returns a hash containing the keys 'line' and 'file' which hold the filename
and line number of the most recent L<Fennec::TestFile> caller. It does not rely
on knowing how deep you are in the stack, or tracking anything, it searches the
stack from current backwords until it finds a testfile.

This is used in tester functions that have been wrapped to provide a line
number and filename to results. If you generate results in util or other
non-tester functions you can use this to add the line number and filename.

=item result( %result_proto )

Create and write a test result. %result_proto can have any keys that are valid
L<Fennec::Output::Result> construction parameters.

=item diag( @messages )

Issue a L<Fennec::Output::Diag> object with the provided messages.

=item note( @messages )

Issue a L<Fennec::Output::Note> object with the provided messages.

=back

=head1 CLASS METHODS

All of these are inherited by any class that uses L<Fennec::Assert>

=over 4

=item my $items = $class->exports()

Retrieve a hashref containing { name => sub {} } pairs for all exports provided
by your module.

=item $class->export_to( $dest_class )

=item $class->export_to( $dest_class, $prefix )

Export all exported subs to the specified package. If a prefix is specified
then all exported subs will be exported with that prefix.

=item $class->import()

=item $class->import( $prefix )

Called automatically when you use L<Fennec::Assert>. It will import all
exported subs into the calling class. If a prefix is specified then all
exported subs will be exported with that prefix. If the package being used is a
L<Fennec::Assert> itself then @ISA will be modified to subclass the calling
package. Assert subclasses do not modify the @ISA whent hey are used.

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
