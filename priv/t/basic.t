# Tests for VMS::Priv v1.2
use VMS::Priv;

print "1..12\n";

my ($CurPrivList, $ProcessPrivList, $AuthPrivList, $ImagePrivList);

$CurPrivList = VMS::Priv::get_current_privs($$) or print "not ";
print "ok 1\n";
chomp($dcl = qx[\@disppriv $$ curpriv]);
$dcl = join(',',sort split /,/, $dcl);
$us = join(',',sort keys %$CurPrivList);
if ($dcl eq $us) { print "ok 2\n" }
else { print "not ok 2\t# DCL = ($dcl), us = ($us)\n"; }

$ProcessPrivList = VMS::Priv::get_process_privs($$) or print "not ";
print "ok 3\n";
chomp($dcl = qx[\@disppriv $$ procpriv]);
$dcl = join(',',sort split /,/, $dcl);
$us = join(',',sort keys %$ProcessPrivList);
if ($dcl eq $us) { print "ok 4\n" }
else { print "not ok 4\t# DCL = ($dcl), us = ($us)\n"; }

$AuthPrivList = VMS::Priv::get_auth_privs($$) or print "not ";
print "ok 5\n";
chomp($dcl = qx[\@disppriv $$  authpriv]);
$dcl = join(',',sort split /,/, $dcl);
$us = join(',',sort keys %$AuthPrivList);
if ($dcl eq $us) { 
print "ok 6\n" }

else { print "not ok 6\t# DCL = ($dcl), us = ($us)\n"; }

$AuthPrivList = VMS::Priv::get_image_privs($$) or print "not ";
print "ok 7\n";
chomp($dcl = qx[\@disppriv $$ imagpriv]);
$dcl = join(',',sort split /,/, $dcl);
$us = join(',',sort keys %$ImagePrivList);
if ($dcl eq $us) { print "ok 8\n" }
else { print "not ok 8\t# DCL = ($dcl), us = ($us)\n"; }

# Snag a priv to work with

my $WorkingPriv = (keys %{$CurPrivList})[0];

my ($WorkingPrivList, $BasePrivList, $ShortPrivList, $CheckList);

# Check to see if we can take a priv away
$WorkingPrivList = VMS::Priv::remove_current_privs([$WorkingPriv]);
!$WorkingPrivList->{$WorkingPriv} ? print "ok 9\n" : print "not ok 9\n";

# Can we add it back?
$WorkingPrivList = VMS::Priv::add_current_privs([$WorkingPriv]);
$WorkingPrivList->{$WorkingPriv} ? print "ok 10\n" : print "not ok 10\n";

# Take the priv away so we can see if there are any changes
VMS::Priv::remove_current_privs([$WorkingPriv]);

$WorkingPrivList = VMS::Priv::set_current_privs([ keys %$CurPrivList ]);
$WorkingPrivList->{$WorkingPriv} ? print "ok 11\n" : print "not ok 11\n";

my @Names = VMS::Priv::priv_names;
# New privs may be added in future versions of VMS/SEVMS, so we don't test
# for an exact number, but any version of VMS under which Perl will run
# should have at least 30 privilege types.
@Names > 30 or print "not ";
print "ok 12\n";
