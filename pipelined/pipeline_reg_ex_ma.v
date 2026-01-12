// EX/MA Pipeline Register
module pipeline_reg_ex_ma(
    input  wire        clk,
    input  wire        rst,
    // Control signals from EX stage
    input  wire [1:0]  E_sel_result,
    input  wire        E_we_dm,
    input  wire        E_we_rf,
    // Data from EX stage
    input  wire [31:0] E_alu_o,
    input  wire [31:0] E_rf_rd2,
    input  wire [4:0]  E_rf_a3,
    input  wire [31:0] E_PC_P4,
    input  wire [31:0] E_ext,        // Immediate (for LUI)
    
    // Outputs to MA stage
    output reg  [1:0]  M_sel_result,
    output reg         M_we_dm,
    output reg         M_we_rf,
    output reg  [31:0] M_alu_o,
    output reg  [31:0] M_dm_wd,
    output reg  [4:0]  M_rf_a3,
    output reg  [31:0] M_PC_P4,
    output reg  [31:0] M_ext         // Immediate (for LUI)
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            M_sel_result <= 2'b00;
            M_we_dm      <= 1'b0;
            M_we_rf      <= 1'b0;
            M_alu_o      <= 32'h00000000;
            M_dm_wd      <= 32'h00000000;
            M_rf_a3      <= 5'b00000;
            M_PC_P4      <= 32'h00000000;
            M_ext        <= 32'h00000000;
        end else begin
            M_sel_result <= E_sel_result;
            M_we_dm      <= E_we_dm;
            M_we_rf      <= E_we_rf;
            M_alu_o      <= E_alu_o;
            M_dm_wd      <= E_rf_rd2;
            M_rf_a3      <= E_rf_a3;
            M_PC_P4      <= E_PC_P4;
            M_ext        <= E_ext;
        end
    end

endmodule
