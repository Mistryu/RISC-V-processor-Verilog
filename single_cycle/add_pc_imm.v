module add_pc_imm(
    input  wire [31:0] pc,
    input  wire [31:0] imm_extended,
    output wire [31:0] pc_plus_imm
);

    assign pc_plus_imm = pc + imm_extended;

endmodule