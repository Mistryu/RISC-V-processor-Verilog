module ALU_Decoder(
    input  wire [1:0] alu_op,
    input  wire [2:0] funct3,
    input  wire funct7_bit5,
    
    output reg [3:0] alu_control
);

    always @(*) begin
        case (alu_op)
            2'b00: begin
                alu_control = 4'b0000;
            end
            2'b01, 2'b10: begin
                alu_control = {funct3, funct7_bit5};
            end
            default: begin
                alu_control = 4'b0000;
            end
        endcase
    end

endmodule

