package Fennec::Manual;
use strict;
use warnings;

1;

__END__

=head1 NAME

Fennec::Manual - Manual for Fennec.

=head1 DESCRIPTION

L<Fennec> provides a solid base that is highly extendable. It allows for the
writing of custom nestable workflows (like RSPEC), Custom Asserts (like
L<Test::Exception>), Custom output handlers (Alternatives to TAP), Custom file
types, and custom result passing (collectors). In L<Fennec> all test files are
objects. L<Fennec> also solves the forking problem, thats it, forking just
plain works.

=head1 EARLY VERSION WARNING

L<Fennec> is still under active development, many features are untested or even
unimplemented. Please give it a try and report any bugs or suggestions.

=head1 USAGE DOCUMENTATION

This covers basic usage of L<Fennec> if you just want to start writing tests.

=over 4

=item Quick Start

L<Fennec::Manual::Quickstart> - Drop Fennec standalone tests into an existing
suite.

=item Fennec Based Test Suite

L<Fennec::Manual::TestSuite> - How to create a Fennec based test suite.

=item Command Line Tools

L<Fennec::Manual::CommandLine> - Command line tools provided by L<Fennec>.

=item Vim tools

L<Fennec::Manual::Vim> - Vim tools and rc files provided with the dist.

=item Running Fennec

L<Fennec::Manual::Running> - How to run individual Fennec test files, or even
zeroing in on specific testsets.

=back

=head1 ASSERTIONS (TESTERS)

Assertions are the actuals testers. ok(), is(), etc. are all assertions. A
testset is comprised of 0 or more such assertions. Each assertion sends a
result to the handler(s).

Each testset itself generates an additional result when completed.
Testset results are true if the testset lived, false if it died. This allows
the use of 'traditional' assertions which do nothing if successful, but die
upon failure. Most Fennec assertions work like Test::Builder based tools, they
do not die upon failure.

=over

=item Writing Assertion Libraries

L<Fennec::Manual::Assertions> - Guide to writing custom assertion libraries

=item Using Test::Builder Based Tools

Many L<Test::Builder> tools will work as expected within Fennec, however some
may require, or can be improved by wrapping them into Fennec.

L<Fennec::Manual::TBAssertions> - Guide to wrapping L<Test::Builder> based
tools for use within fennec.

=item Core Assertion Libraries

Many of these were named to reflect which Test::XXX module they mimic. All Core
assertion libraries are imported by default.

L<Fennec::Assert::Core::Simple> - ok(), use_ok, and similar assertions.

L<Fennec::Assert::Core::More> - Assertions for comparing data and
structures.

L<Fennec::Assert::Core::Exception> - Assertions for testing exceptions.

L<Fennec::Assert::Core::Warn> - Assertions for testing warnings.

L<Fennec::Assert::Core::Anonclass> - Create anonymous objects based on
specifications, created objetcs will have assertions as methods ($obj->is(),
$obj->can_ok(), etc...)

=item TBCore Assertion Libraries

If you prefer to use the well tested and commonly used L<Test::Builder> based
tools instead of the Fennec implementations then L<Fennec::Assert::TBCore> is
here to serve you.

L<Fennec::Assert::TBCore::Simple> - L<Test::Simple>

L<Fennec::Assert::TBCore::More> - L<Test::More>

L<Fennec::Assert::TBCore::Exception> - L<Test::Exception>

L<Fennec::Assert::TBCore::Warn> - L<Test::Warn>

=back

=head1 WORKFLOWS

Workflows are ways to seperate, group, and structure tests. A good example of a
test workflow would be Ruby's RSPEC. Fennec has an implementation of the SPEC
workflow in addition to others.

=over

=item Writing Custom Workflows

L<Fennec::Manual::Workflows>

=item Core workflows

L<Fennec::Workflow::Module> - Workflow that lets you define testsets and
setup/teardown as methods on your test object.

L<Fennec::Workflow::SPEC> - Implementation of the SPEC test workflow

L<Fennec::Workflow::Case> - A workflow that lets you run testsets under
multiple cases.

=back

=head1 RESULT HANDLERS

A Result handler is a single object in the root process to which all results
are passed as they are collected. The handler is responsible for doing
something useful with them. The default handler is the TAP handler which
provides TAP output. Multiple handlers can be used at a time, and they can do
anything they want with the results.

=over

=item Writing Custom Handlers

L<Fennec::Manual::Handlers>

=item Core Handlers

L<Fennec::Handler::TAP> - Produces TAP output for result objects.

=back

=head1 COLLECTORS

Fennec has test parallelization, this means forking into multiple processes.
Collectors are responsible for funneling all results to the parent process
where they are then sent to handlers. A collector needs to implement 2 things,
a writer method that takes results as input, and a cull method which collects
the results.

=over

=item Writing Custom Collectors

L<Fennec::Manual::Collectors>

=item Core Collectors

L<Fennec::Collectors::Files> - The default, writes results as files in
_results, then in the parent process these files are read.

L<Fennec::Collectors::Interceptor> - Used by Fennec::Assert::Interceptor in
order to capture results instead of sending them to the handlers, this is not a
true collector, but a perfectly valid use of the framework.

=back

=head1 FILE TYPES

When Fennec was first conceptualized there was mention of TestML
L<http://www.testml.org>, as well I decided it would be useful to be able to
customise how test files are found/loaded. This led me to make loading test
files a pluggable system. Using custom file loaders you can potentially use any
type of test files you would like.

*There is not currently a TestML plugin, sorry.

=over

=item Writing Custom File Types

L<Fennec::Manual::Files>

=item Core File Loaders

L<Fennec::FileLoader::Module> - The default, looks for .pm files in t/ and
loads them as standard perl modules.

L<Fennec::FileLoader::Standalone> - Used in standalone tests.

=back

=head1 OTHER DOCUMENTATION

=over

=item Mission

L<Fennec::Manual::Mission> - Why does Fennec exist?

=back

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2010 Chad Granum

Fennec is free software; Standard perl licence.

Fennec is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the license for more details.
