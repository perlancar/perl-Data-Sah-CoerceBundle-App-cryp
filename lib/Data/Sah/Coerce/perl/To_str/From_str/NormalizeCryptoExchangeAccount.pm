package Data::Sah::Coerce::perl::To_str::From_str::NormalizeCryptoExchangeAccount;

# AUTHOR
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;

sub meta {
    +{
        v => 4,
        summary => 'Normalize cryptoexchange account',
        might_fail => 1,
        prio => 50,
    };
}

sub coerce {
    my %args = @_;

    my $dt = $args{data_term};

    my $res = {};

    $res->{expr_match} = "!ref($dt)";
    $res->{modules}{"CryptoExchange::Catalog"} //= 0;
    $res->{expr_coerce} = join(
        "",
        "do { my (\$xch, \$acc); $dt =~ m!(.+)/(.+)! and (\$xch, \$acc) = (\$1, \$2) or (\$xch, \$acc) = ($dt, 'default'); ",
        "if (\$acc !~ /\\A[A-Za-z0-9_-]+\\z/) { [qq(Invalid account syntax (\$acc), please only use letters/numbers/underscores/dashes)] } ",
        "elsif (length \$acc > 64) { [qq(Account name too long (\$acc), please do not exceed 64 characters)] } ",
        "else { my \$cat = CryptoExchange::Catalog->new; my \@data = \$cat->all_data; ",
        "  my \$lc = lc(\$xch); my \$rec; for (\@data) { if (defined(\$_->{code}) && \$lc eq lc(\$_->{code}) || \$lc eq lc(\$_->{name}) || \$lc eq \$_->{safename}) { \$rec = \$_; last } } ",
        "  if (!\$rec) { ['Unknown cryptoexchange code/name/safename: ' . \$lc] } else { [undef, qq(\$rec->{safename}/\$acc)] } ",
        "} }",
    );

    $res;
}

1;
# ABSTRACT:

=for Pod::Coverage ^(meta|coerce)$

=head1 DESCRIPTION

Cryptoexchange account is of the following format:

 cryptoexchange/account

where C<cryptoexchange> is the name/code/safename of cryptoexchange as listed in
L<CryptoExchange::Catalog>. This coercion rule normalizes cryptoexchange into
safename and will die if name/code/safename is not listed in the catalog module.

C<account> must also be [A-Za-z0-9_-]+ only and not exceed 64 characters in
length.
