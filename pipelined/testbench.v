// Testbench for Pipelined RISC-V Processor
module testbench;

    reg clock;
    reg rst_n;
    
    rv_pl dut(
        .clk(clock),
        .rst_n(rst_n)
    );
    
    initial begin
        clock = 0;
        rst_n = 0;
        #20;
        rst_n = 1;
        forever #10 clock = ~clock;
    end
    
    initial begin
        $dumpfile("riscv_pipelined.vcd");
        $dumpvars(0, testbench);
    end

    initial begin
        #10000;
        $display("Simulation completed at time: %0t ps", $time);
        $finish;
    end
    
    // Nice way to display the pipeline stages 
    // You can forward the output to a output.txt file for better readability
    initial begin
        forever begin
            @(posedge clock);
            if (dut.W_we_rf || dut.D_jump || dut.E_branch || dut.M_we_dm || dut.F_instr != 32'h00000000) begin
                
               $display("========================================");
                $display("Time: %0t ps", $time);

                
                // IF Stage
                $display("IF Stage: PC=0x%h PC+4=0x%h Inst=0x%h", 
                         dut.F_PC, dut.F_PC_P4, dut.F_instr);
                
                // ID Stage
                $display("ID Stage: PC=0x%h Inst=0x%h", dut.D_PC, dut.D_instr);
                $display("  Control: jump=%b branch=%b we_rf=%b we_dm=%b sel_result=%b", 
                         dut.D_jump, dut.D_branch, dut.D_we_rf, dut.D_we_dm, dut.D_sel_result);
                $display("  RF Read: rs1=x%0d(0x%h) rs2=x%0d(0x%h) rd=x%0d", 
                         dut.D_rs1, dut.D_rf_rd1, dut.D_rs2, dut.D_rf_rd2, dut.D_rf_a3);
                $display("  Immediate: ext=0x%h target_PC=0x%h", dut.D_ext, dut.D_target_PC);
                
                // EX Stage
                $display("EX Stage: PC=0x%h", dut.E_PC);
                $display("  ALU: op1=0x%h op2=0x%h result=0x%h zero=%b", 
                         dut.E_rf_rd1, dut.E_rf_rd2, dut.E_alu_o, dut.E_zero);
                $display("  Forwarding: op1_sel=%b op2_sel=%b", 
                         dut.E_forward_alu_op1, dut.E_forward_alu_op2);
                $display("  Control: we_rf=%b we_dm=%b sel_result=%b", 
                         dut.E_we_rf, dut.E_we_dm, dut.E_sel_result);
                
                // MA Stage
                $display("MA Stage: alu_result=0x%h dm_wd=0x%h dm_rd=0x%h", 
                         dut.M_alu_o, dut.M_dm_wd, dut.M_dm_rd);
                $display("  Control: we_rf=%b we_dm=%b sel_result=%b", 
                         dut.M_we_rf, dut.M_we_dm, dut.M_sel_result);
                
                // WB Stage
                $display("WB Stage: result=0x%h (rd=x%0d) we_rf=%b sel_result=%b", 
                         dut.W_result, dut.W_rf_a3, dut.W_we_rf, dut.W_sel_result);
                
                // Hazard Control
                $display("Hazard: PC_en=%b IF_ID_en=%b IF_ID_clr=%b ID_EX_clr=%b", 
                         dut.PC_en, dut.IF_ID_en, dut.IF_ID_clr, dut.ID_EX_clr);
                
                $display("");
            end
        end
    end

endmodule
