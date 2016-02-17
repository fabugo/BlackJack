library verilog;
use verilog.vl_types.all;
entity blackjack_tb is
    generic(
        ATRASO_INICIAL  : integer := 5
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ATRASO_INICIAL : constant is 1;
end blackjack_tb;
