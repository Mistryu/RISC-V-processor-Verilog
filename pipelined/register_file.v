module register_file(
    input  wire        clock,
    input  wire        write_enable,
    input  wire [4:0]  read_address_1,
    input  wire [4:0]  read_address_2,
    input  wire [4:0]  write_address,
    input  wire [31:0] write_data,
    
    output reg  [31:0] read_data_1,
    output reg  [31:0] read_data_2
);
    reg [31:0] registers [0:31];

    always @(*) begin
        if (read_address_1 == 5'b00000) begin
            read_data_1 = 32'h00000000;
        end else begin
            read_data_1 = registers[read_address_1];
        end
    end

    always @(*) begin
        if (read_address_2 == 5'b00000) begin
            read_data_2 = 32'h00000000;
        end else begin
            read_data_2 = registers[read_address_2];
        end
    end

    always @(negedge clock) begin
        if (write_enable && write_address != 5'b00000) begin
            registers[write_address] <= write_data;
        end
    end

endmodule