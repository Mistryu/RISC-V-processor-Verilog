module register
(
    input  wire        clock,
    input  wire        reset,
    input  wire        write_enable,
    input  wire [31:0] data_in,
    
    output reg  [31:0] data_out
);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            data_out <= 32'h00000000;
        end else if (write_enable) begin
            data_out <= data_in;
        end
    end

endmodule

