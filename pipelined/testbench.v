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

endmodule
