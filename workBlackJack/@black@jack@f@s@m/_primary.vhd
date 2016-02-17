library verilog;
use verilog.vl_types.all;
entity BlackJackFSM is
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        stay            : in     vl_logic;
        hit             : in     vl_logic;
        card            : in     vl_logic_vector(3 downto 0);
        win             : out    vl_logic;
        lose            : out    vl_logic;
        tie             : out    vl_logic;
        dhit            : out    vl_logic;
        dstay           : out    vl_logic
    );
end BlackJackFSM;
