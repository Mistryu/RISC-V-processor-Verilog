module Controller2_0(
    input  wire clk,
    input  wire  rst,
    input  wire [31:0] instruction,
    
    output wire sel_mem_addr,
    output wire we_ir,
    output wire sel_alu_src_a,
    output wire [1:0] sel_alu_src_b,
    output wire [1:0] sel_result,
    output wire we_pc,
    output wire we_mem,
    output wire we_rf,
    output wire we_pc_plus_4,
    output wire we_alu_reg,
    
    output wire [2:0] sel_ext,
    
    output wire [3:0] alu_control
);

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire funct7_bit5;
    wire [1:0] alu_op;

    // Add registers to save previous states whenever it's necessary
    // lui instruction was not convered 
    // Only have 1 testbench that tests the whole thing timewise and calculate it for CPI 
    // Work on the drawio diagrams
    // It has to work for paraell the delays are not supposed to happen!!!!

    
    assign funct3 = instruction[14:12];
    assign funct7_bit5 = instruction[30];
    
    Instruction_Decoder instr_decoder(
        .instruction(instruction),
        .opcode(opcode),
        .sel_ext(sel_ext)
    );

    FSM fsm(
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .sel_mem_addr(sel_mem_addr),
        .we_ir(we_ir),
        .sel_alu_src_a(sel_alu_src_a),
        .sel_alu_src_b(sel_alu_src_b),
        .alu_op(alu_op),
        .sel_result(sel_result),
        .we_pc(we_pc),
        .we_mem(we_mem),
        .we_rf(we_rf),
        .we_pc_plus_4(we_pc_plus_4),
        .we_alu_reg(we_alu_reg)
    );

    ALU_Decoder alu_decoder(
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7_bit5(funct7_bit5),
        .alu_control(alu_control)
    );

endmodule

