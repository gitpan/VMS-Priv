package VMS::Priv;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw();
@EXPORT_OK = qw(&add_current_privs &get_auth_privs       &get_current_privs
                &get_process_privs &remove_current_privs &set_current_privs
                &priv_names        &get_settable_privs   &get_default_privs);
$VERSION = '1.2';

bootstrap VMS::Priv $VERSION;

# Preloaded methods go here.

sub new {
  my($pkg,$pid) = @_;
  my $self = { __PID => $pid || $$ };
  bless $self, $pkg; 
}

sub current_privs { get_current_privs($_[0]->{__PID}); }
sub auth_privs    { get_auth_privs   ($_[0]->{__PID}); }
sub process_privs { get_process_privs($_[0]->{__PID}); }

# Use & notation to pass @_ through
sub add           { shift; &add_current_privs;    }
sub remove        { shift; &remove_current_privs; }
sub set           { shift; &set_current_privs;    }


sub TIEHASH { my $obj = new VMS::Priv @_; $obj->{__PRMFLG} = $_[1] || 0; $obj; }
sub FETCH   { exists $_[0]->current_privs->{$_[1]}; }
sub EXISTS  { exists $_[0]->current_privs->{$_[1]}; }
sub STORE   {
  my($self,$priv,$val) = @_;
  if (defined $val and $val) { $self->add([ $priv ],$self->{__PRMFLG});    }
  else                       { $self->remove([ $priv ],$self->{__PRMFLG}); }
}
sub DELETE  { $_[0]->remove([ $_[1] ],$_[0]->{__PRMFLG}); }
sub CLEAR   { $_[0]->remove([ keys %{$_[0]->current_privs} ],$_[0]->{__PRMFLG}) }
sub FIRSTKEY {
  $_[0]->{__ITERLIST} = [ keys %{$_[0]->current_privs} ];
  shift @{$_[0]->{__ITERLIST}};
}
sub NEXTKEY { shift @{$_[0]->{__ITERLIST}}; }

sub get_settable_privs {
  return { map { ($_,1) }
           keys %{$_[0]->get_auth_privs()}, keys %{$_[0]->get_image_privs()}
         };
}


# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

VMS::Priv - Get and set priviliges for VMS processes

=head1 SYNOPSIS

  use VMS::Priv;

Routines to return different sets of priviliges:

  @names = priv_names();
  $hashref = get_current_privs([pid]);
  $hashref = get_auth_privs([pid]);
  $hashref = get_process_privs([pid]);
  $hashref = get_image_privs([pid]);
  $hashref = get_default_privs([pid])
  $hashref = get_settable_privs([pid])

Routines to add or remove priviliges:

  $hashref = add_current_privs(\@priv_list[,permanent]);
  $hashref = remove_current_privs(\@priv_list[,permanent]);
  $hashref = set_current_privs(\@priv_list[,permanent]);

Tied Hash Interface:

  tie %privtie, VMS::Priv;

=head1 DESCRIPTION

Get and set privileges for VMS processes. The user running the script
must have sufficient privs to actually perform the act.

=head2 Tied hash interface

This really needs to be documented, but since I don't speak tied hash,
it'll have to wait for someone else, alas.

=head2 Object interface

The C<priv_names()> function simply returns as a list of the canonical names
of all the privileges VMS::Priv knows about.  Note that some privileges have
common aliases as well (I<e.g.> C<SETPRI> and C<ALTPRI>).  The VMS::Priv
functions which set privileges understand these aliases as well.

All other routines return a reference to a hash whose keys are the canonical 
names (only) of the privileges which are enabled. The get routines return the
set of privs you asked for, the add/remove/set routines return the privs that
you have after the call is complete.

The add/remove/set routines take as their first argument a reference to a
list of keywords designating the privileges you want to affect.
Case is not significant.  C<add_current_privs()> adds the list of privs to
your process, C<remove_current_privs()> takes the list of privs away from your
process, and C<set_current_privs()> gives just those privs to your process.
The second argument is a Boolean value which if true specifies that these
changes should persist after Perl exits; it defaults to true.

C<get_settable_privs()> returns a list of all the privs you can turn
on. It's a combination of the process's authorized privs and the process's
image privs.

C<get_default_privs()> returns a list of the privs the user who's process
you're looking up gets by default. These may not be the default privs that
were in place when the process was created. You also may bot be able to grant
all the default privs to your process, since it is entirely possible to have
more privs turned on by default than you have authorized. Default unauthorized
privs, once dropped, are lost forever.


=head1 BUGS

You can't alter the privs for any process but yourself. This is a VMS
limitation, and isn't likely to change any time soon.

Under VMS 7.1, the DETACH priv has been renamed IMPERSONATE. DCL's lexical
F$GETJPI, which is used in the tests, still reports DETACH, so we return
DETACH instead of IMPERSONATE. (Which is more of a VMS bug, since they got
the ACNT/NOACNT switch in for 7.1) IMPERSONATE's still a legitimate
thing to pass, though, and VMS accepts either.

There's no test for get_default_privs, as getting them another way to test
is somewhat problematic, at least for me. If someone's got code to parse out
the default privs from AUTHORIZE (the use of which may be a problem in and
of itself at some sites), we can add a test.

=head1 AUTHOR

Dan Sugalski <sugalsd@lbcc.cc.or.us>
Hacked up by Charles Bailey <bailey@genetics.upenn.edu>

=head1 SEE ALSO

perl(1).

=cut
