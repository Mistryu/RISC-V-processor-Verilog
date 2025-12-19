module FSM(
    input  wire clk,
    input  wire rst,
    input  wire [6:0] opcode,
    
    output reg sel_mem_addr,
    output reg we_ir,
    output reg sel_alu_src_a,
    output reg [1:0] sel_alu_src_b,
    output reg [1:0] alu_op,
    output reg [1:0] sel_result,
    output reg we_pc,
    output reg we_mem,
    output reg we_rf,
    output reg we_pc_plus_4,
    output reg we_alu_reg,
    output reg we_original_pc,
    output reg sel_original_pc
);

    // State encoding using one-hot encoding (excluding S8because I didn't implement it in the previous task)
    localparam [9:0] S0_FETCH = 10'b0000000001;
    localparam [9:0] S1_DECODE = 10'b0000000010;
    localparam [9:0] S2_EXE_ADDR = 10'b0000000100;
    localparam [9:0] S3_MEM_RD = 10'b0000001000;
    localparam [9:0] S4_WB_MEM = 10'b0000010000;
    localparam [9:0] S5_MEM_WR = 10'b0000100000;
    localparam [9:0] S6_EXE_R = 10'b0001000000;
    localparam [9:0] S7_WB_ALU = 10'b0010000000;
    localparam [9:0] S9_EXE_I = 10'b0100000000;
    localparam [9:0] S10_JAL = 10'b1000000000;
    
    localparam [6:0] OP_LW = 7'b0000011;
    localparam [6:0] OP_SW = 7'b0100011;
    localparam [6:0] OP_RTYPE = 7'b0110011;
    localparam [6:0] OP_ITYPE = 7'b0010011;
    localparam [6:0] OP_JAL = 7'b1101111;
    localparam [6:0] OP_LUI = 7'b0110111;
    
    reg [9:0] current_state;
    reg [9:0] next_state;
    
    always @(posedge clk) begin
        if (rst) begin
            current_state <= S0_FETCH;
        end else begin
            current_state <= next_state;
        end
    end
    

    always @(*) begin
        next_state = S0_FETCH;
        
        case (current_state)
            S0_FETCH: begin
                next_state = S1_DECODE;
            end
            
            S1_DECODE: begin
                case (opcode)
                    OP_LW, OP_SW: begin
                        next_state = S2_EXE_ADDR;
                    end
                    OP_RTYPE: begin
                        next_state = S6_EXE_R;
                    end
                    OP_ITYPE: begin
                        next_state = S9_EXE_I;
                    end
                    OP_JAL: begin
                        next_state = S10_JAL;
                    end
                    OP_LUI: begin
                        next_state = S7_WB_ALU;
                    end
                    default: begin
                        next_state = S0_FETCH;
                    end
                endcase
            end
            
            S2_EXE_ADDR: begin
                case (opcode)
                    OP_LW: begin
                        next_state = S3_MEM_RD;
                    end
                    OP_SW: begin
                        next_state = S5_MEM_WR;
                    end
                    default: begin
                        next_state = S0_FETCH;
                    end
                endcase
            end
            
            S3_MEM_RD: begin
                next_state = S4_WB_MEM;
            end
            
            S4_WB_MEM, S7_WB_ALU, S5_MEM_WR: begin
                next_state = S0_FETCH;
            end
            
            S6_EXE_R: begin
                next_state = S7_WB_ALU;
            end
            
            S9_EXE_I: begin
                next_state = S7_WB_ALU;
            end
            
            S10_JAL: begin
                next_state = S7_WB_ALU;
            end
            
            default: begin
                next_state = S0_FETCH;
            end
        endcase
    end
    
    // Output: Moore FSM because it's simpler to implement
    always @(*) begin

        sel_mem_addr = 1'b0;
        we_ir = 1'b0;
        sel_alu_src_a = 1'b0;
        sel_alu_src_b = 2'b00;
        alu_op = 2'b00;
        sel_result = 2'b00;
        we_pc = 1'b0;
        we_mem = 1'b0;
        we_rf = 1'b0;
        we_pc_plus_4 = 1'b0;
        we_alu_reg = 1'b0;
        we_original_pc = 1'b0;
        sel_original_pc = 1'b0;
        we_pc = 1'b0;
        
        case (current_state)
            S0_FETCH: begin
                sel_mem_addr = 1'b0;
                we_ir = 1'b1;
                sel_alu_src_a = 1'b0;
                sel_alu_src_b = 2'b10;
                alu_op = 2'b00;
                sel_result = 2'b10;
                we_pc = 1'b1;
                we_pc_plus_4 = 1'b1;
                we_alu_reg = 1'b0;  // Don't save PC+4 to alu_reg
                we_original_pc = 1'b1;  // I'm storing the PC before it's updated for JAL instruction 
            end
            
            S1_DECODE: begin
                sel_mem_addr = 1'b0;
                we_ir = 1'b0;
                sel_alu_src_a = 1'b0;
                sel_alu_src_b = 2'b00;
                alu_op = 2'b00;
                sel_result = 2'b00;
                we_pc = 1'b0;
            end
            
            S2_EXE_ADDR: begin
                sel_mem_addr = 1'b0;
                we_ir = 1'b0;
                sel_alu_src_a = 1'b1;
                sel_alu_src_b = 2'b01;
                alu_op = 2'b00;
                sel_result = 2'b00;
                we_pc = 1'b0;
                we_mem = 1'b0;
                we_rf = 1'b0;
                we_alu_reg = 1'b1;  // Save address calculation result
            end
            
            // S3: MEM_RD ( lw )
            S3_MEM_RD: begin
                sel_mem_addr = 1'b1;
                we_ir = 1'b0;
                sel_alu_src_a = 1'b0;
                sel_alu_src_b = 2'b00;
                alu_op = 2'b00;
                sel_result = 2'b00;
                we_pc = 1'b0;
                we_mem = 1'b0;
                we_rf = 1'b0;
            end
            
            // S4: WB_MEM (Writeback for lw)
            S4_WB_MEM: begin
                sel_mem_addr = 1'b0;
                we_ir = 1'b0;
                sel_alu_src_a = 1'b0;
                sel_alu_src_b = 2'b00;
                alu_op = 2'b00;
                sel_result = 2'b01;
                we_pc = 1'b0;
                we_mem = 1'b0;
                we_rf = 1'b1;
            end
            
            // S5: MEM_WR (Memory write for sw)
            S5_MEM_WR: begin
                sel_mem_addr = 1'b1;
                we_ir = 1'b0;
                sel_alu_src_a = 1'b0;
                sel_alu_src_b = 2'b00;
                alu_op = 2'b00;
                sel_result = 2'b00;
                we_pc = 1'b0;
                we_mem = 1'b1;
                we_rf = 1'b0;
            end
            
            S6_EXE_R: begin
                sel_mem_addr = 1'b0;
                we_ir = 1'b0;
                sel_alu_src_a = 1'b1;
                sel_alu_src_b = 2'b00;
                alu_op = 2'b01;
                sel_result = 2'b00;
                we_pc = 1'b0;
                we_mem = 1'b0;
                we_rf = 1'b0;
                we_alu_reg = 1'b1;  // Save R-type ALU result
            end
            
            // S7: WB_ALU (Writeback ALU result for R, I, LUI, JAL)
            S7_WB_ALU: begin
                sel_mem_addr = 1'b0;
                we_ir = 1'b0;
                sel_alu_src_a = 1'b0;
                sel_alu_src_b = 2'b00;
                alu_op = 2'b00;
                case (opcode)
                    OP_LUI: begin
                        sel_result = 2'b11;
                    end
                    OP_JAL: begin
                        sel_result = 2'b10;
                    end
                    default: begin
                        sel_result = 2'b00;
                    end
                endcase
                we_pc = 1'b0;
                we_mem = 1'b0;
                we_rf = 1'b1;
            end
            
            S9_EXE_I: begin
                sel_mem_addr = 1'b0;
                we_ir = 1'b0;
                sel_alu_src_a = 1'b1;
                sel_alu_src_b = 2'b01;
                alu_op = 2'b10;
                sel_result = 2'b00;
                we_pc = 1'b0;
                we_mem = 1'b0;
                we_rf = 1'b0;
                we_alu_reg = 1'b1;  // Save I-type ALU result
            end
            
            S10_JAL: begin
                sel_mem_addr = 1'b0;
                we_ir = 1'b0;
                sel_alu_src_a = 1'b0;
                sel_alu_src_b = 2'b01;
                alu_op = 2'b00;
                we_alu_reg = 1'b1;
                sel_result = 2'b00;
                we_pc = 1'b1;
                we_mem = 1'b0;
                we_rf = 1'b0;
                sel_original_pc = 1'b1;  // Using original_pc for JAL jump target
            end
            
            default: begin
                sel_mem_addr = 1'b0;
                we_ir = 1'b0;
                sel_alu_src_a = 1'b0;
                sel_alu_src_b = 2'b00;
                alu_op = 2'b00;
                sel_result = 2'b00;
                we_pc = 1'b0;
                we_mem = 1'b0;
                we_rf = 1'b0;
            end
        endcase
    end

endmodule
