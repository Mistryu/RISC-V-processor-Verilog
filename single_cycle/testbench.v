module testbench;

    reg clock;
    
    main dut(
        .clock(clock)
    );
    
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end
    
    initial begin
        $dumpfile("riscv_processor.vcd");
        $dumpvars(0, testbench);
    end

    initial begin
        #20000;
        $display("Simulation completed time: %0t", $time);
        $display("Final PC: 0x%h", dut.pc);
        
        $finish;
    end
    
    //Debugging info. You can check the values here instead of using gdkwave to an extent :)
    initial begin
        $monitor("Time: %0t | PC: 0x%h | next_pc: 0x%h | pc_plus_4: 0x%h | pc_plus_imm: 0x%h | sel_pc_src: %b | rd1: 0x%h | rd2: 0x%h | Instruction: 0x%h | ALU Result: 0x%h", 
                 $time, dut.pc, dut.next_pc, dut.pc_plus_4, dut.pc_plus_imm, dut.sel_pc_src, dut.rd1, dut.rd2, dut.instruction, dut.alu_result);
    end

endmodule

