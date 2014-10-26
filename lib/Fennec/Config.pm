package Fennec::Config;
BEGIN {
  $Fennec::Config::VERSION = '0.025';
}
use strict;
use warnings;

our $CONFIG;

sub defaults {(
    '/etc/fennec/config.pm',
    ($ENV{HOME} || $ENV{USERPROFILE}) . '/.fennec/config.pm',
)}

sub fetch {
    unless ( $CONFIG ) {
        for my $file ( defaults() ) {
            next unless -e $file;
            my $data = do $file;
            next unless $data;
            $CONFIG = { ($CONFIG ? (%$CONFIG) : ()), %$data };
        }
        $CONFIG ||= {};
    }
    return (%$CONFIG);
}

sub reload {
    $CONFIG = undef;
    return (fetch());
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
