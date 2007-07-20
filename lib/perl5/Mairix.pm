package Mairix;

=head1 NAME

Mairix - helpers for mairix CLI utilities

=head1 SYNOPSIS

TODO

=head1 DESCRIPTION

TODO

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

#  return map "s:$_", grep { length($_) && /\w/ } @tokens;
  return 's:' . join ",", grep { length($_) && /\w/ } @tokens;
}

=head2 normalize_subject

Trim a subject of cruft accumulated as a result of replying
to/forwarding the message etc.

=cut

sub normalize_subject {
  my ($original) = @_;

  my $new = $original;
  1 while $new =~ s/^\s+//
       or $new =~ s/\s+$//
       or $new =~ s/^((Re|Fwd|Aw|Antw|Svar):|\(Fwd\))\s*//i
       or $new =~ s/^\[Fwd:\s*(.+)\s*\]$/$1/i
       or $new =~ s/\(Fwd\)$//i
       or $new =~ s/^(FYI|FYEO|FCP|AHOD|F)(:|\b)//i
       or $new =~ s/^\s*\[[\w -]+\]\s+//i
       or $new =~ s/\bv\d+(\.\d+)*(\b|$)//i;
  if ($new ne $original) {
    warn "Normalized '$original' to '$new'\n";
  }
  return $new;
}

=head1 BUGS

None, zero, nada etc.

=head1 SEE ALSO

L<mairix-wrapper>, L<mairix-copy-message>

=cut

1;
