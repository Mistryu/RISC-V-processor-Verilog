module program_counter(
    input  wire        clk, 
    input  wire [31:0] next_pc,
    output reg  [31:0] pc
);

    initial begin
        pc = 32'h00000000;
    end

    always @(posedge clk) begin
        pc <= next_pc;
    end

endmodule