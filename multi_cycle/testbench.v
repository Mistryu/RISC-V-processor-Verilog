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
        $dumpfile("riscv_processor.vcd");
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
                $display("  ALU: SrcA=0x%h SrcB=0x%h Ctrl=%b Result=0x%h", 
                         dut.alu_src_a, dut.alu_src_b, dut.alu_control, dut.alu_result);
                $display("  Control: sel_alu_src_a=%b sel_alu_src_b=%b imm_ext=0x%h", 
                         dut.sel_alu_src_a, dut.sel_alu_src_b, dut.imm_extended);
                $display("  ALU_Reg: Out=0x%h | Mem_Addr=0x%h sel_mem_addr=%b we_mem=%b", 
                         dut.alu_reg_out, dut.mem_address, dut.sel_mem_addr, dut.we_mem);
                if (dut.we_mem) begin
                    $display("  STORE: Writing 0x%h (rd2_reg_out) to address 0x%h", dut.rd2_reg_out, dut.mem_address);
                end
                $display("  Memory: Read_Data=0x%h Data_Reg_Out=0x%h", 
                         dut.mem_read_data, dut.data_reg_out);
                $display("  Updates: ALU_Result=0x%h PC_Upd=%b RF_Wr=%b RF_Data=0x%h", 
                         dut.alu_result, dut.we_pc, dut.we_rf, dut.rf_write_data);
                $display("");
            end
        end
    end

endmodule

