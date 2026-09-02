`timescale 1ns/1ps

// ctrl: 0 = SLT (signed), 1 = SLTU (unsigned)
module alucomp(outp, a, b, ctrl);
    input  [31:0] a, b;
    input         ctrl;
    output [31:0] outp;

    wire slt_signed  = $signed(a) < $signed(b);
    wire slt_unsigned = a < b;
    wire slt = ctrl ? slt_unsigned : slt_signed;

    assign outp = {31'b0, slt};
endmodule
