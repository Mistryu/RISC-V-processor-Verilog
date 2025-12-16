module instructoin_memory(
    input  wire [31:0] pc,              
    output reg  [31:0] instruction      
);

    // Memory size: 32 KB
    parameter MEM_SIZE = 8192;     
    reg [31:0] memory [0:MEM_SIZE-1];

    initial begin
        $readmemh("program.hex", memory);
    end

    // Combinational logic
    always @(*) begin
        if (pc[31:2] < MEM_SIZE) begin  // Check in case address out of bounds
            instruction = memory[pc[31:2]];
        end else begin
            instruction = 32'h00000013; // NOP
        end
    end

endmodule