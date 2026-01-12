// Zero Flag Comparator Module
module zero_flag(
    input  wire [31:0] value,
    output wire        is_zero
);

    assign is_zero = (value == 32'h00000000);

endmodule
