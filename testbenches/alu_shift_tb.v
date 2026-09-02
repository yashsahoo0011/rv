`timescale 1ns/1ps

module alu_shift_tb;

    reg [31:0] inp;
    reg [4:0] b;
    reg ctrl;
    wire [31:0] outp;

    alushift uut(outp, inp, b, ctrl);

    initial begin
        $dumpfile("task2");
        $dumpvars(0, alu_shift_tb);
    end

    initial begin
        $monitor($time, "A=%b, Shift=%b, ctrl=%b, Output = %b",inp,b,ctrl,outp);

        inp = 4;
        b = 2;
        ctrl = 0;
        #10;

        inp = 5;
        b = 2;
        ctrl = 1;

        $finish;
    end






endmodule