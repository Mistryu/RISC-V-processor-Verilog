module testbench_cpi;

    reg clock, rst;
    rv_mc dut(.clk(clock), .rst(rst));
    
    integer cycles = 0;
    integer instructions = 0;
    reg prev_we_rf;
    reg prev_we_mem;
    
    initial begin
        clock = 0;
        rst = 1;
        prev_we_rf = 0;
        prev_we_mem = 0;
        #20;
        rst = 0;
        forever #10 clock = ~clock;
    end
    
    initial begin
        $readmemh("program.hex", dut.MEM.RAM);
        $dumpfile("riscv_cpi.vcd");
        $dumpvars(1, testbench_cpi);
        #10000;
        $dumpall;
        $dumpflush;
        $dumpoff;
        $finish;
    end
    
    // Due to the last instruction not being counted in the loop because there is no edge after the last addition we always need to manually add it
    // This is the downside of counting instruction after they complete
    always @(posedge clock) begin
        if (!rst) begin
            cycles = cycles + 1;
            // Count instructions when they complete
            if ((dut.we_rf && !prev_we_rf) || (dut.we_mem && !prev_we_mem)) begin
                instructions = instructions + 1;
            end
            prev_we_rf = dut.we_rf;
            prev_we_mem = dut.we_mem;
        end else begin
            prev_we_rf = 0;
            prev_we_mem = 0;
        end
    end

endmodule
