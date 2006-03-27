package Mairix;

=head1 NAME

Mairix - 

=head1 SYNOPSIS



=head1 DESCRIPTION



=cut

use strict;
use warnings;

=head2 subject_query

Turn a subject into a mairix query to retrieve mail's with related
subjects.

=cut

sub subject_query {
  my ($subject) = @_;
  my $query = normalize_subject($subject);
  $query =~ s/^\s+//g;
  $query =~ s/\s+$//g;

  my @tokens = split /\s+|[^\w]+/, $query;

  return map "s:$_", grep { length($_) && /\w/ } @tokens;

  return 's:' . join ",", grep { length($_) && /\w/ } @tokens;
}

sub normalize_subject {
  my ($original) = @_;

  my $new = $original;
  1 while $new =~ s/^(Re:|Fwd:|\(Fwd\))\s*//i
       or $new =~ s/^\[Fwd:\s*(.+)\s*\]$/$1/i
       or $new =~ s/\s*\(Fwd\)\s*$//i
       or $new =~ s/^\s*\[[\w -]+\]\s+//i;
  if ($new ne $original) {
    warn "Normalized '$original' to '$new'\n";
  }
  return $new;
}

=head1 BUGS

=head1 SEE ALSO

=cut

1;
