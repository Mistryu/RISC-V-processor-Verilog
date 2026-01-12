// ID/EX Pipeline Register
module pipeline_reg_id_ex(
    input  wire        clk,
    input  wire        rst,
    input  wire        clr,
    // Control signals from ID stage
    input  wire        D_jump,
    input  wire        D_branch,
    input  wire [1:0]  D_sel_result,
    input  wire        D_we_dm,
    input  wire [3:0]  D_alu_control,
    input  wire        D_sel_alu_src_b,
    input  wire        D_we_rf,
    // Data from ID stage
    input  wire [31:0] D_rf_rd1,
    input  wire [31:0] D_rf_rd2,
    input  wire [4:0]  D_rf_a3,
    input  wire [4:0]  D_rs1,
    input  wire [4:0]  D_rs2,
    input  wire [31:0] D_ext,
    input  wire [31:0] D_PC,
    input  wire [31:0] D_PC_P4,
    
    // Outputs to EX stage
    output reg         E_jump,
    output reg         E_branch,
    output reg  [1:0]  E_sel_result,
    output reg         E_we_dm,
    output reg  [3:0]  E_alu_control,
    output reg         E_sel_alu_src_b,
    output reg         E_we_rf,
    output reg  [31:0] E_rf_rd1,
    output reg  [31:0] E_rf_rd2,
    output reg  [4:0]  E_rf_a3,
    output reg  [4:0]  E_rs1,
    output reg  [4:0]  E_rs2,
    output reg  [31:0] E_ext,
    output reg  [31:0] E_PC,
    output reg  [31:0] E_PC_P4
);

    always @(posedge clk or posedge rst) begin
        if (rst || clr) begin
            E_jump         <= 1'b0;
            E_branch       <= 1'b0;
            E_sel_result   <= 2'b00;
            E_we_dm        <= 1'b0;
            E_alu_control  <= 4'b0000;
            E_sel_alu_src_b <= 1'b0;
            E_we_rf        <= 1'b0;
            E_rf_rd1       <= 32'h00000000;
            E_rf_rd2       <= 32'h00000000;
            E_rf_a3        <= 5'b00000;
            E_rs1          <= 5'b00000;
            E_rs2          <= 5'b00000;
            E_ext          <= 32'h00000000;
            E_PC           <= 32'h00000000;
            E_PC_P4        <= 32'h00000000;
        end else begin
            E_jump         <= D_jump;
            E_branch       <= D_branch;
            E_sel_result   <= D_sel_result;
            E_we_dm        <= D_we_dm;
            E_alu_control  <= D_alu_control;
            E_sel_alu_src_b <= D_sel_alu_src_b;
            E_we_rf        <= D_we_rf;
            E_rf_rd1       <= D_rf_rd1;
            E_rf_rd2       <= D_rf_rd2;
            E_rf_a3        <= D_rf_a3;
            E_rs1          <= D_rs1;
            E_rs2          <= D_rs2;
            E_ext          <= D_ext;
            E_PC           <= D_PC;
            E_PC_P4        <= D_PC_P4;
        end
    end

endmodule
