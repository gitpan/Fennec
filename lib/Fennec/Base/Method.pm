package Fennec::Base::Method;
BEGIN {
  $Fennec::Base::Method::VERSION = '0.030';
}
use strict;
use warnings;

use Fennec::Util::Alias qw/
    Fennec::Util::Accessors
    Fennec::Util::Sub
/;
use Carp;
use Fennec::Util qw/test_caller/;
use B;

Accessors qw/method name file line skip todo/;

sub proto {()}

sub end_line { shift->specs->end_line }
sub start_line { shift->specs->start_line }

sub specs {
    my $self = shift;
    $self->{ specs } = Sub->new( $self->method )
        unless $self->{ specs };
    return $self->{ specs };
}

sub lines_for_filter {
    my $self = shift;
    return ( $self->start_line, $self->end_line );
}

sub _method_proto {
    my $class = shift;
    return ( $_[0] ) if @_ == 1;
    my %proto = @_;
    return ( $proto{ method }, %proto );
}

sub new {
    my $class = shift;
    my $name = shift;
    my ( $method, %proto ) = $class->_method_proto( @_ );
    confess( "$class must be created with a method " )
        unless $method;

    my %tc = test_caller();
    my $end_line = $tc{line};

    my $self = bless(
        {
            $class->proto,
            %proto,
            specs  => Sub->new( $method, $end_line ),
            name   => $name,
            method => $method,
        },
        $class
    );
    my $init = $self->can( 'init' ) || $self->can( 'initialize' );
    $self->$init( $name, @_ ) if $init;
    return $self;
}

sub run_on {
    my $self = shift;
    my ( $on, @args ) = @_;
    my $code = $self->method;
    $on->$code( @args );
}

1;

=head1 NAME

Fennec::Base::Method - Base class for objects that are blessed methods.

=head1 METHODS

=over 4

=item %proto = $class->proto()

Define a generic protoype to use in all new objects. Prototype specified in
constructor takes priority over these options. This is an abstract method,
default sumply returns an empty list.

=item $obj = $class->new( $name, sub { ... })

=item $obj = $class->new( $name, method => sub { ... }, %proto )

Create a new instance of the object, $name and method are required, method can
be the second argument, or specified with method => sub {} when providing
extended paramaters.

=item $obj->run_on( $other_obj, @args )

Run the object as a method on the object specified as the first argument.
Additional arguments are passed into the method invocation.

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
