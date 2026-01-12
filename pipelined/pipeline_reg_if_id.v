// IF/ID Register
module pipeline_reg_if_id(
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    input  wire        clr,
    input  wire [31:0] F_instr,
    input  wire [31:0] F_PC,
    input  wire [31:0] F_PC_P4,
    
    output reg  [31:0] D_instr,
    output reg  [31:0] D_PC,
    output reg  [31:0] D_PC_P4
);

    always @(posedge clk or posedge rst) begin
        if (rst || clr) begin
            D_instr <= 32'h00000013; // NOP
            D_PC    <= 32'h00000000;
            D_PC_P4 <= 32'h00000000;
        end else if (en) begin
            D_instr <= F_instr;
            D_PC    <= F_PC;
            D_PC_P4 <= F_PC_P4;
        end
    end

endmodule
