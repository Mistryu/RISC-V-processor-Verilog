// Top-level core + memory
module rv_mc( // keep this name as your top module of rv_mc core
    input  wire clk, // keep this name: clk
    input  wire rst  // keep this name: rst
);

    // Register wires
    wire [31:0] pc;
    wire [31:0] instruction;
    wire [31:0] mem_read_data;
    wire [31:0] data_reg_out;
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] rd1_reg_out;
    wire [31:0] rd2_reg_out;
    wire [31:0] alu_result;
    wire [31:0] alu_reg_out;
    wire [31:0] pc_plus_4;
    
    wire [31:0] alu_src_a;
    wire [31:0] alu_src_b;
    wire [31:0] imm_extended;
    wire [31:0] mem_address;
    wire [31:0] rf_write_data;
    
    // Control signals
    wire        sel_mem_addr;
    wire        we_ir;
    wire        sel_alu_src_a;
    wire [1:0]  sel_alu_src_b;
    wire [1:0]  sel_result;
    wire        we_pc;
    wire        we_mem;
    wire        we_rf;
    wire        we_pc_plus_4;
    wire        we_alu_reg;
    wire [2:0]  sel_ext;
    wire [3:0]  alu_control;
    
    // Instruction field
    wire [4:0]  rs1 = instruction[19:15];
    wire [4:0]  rs2 = instruction[24:20];
    wire [4:0]  rd  = instruction[11:7];
    
    // Constant 4 for PC + 4
    localparam [31:0] CONSTANT_4 = 32'd4;
    
    register PC_reg(
        .clock(clk),
        .reset(rst),
        .write_enable(we_pc),
        .data_in(alu_result),
        .data_out(pc)
    );
    
    mux mux_mem_addr(
        .sel(sel_mem_addr),
        .input1(alu_reg_out),
        .input2(pc),
        .out(mem_address)
    );
    
    mem MEM // keep this name MEM
    (
        .clock(clk),
        .write_enable(we_mem),
        .address(mem_address),
        .write_data(rd2_reg_out),
        .read_data(mem_read_data)
    );
    
    register instr_reg(
        .clock(clk),
        .reset(rst),
        .write_enable(we_ir),
        .data_in(mem_read_data),
        .data_out(instruction)
    );
    
    Controller2_0 controller(
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .sel_mem_addr(sel_mem_addr),
        .we_ir(we_ir),
        .sel_alu_src_a(sel_alu_src_a),
        .sel_alu_src_b(sel_alu_src_b),
        .sel_result(sel_result),
        .we_pc(we_pc),
        .we_mem(we_mem),
        .we_rf(we_rf),
        .we_pc_plus_4(we_pc_plus_4),
        .we_alu_reg(we_alu_reg),
        .sel_ext(sel_ext),
        .alu_control(alu_control)
    );
    
    register_file rf(
        .clock(clk),
        .write_enable(we_rf),
        .read_address_1(rs1),
        .read_address_2(rs2),
        .write_address(rd),
        .write_data(rf_write_data),
        .read_data_1(rd1),
        .read_data_2(rd2)
    );
    
    register rd1_reg(
        .clock(clk),
        .reset(rst),
        .write_enable(1'b1),
        .data_in(rd1),
        .data_out(rd1_reg_out)
    );
    
    register rd2_reg(
        .clock(clk),
        .reset(rst),
        .write_enable(1'b1),
        .data_in(rd2),
        .data_out(rd2_reg_out)
    );
    
    sign_extender sign_ext(
        .instruction(instruction),
        .sel_ext(sel_ext),
        .imm_extended(imm_extended)
    );
    
    mux mux_alu_src_a(
        .sel(sel_alu_src_a),
        .input1(rd1_reg_out),
        .input2(pc),
        .out(alu_src_a)
    );
    
    MUX3 mux_alu_src_b(
        .sel(sel_alu_src_b),
        .input0(rd2_reg_out),
        .input1(imm_extended),
        .input2(CONSTANT_4),
        .out(alu_src_b)
    );
    
    ALU alu(
        .RD1(alu_src_a),
        .RD2(alu_src_b),
        .alu_control(alu_control),
        .alu_result(alu_result)
    );
    
    register alu_reg(
        .clock(clk),
        .reset(rst),
        .write_enable(we_alu_reg),
        .data_in(alu_result),
        .data_out(alu_reg_out)
    );
    
    // Needed fo Jal. I use this to store PC + 4 address for return 
    register pc_plus_4_reg(
        .clock(clk),
        .reset(rst),
        .write_enable(we_pc_plus_4),
        .data_in(alu_result),
        .data_out(pc_plus_4)
    );
    
    register data_reg(
        .clock(clk),
        .reset(rst),
        .write_enable(1'b1),
        .data_in(mem_read_data),
        .data_out(data_reg_out)
    );
    

    // Result Selection MUX for Register file
    // encoding:
    // 00 = ALU result (alu_reg_out)
    // 01 = Data memory read (data_reg_out)
    // 10 = PC+4 (for JAL return address - from pc_plus_4_reg)
    // 11 = Immediate (for LUI)
    // I will copy the 4 to 1 mux from the single cycle code 
    wire [31:0] result_mux0_out;
    wire [31:0] result_mux1_out;
    
    mux mux_result_0(
        .sel(sel_result[0]),
        .input1(data_reg_out),
        .input2(alu_reg_out),
        .out(result_mux0_out)
    );
    
    mux mux_result_1(
        .sel(sel_result[0]),
        .input1(imm_extended),
        .input2(pc_plus_4),
        .out(result_mux1_out)
    );
    
    mux mux_result(
        .sel(sel_result[1]),
        .input1(result_mux1_out),
        .input2(result_mux0_out),
        .out(rf_write_data)
    );

endmodule

