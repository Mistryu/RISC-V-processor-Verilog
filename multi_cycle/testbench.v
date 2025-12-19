module testbench;

    reg clock;
    reg rst;
    
    rv_mc dut(
        .clk(clock),
        .rst(rst)
    );
    
    initial begin
        clock = 0;
        rst = 1;
        #20;
        rst = 0;
        forever #10 clock = ~clock;
    end
    
    initial begin
        $dumpfile("riscv_mul.vcd");
        $dumpvars(0, testbench);
    end

    initial begin
        $readmemh("program.hex", dut.MEM.RAM);
        
        #10000;
        
        $display("Simulation completed at time: %0t ps", $time);
        $finish;
    end
    
    initial begin
        forever begin
            @(posedge clock);
            if (dut.we_pc || dut.we_rf || dut.we_mem || dut.instruction == 32'h00002083) begin
                $display("Time: %0t ps | PC: 0x%h | Inst: 0x%h", 
                         $time, dut.pc, dut.instruction);
                $display("PC Control: pc=0x%h original_pc=0x%h pc_plus_4=0x%h pc_for_alu=0x%h sel_original_pc=%b", 
                         dut.pc, dut.original_pc, dut.pc_plus_4, dut.pc_for_alu, dut.sel_original_pc);
                $display("ALU: SrcA=0x%h SrcB=0x%h Result=0x%h", 
                         dut.alu_src_a, dut.alu_src_b, dut.alu_result);
                $display("Immediate: imm_ext=0x%h", dut.imm_extended);
                $display("Write Enables: we_pc=%b we_rf=%b we_pc_plus_4=%b we_original_pc=%b", 
                         dut.we_pc, dut.we_rf, dut.we_pc_plus_4, dut.we_original_pc);
                $display("Register File Write: RF_Data=0x%h (rd=%0d)", 
                         dut.rf_write_data, dut.instruction[11:7]);
                $display("");
            end
        end
    end

endmodule

