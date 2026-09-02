`timescale 1ns/1ps

module aluaddsub_tb;

    reg signed [31:0] a, b;
    reg ctrl;

    wire signed [31:0] outp;
    wire pos_of, neg_of;

    aluaddsub uut(outp, a, b, ctrl, pos_of, neg_of);

    initial begin
        $dumpfile("task1.vcd");
        $dumpvars(0, aluaddsub_tb);
    end

    initial begin
        $monitor($time, " A=%d, B=%d, ctrl=%b, Sum=%d, +OF=%b, -OF=%b",
                 a, b, ctrl, outp, pos_of, neg_of);

        a = 8;
        b = 4;
        ctrl = 0;
        #10;

        b = 10;
        ctrl = 1;
        #10;

        a = -2;
        b = -1;
        ctrl = 0;
        #10;

        a = 32'h7FFFFFFF;
        b = 1;
        ctrl = 0;
        #10;

        a = 32'h80000000;
        b = 1;
        ctrl = 1;
        #10;

        $finish;
    end

endmodule