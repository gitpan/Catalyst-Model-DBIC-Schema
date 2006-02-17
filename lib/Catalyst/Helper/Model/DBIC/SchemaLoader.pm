package Catalyst::Helper::Model::DBIC::SchemaLoader;

use strict;
use warnings;
use Carp;

=head1 NAME

Catalyst::Helper::Model::DBIC::SchemaLoader - Helper for AutoLoaded DBIC Schema Models

=head1 SYNOPSIS

    script/myapp_create.pl model Foo DBIC::SchemaLoader dsn user password

    Where:
      Foo is the short name for the Model class being generated
      dsn, user, and password are the connection info

=head1 DESCRIPTION

This helper generates two classes:

First, it generates a L<DBIx::Class::Schema::Loader> class at
F<lib/MyApp/SchemaLoader/Foo.pm> based on your supplied dsn/user/pass.

Then, it generates a L<Catalyst::Model::DBIC::Schema> at
F<lib/MyApp/M/Foo.pm>, which references the above-generated loader.

Models generated by this Helper require the seperate package
L<DBIx::Class::Schema::Loader> to be installed.  It is on the recommended
list for this package, but is not required for installation.

=head2 METHODS

=head3 mk_compclass

=cut

sub mk_compclass {
    my ( $self, $helper, $dsn, $user, $pass ) = @_;

    $helper->{loader_class} = $helper->{class};
    $helper->{loader_class} =~ s/\:\:M(?:odel)?\:\:/::SchemaLoader::/;
    my @loader_parts = split(/\:\:/, $helper->{loader_class});
    my $loader_file_part = pop @loader_parts;

    my $loader_dir  = File::Spec->catfile( $helper->{base}, 'lib', @loader_parts );
    my $loader_file = File::Spec->catfile( $loader_dir, $loader_file_part . '.pm' );

    $helper->mk_dir($loader_dir);

    $helper->{dsn}          = $dsn  || '';
    $helper->{user}         = $user || '';
    $helper->{pass}         = $pass || '';

    $helper->mk_dir( $loader_dir );
    $helper->render_file( 'loaderclass', $loader_file );


    my $file = $helper->{file};
    $helper->render_file( 'compclass', $file );
}

=head1 SEE ALSO

General Catalyst Stuff:

L<Catalyst::Manual>, L<Catalyst::Test>, L<Catalyst::Request>,
L<Catalyst::Response>, L<Catalyst::Helper>, L<Catalyst>,

Stuff related to DBIC and this Model style:

L<DBIx::Class>, L<DBIx::Class::Schema>,
L<DBIx::Class::Schema::Loader>, L<Catalyst::Model::DBIC::Schema>,
L<Catalyst::Helper::Model::DBIC::Schema>

=head1 AUTHOR

Brandon L Black, C<blblack@gmail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

=begin pod_to_ignore

__DATA__

__loaderclass__
package [% loader_class %];

use strict;
use base qw/DBIx::Class::Schema::Loader/;

__PACKAGE__->load_from_connection(
    dsn     => '[% dsn %]',
    user    => '[% user %]',
    pass    => '[% pass %]',
    options => {
                  RaiseError         => 1,
                  PrintError         => 0,
                  ShowErrorStatement => 1,
                  TraceLevel         => 0,
                  AutoCommit         => 1,
                },
    relationships => 1,
    # debug => 1,
);

=head1 NAME

[% loader_class %] - Loader-generated DBIx::Class::Schema class

=head1 SYNOPSIS

See L<[% app %]>

=head1 DESCRIPTION

Generated by L<Catalyst::Model::DBIC::Schema> for use in L<[% class %]>

=head1 AUTHOR

[% author %]

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

__compclass__
package [% class %];

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => '[% loader_class %]',
);

=head1 NAME

[% class %] - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<[% app %]>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using L<DBIx::Class::Schema::Loader>
generated Schema: L<[% loader_class %]>

=head1 AUTHOR

[% author %]

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
