module Instruction_Decoder(
    input  wire [31:0] instruction,
    
    output wire [6:0] opcode,
    output reg [2:0] sel_ext
);

    assign opcode = instruction[6:0];

    always @(*) begin
        case (opcode)
            7'b0000011: begin
                sel_ext = 3'b000;
            end
            7'b0100011: begin
                sel_ext = 3'b001;
            end
            7'b0110011: begin
                sel_ext = 3'b000;
            end
            7'b0010011: begin
                sel_ext = 3'b000;
            end
            7'b1101111: begin
                sel_ext = 3'b100;
            end
            7'b0110111: begin
                sel_ext = 3'b011;
            end
            default: begin
                sel_ext = 3'b000;
            end
        endcase
    end

endmodule
