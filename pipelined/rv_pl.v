// Top-level core + memory
module rv_pl ( // keep this name as your top module of rv_mc core
    input  wire clk,  // keep this name: clk
    input  wire rst_n  // keep this name: rst_n, must be synchronized low-active reset
);

    // Synchronized reset (convert low-active to high-active)
    reg rst_sync1, rst_sync2;
    wire rst;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rst_sync1 <= 1'b1;
            rst_sync2 <= 1'b1;
        end else begin
            rst_sync1 <= 1'b0;
            rst_sync2 <= rst_sync1;
        end
    end
    
    assign rst = rst_sync2;

    // IF Stage signals
    wire [31:0] F_PC;
    wire [31:0] F_PC_P4;
    wire [31:0] F_instr;
    wire [31:0] next_pc;
    
    // IF/ID Pipeline Register signals
    wire [31:0] D_instr;
    wire [31:0] D_PC;
    wire [31:0] D_PC_P4;
    
    // ID Stage signals
    wire        D_jump;
    wire        D_branch;
    wire [1:0]  D_sel_result;
    wire        D_we_dm;
    wire [3:0]  D_alu_control;
    wire        D_sel_alu_src_b;
    wire [2:0]  D_sel_ext;
    wire        D_we_rf;
    wire [31:0] D_rf_rd1;
    wire [31:0] D_rf_rd2;
    wire [4:0]  D_rf_a3;
    wire [4:0]  D_rs1;
    wire [4:0]  D_rs2;
    wire [31:0] D_ext;
    wire [31:0] D_target_PC;  // Jump target for JAL
    
    // ID/EX Pipeline Register signals
    wire        E_jump;
    wire        E_branch;
    wire [1:0]  E_sel_result;
    wire        E_we_dm;
    wire [3:0]  E_alu_control;
    wire        E_sel_alu_src_b;
    wire        E_we_rf;
    wire [31:0] E_rf_rd1;
    wire [31:0] E_rf_rd2;
    wire [4:0]  E_rf_a3;
    wire [4:0]  E_rs1;
    wire [4:0]  E_rs2;
    wire [31:0] E_ext;
    wire [31:0] E_PC;
    wire [31:0] E_PC_P4;
    
    // Hazard Unit signals
    wire [1:0]  E_forward_alu_op1;
    wire [1:0]  E_forward_alu_op2;
    wire        PC_en;
    wire        IF_ID_en;
    wire        IF_ID_clr;
    wire        ID_EX_clr;
    
    // EX Stage signals
    wire [31:0] E_alu_o;
    wire        E_zero;
    wire [31:0] E_target_PC;
    
    // EX/MA Pipeline Register signals
    wire [1:0]  M_sel_result;
    wire        M_we_dm;
    wire        M_we_rf;
    wire [31:0] M_alu_o;
    wire [31:0] M_dm_wd;
    wire [4:0]  M_rf_a3;
    wire [31:0] M_PC_P4;
    wire [31:0] M_ext;        // Immediate (for LUI)
    
    // MA Stage signals
    wire [31:0] M_dm_rd;
    
    // MA/WB Pipeline Register signals
    wire [1:0]  W_sel_result;
    wire        W_we_rf;
    wire [31:0] W_dm_rd;
    wire [31:0] W_alu_o;
    wire [4:0]  W_rf_a3;
    wire [31:0] W_PC_P4;
    wire [31:0] W_ext;        // Immediate (for LUI)
    
    // WB Stage signals
    wire [31:0] W_result;
    
    // PC MUX: Select PC+4 or jump target 
    // Since I didn't implement the branch instructions, I can use the D_jump signal to select the PC+4 or jump target
    mux mux_pc_src(
        .sel(D_jump),
        .input1(D_target_PC),  // Jump target
        .input2(F_PC_P4),      // PC+4 (normal)
        .out(next_pc)
    );
    
    /////////////////////    IF STAGE    \\\\\\\\\\\\\\\\\\\\\\
    
    // Program Counter
    program_counter pc_module(
        .clk(clk),
        .rst(rst),
        .pc_en(PC_en),
        .next_pc(next_pc),
        .pc(F_PC)
    );
    
    // PC + 4 Adder
    add_pc_4 pc_adder(
        .pc(F_PC),
        .pc_plus_4(F_PC_P4)
    );
    
    // Instruction Memory - keep this name IMEM
    instruction_memory IMEM(
        .pc(F_PC),
        .instruction(F_instr)
    );
    
    // IF/ID Pipeline Register
    pipeline_reg_if_id reg_if_id(
        .clk(clk),
        .rst(rst),
        .en(IF_ID_en),
        .clr(IF_ID_clr),
        .F_instr(F_instr),
        .F_PC(F_PC),
        .F_PC_P4(F_PC_P4),
        .D_instr(D_instr),
        .D_PC(D_PC),
        .D_PC_P4(D_PC_P4)
    );
    
    /////////////////////    ID STAGE    \\\\\\\\\\\\\\\\\\\\\\
    
    // Instruction field extraction
    wire [6:0] opcode = D_instr[6:0];
    wire [2:0] funct3 = D_instr[14:12];
    wire       funct7s = D_instr[30];
    wire [4:0] rs1 = D_instr[19:15];
    wire [4:0] rs2 = D_instr[24:20];
    wire [4:0] rd = D_instr[11:7];
    
    assign D_rf_a3 = rd;
    assign D_rs1 = rs1;
    assign D_rs2 = rs2;
    
    // Controller
    controller ctrl(
        .op(opcode),
        .funct3(funct3),
        .funct7s(funct7s),
        .D_jump(D_jump),
        .D_branch(D_branch),
        .D_sel_result(D_sel_result),
        .D_we_dm(D_we_dm),
        .D_alu_control(D_alu_control),
        .D_sel_alu_src_b(D_sel_alu_src_b),
        .D_sel_ext(D_sel_ext),
        .D_we_rf(D_we_rf)
    );
    
    // Register File - keep this name RF
    register_file RF(
        .clock(clk),
        .write_enable(W_we_rf),
        .read_address_1(rs1),
        .read_address_2(rs2),
        .write_address(W_rf_a3),
        .write_data(W_result),
        .read_data_1(D_rf_rd1),
        .read_data_2(D_rf_rd2)
    );
    
    // Sign Extender
    sign_extender sign_ext(
        .instruction(D_instr),
        .sel_ext(D_sel_ext),
        .imm_extended(D_ext)
    );
    
    // Jump target calculation (PC + immediate) for JAL
    add_pc_imm jump_target_adder(
        .pc(D_PC),
        .imm_extended(D_ext),
        .pc_plus_imm(D_target_PC)
    );
    
    // ID/EX Pipeline Register
    pipeline_reg_id_ex reg_id_ex(
        .clk(clk),
        .rst(rst),
        .clr(ID_EX_clr),
        .D_jump(D_jump),
        .D_branch(D_branch),
        .D_sel_result(D_sel_result),
        .D_we_dm(D_we_dm),
        .D_alu_control(D_alu_control),
        .D_sel_alu_src_b(D_sel_alu_src_b),
        .D_we_rf(D_we_rf),
        .D_rf_rd1(D_rf_rd1),
        .D_rf_rd2(D_rf_rd2),
        .D_rf_a3(D_rf_a3),
        .D_rs1(D_rs1),
        .D_rs2(D_rs2),
        .D_ext(D_ext),
        .D_PC(D_PC),
        .D_PC_P4(D_PC_P4),
        .E_jump(E_jump),
        .E_branch(E_branch),
        .E_sel_result(E_sel_result),
        .E_we_dm(E_we_dm),
        .E_alu_control(E_alu_control),
        .E_sel_alu_src_b(E_sel_alu_src_b),
        .E_we_rf(E_we_rf),
        .E_rf_rd1(E_rf_rd1),
        .E_rf_rd2(E_rf_rd2),
        .E_rf_a3(E_rf_a3),
        .E_rs1(E_rs1),
        .E_rs2(E_rs2),
        .E_ext(E_ext),
        .E_PC(E_PC),
        .E_PC_P4(E_PC_P4)
    );
    
    // Hazard Unit
    hazard_unit hazard(
        .D_rs1(D_rs1),
        .D_rs2(D_rs2),
        .E_rs1(E_rs1),
        .E_rs2(E_rs2),
        .E_rd(E_rf_a3),
        .M_rd(M_rf_a3),
        .W_rd(W_rf_a3),
        .E_we_rf(E_we_rf),
        .M_we_rf(M_we_rf),
        .W_we_rf(W_we_rf),
        .E_sel_result(E_sel_result),
        .M_sel_result(M_sel_result),
        .D_jump(D_jump),
        .E_branch(E_branch),
        .E_zero(E_zero),
        .E_forward_alu_op1(E_forward_alu_op1),
        .E_forward_alu_op2(E_forward_alu_op2),
        .PC_en(PC_en),
        .IF_ID_en(IF_ID_en),
        .IF_ID_clr(IF_ID_clr),
        .ID_EX_clr(ID_EX_clr)
    );
    
    /////////////////////    EX STAGE    \\\\\\\\\\\\\\\\\\\\\\
    
    // Forwarding MUX for ALU operand 1
    wire [31:0] alu_op1_forwarded;
    MUX3 mux_forward_op1(
        .sel(E_forward_alu_op1),
        .input0(E_rf_rd1),
        .input1(W_result),
        .input2(M_alu_o),
        .out(alu_op1_forwarded)
    );
    
    // Forwarding MUX for ALU operand 2
    wire [31:0] alu_op2_forwarded;
    MUX3 mux_forward_op2(
        .sel(E_forward_alu_op2),
        .input0(E_rf_rd2),
        .input1(W_result),
        .input2(M_alu_o),
        .out(alu_op2_forwarded)
    );
    
    // ALU source B MUX
    wire [31:0] alu_src_b;
    mux mux_alu_src_b(
        .sel(E_sel_alu_src_b),
        .input1(E_ext),
        .input2(alu_op2_forwarded),
        .out(alu_src_b)
    );
    
    // ALU
    ALU alu(
        .RD1(alu_op1_forwarded),
        .RD2(alu_src_b),
        .alu_control(E_alu_control),
        .alu_result(E_alu_o)
    );
    
    // Zero flag check
    zero_flag zero_check(
        .value(E_alu_o),
        .is_zero(E_zero)
    );
    
    // Branch/Jump target PC adder
    add_pc_imm target_pc_adder(
        .pc(E_PC),
        .imm_extended(E_ext),
        .pc_plus_imm(E_target_PC)
    );
    
    // EX/MA Pipeline Register
    pipeline_reg_ex_ma reg_ex_ma(
        .clk(clk),
        .rst(rst),
        .E_sel_result(E_sel_result),
        .E_we_dm(E_we_dm),
        .E_we_rf(E_we_rf),
        .E_alu_o(E_alu_o),
        .E_rf_rd2(E_rf_rd2),
        .E_rf_a3(E_rf_a3),
        .E_PC_P4(E_PC_P4),
        .E_ext(E_ext),
        .M_sel_result(M_sel_result),
        .M_we_dm(M_we_dm),
        .M_we_rf(M_we_rf),
        .M_alu_o(M_alu_o),
        .M_dm_wd(M_dm_wd),
        .M_rf_a3(M_rf_a3),
        .M_PC_P4(M_PC_P4),
        .M_ext(M_ext)
    );
    
    /////////////////////    MA STAGE    \\\\\\\\\\\\\\\\\\\\\\
    
    // Data Memory - keep this name DMEM
    data_memory DMEM(
        .clock(clk),
        .write_enable(M_we_dm),
        .address(M_alu_o),
        .write_data(M_dm_wd),
        .read_data(M_dm_rd)
    );
    
    // MA/WB Pipeline Register
    pipeline_reg_ma_wb reg_ma_wb(
        .clk(clk),
        .rst(rst),
        .M_sel_result(M_sel_result),
        .M_we_rf(M_we_rf),
        .M_dm_rd(M_dm_rd),
        .M_alu_o(M_alu_o),
        .M_rf_a3(M_rf_a3),
        .M_PC_P4(M_PC_P4),
        .M_ext(M_ext),
        .W_sel_result(W_sel_result),
        .W_we_rf(W_we_rf),
        .W_dm_rd(W_dm_rd),
        .W_alu_o(W_alu_o),
        .W_rf_a3(W_rf_a3),
        .W_PC_P4(W_PC_P4),
        .W_ext(W_ext)
    );
    
    /////////////////////    WB STAGE    \\\\\\\\\\\\\\\\\\\\\\
    
    // Result MUX: 4-to-1 using two 2-to-1 muxes
    // 00 = ALU result
    // 01 = Data memory read
    // 10 = PC+4 (for JAL)
    // 11 = Immediate (for LUI)
    
    wire [31:0] result_mux0_out;
    wire [31:0] result_mux1_out;
    
    mux mux_result_0(
        .sel(W_sel_result[0]),
        .input1(W_dm_rd),
        .input2(W_alu_o),
        .out(result_mux0_out)
    );
    
    mux mux_result_1(
        .sel(W_sel_result[0]),
        .input1(W_ext),      // Immediate (for LUI)
        .input2(W_PC_P4),    // PC+4 (for JAL)
        .out(result_mux1_out)
    );

    mux mux_result(
        .sel(W_sel_result[1]),
        .input1(result_mux1_out),  // PC+4 or Immediate
        .input2(result_mux0_out),  // ALU or Memory
        .out(W_result)
    );

endmodule
