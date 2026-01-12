module hazard_unit(
    input  wire [4:0]  D_rs1,
    input  wire [4:0]  D_rs2,
    input  wire [4:0]  E_rs1,
    input  wire [4:0]  E_rs2,
    input  wire [4:0]  E_rd,
    input  wire [4:0]  M_rd,
    input  wire [4:0]  W_rd,
    input  wire        E_we_rf,
    input  wire        M_we_rf,
    input  wire        W_we_rf,
    input  wire [1:0]  E_sel_result,
    input  wire [1:0]  M_sel_result,
    input  wire        D_jump,
    input  wire        E_branch,
    input  wire        E_zero,
    
    // Forwarding signals for ALU operands
    output reg  [1:0]  E_forward_alu_op1,
    output reg  [1:0]  E_forward_alu_op2,
    
    // Stall and flush signals
    output reg         PC_en,
    output reg         IF_ID_en,
    output reg         IF_ID_clr,
    output reg         ID_EX_clr
);

    // LW instruction
    wire M_is_lw = (M_sel_result == 2'b01);
    
    // RAW Hazard Detection and Forwarding
    always @(*) begin
        E_forward_alu_op1 = 2'b00;
        E_forward_alu_op2 = 2'b00;

        // Forward ALU operand 1
        if ((E_rs1 == M_rd) && M_we_rf && (M_rd != 5'b00000) && !M_is_lw) begin
            E_forward_alu_op1 = 2'b10;  // Forward from MA stage
        end
        else if ((E_rs1 == W_rd) && W_we_rf && (W_rd != 5'b00000)) begin
            E_forward_alu_op1 = 2'b01;  // Forward from WB stage
        end
        
        // Forward ALU operand 2
        if ((E_rs2 == M_rd) && M_we_rf && (M_rd != 5'b00000) && !M_is_lw) begin
            E_forward_alu_op2 = 2'b10;  // Forward from MA stage
        end
        else if ((E_rs2 == W_rd) && W_we_rf && (W_rd != 5'b00000)) begin
            E_forward_alu_op2 = 2'b01;  // Forward from WB stage
        end
    end
    
    // LW Hazard Detection
    // Stall if: instruction at EX is LW AND ID stage needs the result
    // E_sel_result[0] indicates memory read (LW) AND (D_rs1 or D_rs2) == E_rd
    wire lw_hazard;
    wire E_is_lw = (E_sel_result == 2'b01);  // memory read (LW)
    assign lw_hazard = E_is_lw && E_we_rf && (E_rd != 5'b00000) && 
                       ((D_rs1 == E_rd) || (D_rs2 == E_rd));
    

    // Control Hazard Detection
    // Flush if branch at EX stage is taken
    wire branch_taken;
    assign branch_taken = E_branch && E_zero;
    
    // Generates stall and flush signals
    always @(*) begin
        PC_en = 1'b1;
        IF_ID_en = 1'b1;
        IF_ID_clr = 1'b0;
        ID_EX_clr = 1'b0;
        
        // LW Hazard: Stall pipeline for one cycle and flush ID/EX register
        if (lw_hazard) begin
            PC_en = 1'b0;
            IF_ID_en = 1'b0;
            ID_EX_clr = 1'b1;
        end
        
        // JAL Control Hazard: Flush only IF/ID register
        if (D_jump) begin
            IF_ID_clr = 1'b1;
        end
        
        // Branch Control Hazard: Flush IF/ID and ID/EX register if branch is taken
        if (branch_taken) begin
            IF_ID_clr = 1'b1;
            ID_EX_clr = 1'b1;
        end
    end

endmodule
