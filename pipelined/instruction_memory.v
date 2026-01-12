module instruction_memory(
    input  wire [31:0] pc,
    output reg  [31:0] instruction
);

    parameter MEM_SIZE = 8192;
    reg [31:0] RAM [0:MEM_SIZE-1];
    
    initial begin
        $readmemh("program.hex", RAM);
    end
    
    always @(*) begin
        if (pc[31:2] < MEM_SIZE) begin
            instruction = RAM[pc[31:2]];
        end else begin
            instruction = 32'h00000013; // NOP
        end
    end

endmodule
