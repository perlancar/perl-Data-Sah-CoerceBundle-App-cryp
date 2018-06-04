package Data::Sah::Coerce::perl::str::str_normalize_cryptoexchange_account;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

sub meta {
    +{
        v => 3,
        enable_by_default => 0,
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
        "else { my \$cat = CryptoExchange::Catalog->new; my \@data = \$cat->all_data; ",
        "  my \$lc = lc(\$xch); my \$rec; for (\@data) { if (defined(\$_->{code}) && \$lc eq lc(\$_->{code}) || \$lc eq lc(\$_->{name}) || \$lc eq \$_->{safename}) { \$rec = \$_; last } } ",
        "  if (!\$rec) { ['Unknown cryptoexchange code/name/safename'] } else { [undef, qq(\$rec->{safename}/\$acc)] } ",
        "} }",
    );

    $res;
}

1;
# ABSTRACT: Normalize cryptoexchange account

=for Pod::Coverage ^(meta|coerce)$

=head1 DESCRIPTION

Cryptoexchange account is of the following format:

 cryptoexchange/account

where C<cryptoexchange> is the name/code/safename of cryptoexchange as listed in
L<CryptoExchange::Catalog>. This coercion rule normalizes cryptoexchange into
safename and will die if name/code/safename is not listed in the catalog module.

C<account> must also be [A-Za-z0-9_-]+ only.

The rule is not enabled by default. You can enable it in a schema using e.g.:

 ["str", "x.perl.coerce_rules"=>["str_normalize_cryptocurrency_account"]]
