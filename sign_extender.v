module sign_extender(
    input  wire [31:0] instruction,
    input  wire [2:0]  sel_ext,          
    output reg  [31:0] imm_extended           
);

    reg [11:0] immediate_12bit;
    reg [12:0] immediate_13bit;
    reg [20:0] immediate_21bit;
    reg [19:0] immediate_20bit;
    reg        sign_bit;
    
    // Combinational logic
    always @(*) begin
        case (sel_ext)

            // I-type: imm[11:0] from I-type
            3'b000: begin
                immediate_12bit = instruction[31:20];
                sign_bit = immediate_12bit[11];
                
                if (sign_bit) begin
                    imm_extended = {20'hFFFFF, immediate_12bit};
                end else begin
                    imm_extended = {20'h00000, immediate_12bit};
                end
            end
            
            // S-type: imm[11:0] from S-type
            3'b001: begin
                immediate_12bit = {instruction[31:25], instruction[11:7]};
                sign_bit = immediate_12bit[11];
                
                if (sign_bit) begin
                    imm_extended = {20'hFFFFF, immediate_12bit};
                end else begin
                    imm_extended = {20'h00000, immediate_12bit};
                end
            end

            // B-type: imm[12:0] from B-type
            3'b010: begin
                immediate_13bit = {instruction[31], instruction[7], instruction[30:25], 
                                   instruction[11:8], 1'b0};
                sign_bit = immediate_13bit[12];
                
                if (sign_bit) begin
                    imm_extended = {19'h7FFFF, immediate_13bit};
                end else begin
                    imm_extended = {19'h00000, immediate_13bit};
                end
            end
            
            // U-type: imm[31:12] from U-type
            3'b011: begin
                immediate_20bit = instruction[31:12];
                imm_extended = {immediate_20bit, 12'b0};
            end

            // J-type: imm[20:0] from J-type
            3'b100: begin
                immediate_21bit = {instruction[31], instruction[19:12], instruction[20],
                                   instruction[30:21], 1'b0};
                sign_bit = immediate_21bit[20];
                
                if (sign_bit) begin
                    imm_extended = {11'h7FF, immediate_21bit};
                end else begin
                    imm_extended = {11'h000, immediate_21bit};
                end
            end

            // Default case: wrong input 
            default: begin
                imm_extended = 32'h00000000;
            end
        endcase
    end

endmodule