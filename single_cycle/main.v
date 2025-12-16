module main(
    input  wire clock
);

    // Internal wires
    wire [31:0] pc;
    wire [31:0] next_pc;
    wire [31:0] pc_plus_4;
    wire [31:0] pc_plus_imm;
    wire [31:0] instruction;
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] imm_extended;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire [31:0] dmem_read_data;
    wire [31:0] rf_write_data;
    wire [31:0] mux_result_intermediate;
    wire [31:0] mux_result_pc_imm;
    
    // Controller
    wire        rf_we;
    wire [2:0]  sel_ext;
    wire        sel_alu_src_b;
    wire [3:0]  alu_control;
    wire        dmem_we;
    wire [1:0]  sel_result;
    wire        sel_pc_src;
    
    // Instruction field extraction
    wire [4:0]  rs1 = instruction[19:15];
    wire [4:0]  rs2 = instruction[24:20];
    wire [4:0]  rd  = instruction[11:7];

    // Program Counter
    program_counter pc_module(
        .clk(clock),
        .next_pc(next_pc),
        .pc(pc)
    );

    // Adder for PC + 4
    add pc_adder(
        .pc(pc),
        .next_pc(pc_plus_4)
    );
    
    // Adder for PC + immediate JAL
    add_pc_imm add_pc_imm(
        .pc(pc),
        .imm_extended(imm_extended),
        .pc_plus_imm(pc_plus_imm)
    );
    
    // MUX for PC source: PC+4 or PC+imm for jal
    mux mux_pc_src(
        .sel(sel_pc_src),
        .input1(pc_plus_imm),
        .input2(pc_plus_4),
        .out(next_pc)
    );

    // Instruction Memory
    instructoin_memory inst_mem(
        .pc(pc),
        .instruction(instruction)
    );

    // Controller
    controller ctrl(
        .instruction(instruction),
        .rf_we(rf_we),
        .sel_ext(sel_ext),
        .sel_alu_src_b(sel_alu_src_b),
        .dmem_we(dmem_we),
        .sel_result(sel_result),
        .sel_pc_src(sel_pc_src),
        .alu_control(alu_control)
    );

    // Register File
    register_file rf(
        .clock(clock),
        .write_enable(rf_we),
        .read_address_1(rs1),
        .read_address_2(rs2),
        .write_address(rd),
        .write_data(rf_write_data),
        .read_data_1(rd1),
        .read_data_2(rd2)
    );

    // Sign Extender
    sign_extender sign_ext(
        .instruction(instruction),
        .sel_ext(sel_ext),
        .imm_extended(imm_extended)
    );

    // MUX for ALU Left
    mux mux_alu_src_b(
        .sel(sel_alu_src_b),
        .input1(rd2),
        .input2(imm_extended),
        .out(alu_operand_b)
    );

    // ALU
    ALU alu(
        .RD1(rd1),
        .RD2(alu_operand_b),
        .alu_control(alu_control),
        .alu_result(alu_result)
    );

    // Data Memory
    data_memory dmem(
        .clock(clock),
        .write_enable(dmem_we),
        .address(alu_result),
        .write_data(rd2),
        .read_data(dmem_read_data)
    );

    // MUX for Result alu to mem
    mux mux_result_alu_mem(
        .sel(sel_result[0]),
        .input1(alu_result),
        .input2(dmem_read_data),
        .out(mux_result_intermediate)
    );
    
    // MUX for Result pc imm
    mux mux_result_pc_imm_mux(
        .sel(sel_result[0]),
        .input1(pc_plus_4),
        .input2(imm_extended),
        .out(mux_result_pc_imm)
    );
    
    // MUX for Result: Final selection
    mux mux_result_final(
        .sel(sel_result[1]),
        .input1(mux_result_intermediate),
        .input2(mux_result_pc_imm),
        .out(rf_write_data)
    );

endmodule

