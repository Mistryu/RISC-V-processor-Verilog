module controller(
    input wire [31:0] instruction,

    output reg         rf_we,
    output reg  [2:0]  sel_ext,
    output reg         sel_alu_src_b,
    output reg         dmem_we,
    output reg  [1:0]  sel_result,
    output reg         sel_pc_src,
    output reg  [3:0]  alu_control
);

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    
    reg [1:0] alu_op;

    // First Level Decoding
    always @(*) begin
        case (opcode)
            // I-type lw
            7'b0000011: begin
                rf_we = 1'b1;
                sel_ext = 3'b000;
                sel_alu_src_b = 1'b1;
                dmem_we = 1'b0;
                sel_result = 2'b01;
                sel_pc_src = 1'b0;
                alu_op = 2'b00;
            end
            
            // S-type sw
            7'b0100011: begin
                rf_we = 1'b0;
                sel_ext = 3'b001;
                sel_alu_src_b = 1'b1;
                dmem_we = 1'b1;
                sel_result = 2'b00;
                sel_pc_src = 1'b0;
                alu_op = 2'b00;
            end
            
            // R-type
            7'b0110011: begin
                rf_we = 1'b1;
                sel_ext = 3'b000;
                sel_alu_src_b = 1'b0;
                dmem_we = 1'b0;
                sel_result = 2'b00;
                sel_pc_src = 1'b0;
                alu_op = 2'b01;
            end
            
            // I-type
            7'b0010011: begin
                rf_we = 1'b1;
                sel_ext = 3'b000;
                sel_alu_src_b = 1'b1;
                dmem_we = 1'b0;
                sel_result = 2'b00;
                sel_pc_src = 1'b0;
                alu_op = 2'b10;
            end
            
            // J-type jal
            7'b1101111: begin
                rf_we = 1'b1;
                sel_ext = 3'b100;
                sel_alu_src_b = 1'b0;
                dmem_we = 1'b0;
                sel_result = 2'b10;
                sel_pc_src = 1'b1;
                alu_op = 2'b00;
            end
            
            // U-type lui
            7'b0110111: begin
                rf_we = 1'b1;
                sel_ext = 3'b011;
                sel_alu_src_b = 1'b0;
                dmem_we = 1'b0;
                sel_result = 2'b11;
                sel_pc_src = 1'b0;
                alu_op = 2'b00;
            end
            
            // Default case error 
            default: begin
                rf_we = 1'b0;
                sel_ext = 3'b000;
                sel_alu_src_b = 1'b0;
                dmem_we = 1'b0;
                sel_result = 2'b00;
                sel_pc_src = 1'b0;
                alu_op = 2'b00;
            end
        endcase
    end

    // Second Level Decoding
    always @(*) begin
        case (alu_op)
            2'b00: begin
                alu_control = 4'b0000;
            end
            // R-type and I-type
            2'b01, 2'b10: begin
                alu_control = {funct3, funct7[5]};
            end
            // Default case
            default: begin
                alu_control = 4'b0000;
            end
        endcase
    end

endmodule

