module MUX3 (
    input  wire [1:0]  sel,    
    input  wire [31:0] input0,    
    input  wire [31:0] input1,    
    input  wire [31:0] input2,    
    output wire [31:0] out
);

    assign out = (sel == 2'b00) ? input0 :
                 (sel == 2'b01) ? input1 :
                 input2;

endmodule
