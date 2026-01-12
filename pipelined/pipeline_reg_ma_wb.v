// MA/WB Pipeline Register
module pipeline_reg_ma_wb(
    input  wire        clk,
    input  wire        rst,
    // Control signals from MA stage
    input  wire [1:0]  M_sel_result,
    input  wire        M_we_rf,
    // Data from MA stage
    input  wire [31:0] M_dm_rd,
    input  wire [31:0] M_alu_o,
    input  wire [4:0]  M_rf_a3,
    input  wire [31:0] M_PC_P4,
    input  wire [31:0] M_ext,        // Immediate (for LUI)
    
    // Outputs to WB stage
    output reg  [1:0]  W_sel_result,
    output reg         W_we_rf,
    output reg  [31:0] W_dm_rd,
    output reg  [31:0] W_alu_o,
    output reg  [4:0]  W_rf_a3,
    output reg  [31:0] W_PC_P4,
    output reg  [31:0] W_ext         // Immediate (for LUI)
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            W_sel_result <= 2'b00;
            W_we_rf      <= 1'b0;
            W_dm_rd      <= 32'h00000000;
            W_alu_o      <= 32'h00000000;
            W_rf_a3      <= 5'b00000;
            W_PC_P4      <= 32'h00000000;
            W_ext        <= 32'h00000000;
        end else begin
            W_sel_result <= M_sel_result;
            W_we_rf      <= M_we_rf;
            W_dm_rd      <= M_dm_rd;
            W_alu_o      <= M_alu_o;
            W_rf_a3      <= M_rf_a3;
            W_PC_P4      <= M_PC_P4;
            W_ext        <= M_ext;
        end
    end

endmodule
