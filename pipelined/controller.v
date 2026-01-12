module controller(
    input  wire [6:0] op,
    input  wire [2:0] funct3,
    input  wire       funct7s,
    
    output reg        D_jump,
    output reg        D_branch,
    output reg [1:0]  D_sel_result,
    output reg        D_we_dm,
    output reg [3:0]  D_alu_control,
    output reg        D_sel_alu_src_b,
    output reg [2:0]  D_sel_ext,
    output reg        D_we_rf
);

    reg [1:0] alu_op;

    always @(*) begin
        D_jump = 1'b0;
        D_branch = 1'b0;
        D_sel_result = 2'b00;
        D_we_dm = 1'b0;
        D_sel_alu_src_b = 1'b0;
        D_sel_ext = 3'b000;
        D_we_rf = 1'b0;
        alu_op = 2'b00;
        
        case (op)
            // I-type: Load Word (LW)
            7'b0000011: begin
                D_sel_result = 2'b01;
                D_we_dm = 1'b0;
                D_sel_alu_src_b = 1'b1;
                D_sel_ext = 3'b000;
                D_we_rf = 1'b1;
                alu_op = 2'b00;
            end
            
            // S-type: Store Word (SW)
            7'b0100011: begin
                D_sel_result = 2'b00;
                D_we_dm = 1'b1;
                D_sel_alu_src_b = 1'b1;
                D_sel_ext = 3'b001;
                D_we_rf = 1'b0;
                alu_op = 2'b00;
            end
            
            // R-type: Arithmetic and Logical
            7'b0110011: begin
                D_sel_result = 2'b00;
                D_we_dm = 1'b0;
                D_sel_alu_src_b = 1'b0;
                D_sel_ext = 3'b000;
                D_we_rf = 1'b1;
                alu_op = 2'b01;
            end
            
            // I-type: Arithmetic and Logical Immediate
            7'b0010011: begin
                D_sel_result = 2'b00;
                D_we_dm = 1'b0;
                D_sel_alu_src_b = 1'b1;
                D_sel_ext = 3'b000;
                D_we_rf = 1'b1;
                alu_op = 2'b10;
            end
            
            // U-type: Load Upper Immediate (LUI)
            7'b0110111: begin
                D_sel_result = 2'b11;
                D_we_dm = 1'b0;
                D_sel_alu_src_b = 1'b0;
                D_sel_ext = 3'b011;
                D_we_rf = 1'b1;
                alu_op = 2'b00;
            end
            
            // J-type: Jump And Link (JAL)
            7'b1101111: begin
                D_jump = 1'b1;
                D_sel_result = 2'b10;
                D_we_dm = 1'b0;
                D_sel_alu_src_b = 1'b0;
                D_sel_ext = 3'b100;
                D_we_rf = 1'b1;
                alu_op = 2'b00;
            end
            
            default: begin
                // Default: NOP
                D_sel_result = 2'b00;
                D_we_dm = 1'b0;
                D_sel_alu_src_b = 1'b0;
                D_sel_ext = 3'b000;
                D_we_rf = 1'b0;
                alu_op = 2'b00;
            end
        endcase
    end

    // Second Level Decoding
    always @(*) begin
        case (alu_op)
            2'b00: begin
                // Add for load/store address calc
                D_alu_control = 4'b0000;
            end
            2'b01: begin
                // R-type
                D_alu_control = {funct3, funct7s};
            end
            2'b10: begin
                // I-type
                D_alu_control = {funct3, 1'b0};
            end
            default: begin
                D_alu_control = 4'b0000;
            end
        endcase
    end

endmodule
