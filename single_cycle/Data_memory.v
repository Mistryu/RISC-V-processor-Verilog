module data_memory(
    input  wire        clock,        
    input  wire        write_enable,         
    input  wire [31:0] address,       
    input  wire [31:0] write_data,         
    output reg  [31:0] read_data          
);

    // Memory size: 32 KB
    parameter MEM_SIZE = 8192;     
    reg [31:0] memory [0:MEM_SIZE-1];

    // Sequential logic read
    always @(posedge clock) begin
        if (address[31:2] < MEM_SIZE) begin
            read_data <= memory[address[31:2]];
        end else begin
            read_data <= 32'h00000000;  // Out of bounds
        end
    end

    // Sequential logic write
    always @(posedge clock) begin
        if (write_enable && address[31:2] < MEM_SIZE) begin
            memory[address[31:2]] <= write_data;
        end else begin
            read_data <= 32'h00000000;  // Out of bounds
        end
    end

endmodule

