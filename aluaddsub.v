`timescale 1ns/1ps

module aluaddsub(outp, a, b, ctrl, pos_of, neg_of);

    input signed [31:0] a, b;
    output signed [31:0] outp;
    input ctrl;
    output pos_of, neg_of;

    wire [31:0] bop;
    wire [32:0] output_boob;
    wire [31:0] sum_withoutmsb;

    assign bop = ctrl ? ~b : b;

    assign output_boob = a + bop + ctrl;
    assign outp = output_boob[31:0];

    assign sum_withoutmsb = a[30:0] + bop[30:0] + ctrl;

    assign pos_of = sum_withoutmsb[31] & ~output_boob[32];
    assign neg_of = ~sum_withoutmsb[31] & output_boob[32];

endmodule