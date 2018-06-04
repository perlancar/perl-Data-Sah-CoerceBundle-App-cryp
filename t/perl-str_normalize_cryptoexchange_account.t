#!perl

use 5.010001;
use strict;
use warnings;
use Test::More 0.98;

use Data::Sah::Coerce qw(gen_coercer);

subtest "basics" => sub {
    my $c = gen_coercer(
        type=>"str",
        coerce_rules=>["str_normalize_cryptoexchange_account"],
        return_type => "status+err+val",
    );

    my $res;

    is_deeply($c->({}), [undef, undef, {}], "hashref uncoerced");
    is_deeply($c->("foo"), [1, "Unknown cryptoexchange code/name/safename", undef], "unknown exchange -> fail");
    is_deeply($c->("gdax/a b"), [1, "Invalid account syntax (a b), please only use letters/numbers/underscores/dashes", undef], "invalid account syntax -> fail");

    is_deeply($c->("GDAX"), [1, undef, "gdax/default"]);
    is_deeply($c->("gdax/1"), [1, undef, "gdax/1"]);
    is_deeply($c->("bx/2"), [1, undef, "bx-thailand/2"]);
    is_deeply($c->("BX thailand/Three"), [1, undef, "bx-thailand/Three"]);

};

done_testing;
