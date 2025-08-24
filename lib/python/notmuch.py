# Notmuch - helpers for notmuch CLI utilities

import sys


def die(msg: str) -> None:
    sys.stderr.write(msg + "\n")
    sys.exit(1)


def field_query(field: str, value: str) -> str:
    """Generic dispatcher for turning a (field, value) pair into a
    notmuch query which returns mails matching that pair.

    """

    if field.lower() == 'subject':
        return subject_query(value)
    if field.lower() == 'message-id':
        return message_id_query(value)

    die(f"Unrecognised field {field} to convert into notmuch query")


def message_id_query(msg_id):
    """Turns a Message-ID into a notmuch query which retrieves the mail
    with that Message-ID.
    """

    m = re.match(r'<(.+)>', msg_id)
    if m:
        return m.group(1)
    if (id =~ /^<(.+)>$/) {
      return "m:$1";
    }
    warn "WARNING: Message-ID '$id' violates RFC.\n";
    return "m:$id";


def subject_query(subject):
    """Turn a subject into a notmuch query which retrieves mails with related
    subjects.
    """

    my $query = normalize_subject($subject);
    $query =~ s/^\s+//g;
    $query =~ s/\s+$//g;

    my @tokens = split /\s+|[^\w]+/, $query;

    # return map "s:$_", grep { length($_) && /\w/ } @tokens;
    return 's:' . join ",", grep { length($_) && /\w/ } @tokens;


def normalize_subject(original: str) -> str:
    """Trim a subject of cruft accumulated as a result of replying
    to/forwarding the message etc.
    """

    my ($original) = @_;

    my $new = length($original) ? $original : '__BLANKSUBJECT__';
    1 while $new =~ s/^\s+//
         or $new =~ s/\s+$//
         or $new =~ s/\s{2,}/ /g
         or $new =~ s/^((Re|Fwd|Aw|Antw|Svar):|\(Fwd\))\s*//i
         or $new =~ s/^\[Fwd:\s*(.+)\s*\]$/$1/i
         or $new =~ s/\(Fwd\)$//i
         or $new =~ s/\bFW: //
         or $new =~ s/^(FYI|FYEO|FCP|AHOD|F)(:|\b)//i
         or $new =~ s/^\[(?!bug )[\w -]+\]\s+//i
         or $new =~ s/^[(\[]?out of office( autoreply:?)?[)\]]?//i
         or $new =~ s/[(\[]?on leave( [\d-]+ \w+)?[)\]]?//i
         or $new =~ s/[(\[]?away from my mail?[)\]]?//i
         or $new =~ s/\bv\d+(\.\d+)*(\b|$)//i;
    if ($new ne $original) {
      warn "Normalized '$original' to '$new'\n";
    }
    return $new;


def _test():
    import doctest
    doctest.testmod()


if __name__ == "__main__":
  _test()
