`timescale 1ns/1ps

module pipeline_tb;
    reg clk = 0;
    reg reset;
    integer errors = 0;

    rv32i_pipeline_top #(
        .IMEM_ADDR_WIDTH(10),
        .DMEM_ADDR_WIDTH(10),
        .INIT_FILE("tb/test1.hex")
    ) dut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    function [31:0] regval(input integer idx);
        regval = dut.rf.x[32*idx +: 32];
    endfunction

    task check(input [255:0] name, input integer idx, input [31:0] expected);
        begin
            if (regval(idx) !== expected) begin
                $display("FAIL x%0d (%0s): expected %d (0x%h), got %d (0x%h)",
                          idx, name, expected, expected, regval(idx), regval(idx));
                errors = errors + 1;
            end else begin
                $display("PASS x%0d (%0s) = %d (0x%h)", idx, name, regval(idx), regval(idx));
            end
        end
    endtask

    initial begin
        $dumpfile("pipeline.vcd");
        $dumpvars(0, pipeline_tb);
    end

    initial begin
        reset = 1;
        repeat (3) @(posedge clk);
        reset = 0;

        // Run long enough for the whole program (including the 1-cycle
        // load-use stall and the branch/jump flush bubbles) to complete
        // and land in the halt: loop.
        repeat (120) @(posedge clk);

        $display("---- Register check ----");
        check("x1  addi",        1, 5);
        check("x2  addi",        2, 10);
        check("x3  add",         3, 15);
        check("x4  add fwd d1",  4, 30);
        check("x5  sub fwd d1",  5, 25);
        check("x6  addi fwd d1", 6, 125);
        check("x7  addi",        7, 7);
        check("x9  add fwd d2",  9, 7);
        check("x10 addi (base)",10, 256);
        check("x11 lw",         11, 125);
        check("x12 addi load-use",12, 126);
        check("x13 addi -1",    13, 32'hFFFFFFFF);
        check("x14 lbu",        14, 32'h000000FF);
        check("x15 lb",         15, 32'hFFFFFFFF);
        check("x16 lhu",        16, 32'h0000FFFF);
        check("x17 lh",         17, 32'hFFFFFFFF);
        check("x18 branches",   18, 11);
        check("x19 loop ctr",   19, 0);
        check("x20 loop sum",   20, 15);
        check("x21 jal link",   21, 32'h0000007C + 4);
        check("x22 subr",       22, 42);
        check("x25 post-return",25, 999);      // jalr returns to pc+4 after jal, so this DOES execute
        check("x23 lui",        23, 32'h12345000);
        check("x28 slt",        28, 1);
        check("x29 sltu",       29, 0);

        if (errors == 0)
            $display("ALL PIPELINE TESTS PASSED");
        else
            $display("%0d PIPELINE TESTS FAILED", errors);

        $finish;
    end

    // Optional cycle trace of the fetch PC for debugging
    // always @(posedge clk) if (!reset) $display("t=%0t PC=%h", $time, dut.pc_current);

endmodule
