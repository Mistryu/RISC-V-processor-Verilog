module mem
(
    input  wire clock,
    input  wire write_enable,
    input  wire [31:0] address,
    input  wire [31:0] write_data,
    
    output reg  [31:0] read_data
);

    localparam MEM_DEPTH = 8192;
    
    reg [31:0] RAM [0 : MEM_DEPTH-1];
    
    // Write is synchronous (on clock edge)
    always @(posedge clock) begin
        if (write_enable && address[31:2] < MEM_DEPTH) begin
            RAM[address[31:2]] <= write_data;
        end
    end
    
    // Read is combinational (immediate response to address change)
    always @(*) begin
        if (address[31:2] < MEM_DEPTH) begin
            read_data = RAM[address[31:2]];
        end else begin
            read_data = 32'h00000000;
        end
    end

endmodule
