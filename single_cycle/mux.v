module mux (
    input  wire         sel,    
    input  wire [31:0]  input1,    
    input  wire [31:0]  input2,    
    output wire [31:0]  out
);

    // Combinational logic
    assign out = sel ? input1 : input2;

endmodule

