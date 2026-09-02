`timescale 1ns/1ps

// 32-to-1 mux over a flattened array of 32 words, each 32 bits wide.
// inp[32*k +: 32] holds word k. Fixes original bug that referenced the
// Verilog keyword `input` instead of the port name, and widened `sel`
// from 1 bit to the required 5 bits.
module mux32to1(
    input  [1023:0] inp,   // 32 words x 32 bits, flattened
    input  [4:0]    sel,
    output [31:0]   outp
);
    assign outp = inp[32*sel +: 32];
endmodule
