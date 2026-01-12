module ALU(
    input  wire [31:0] RD1,
    input  wire [31:0] RD2,
    input  wire [3:0]  alu_control,
    output reg  [31:0] alu_result
);

    reg [31:0] addition_result;
    reg [31:0] shifted_operand_b;

    // Combinational logic
    always @(*) begin
        if (alu_control[0] && (alu_control[3:1] == 3'b000 || 
                               alu_control[3:1] == 3'b010 || 
                               alu_control[3:1] == 3'b011)) begin
            shifted_operand_b = ~RD2 + 32'd1;
        end else begin
            shifted_operand_b = RD2;
        end

        addition_result = RD1 + shifted_operand_b;

        case (alu_control)
            4'b0000: begin
                alu_result = addition_result;
            end
            
            4'b0001: begin
                alu_result = addition_result;
            end

            4'b0010: begin
                alu_result = RD1 << RD2[4:0];
            end

            4'b1010: begin
                alu_result = RD1 >> RD2[4:0];
            end

            4'b1011: begin
                alu_result = $signed(RD1) >>> RD2[4:0];
            end

            4'b0100: begin
                // SLT: Set if less than (signed comparison)
                // Compute RD1 - RD2 and check sign bit
                alu_result = {31'b0, ($signed(RD1) < $signed(RD2))};
            end

            4'b0110: begin
                alu_result = {31'b0, (RD1 < RD2)};
            end

            4'b1000: begin
                alu_result = RD1 ^ RD2;
            end

            4'b1100: begin
                alu_result = RD1 | RD2;
            end

            4'b1110: begin
                alu_result = RD1 & RD2;
            end

            default: begin
                alu_result = addition_result;
            end
        endcase
    end

endmodule

