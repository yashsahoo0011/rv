`timescale 1ns/1ps

// Thin wrapper kept for interface continuity with the original design:
// selects one 32-bit word out of 32 from a flattened register array.
module bit32_32to1mux(
    output [31:0]    reg_out,
    input  [4:0]     reg_num,
    input  [1023:0]  reg_arr
);
    mux32to1 m1(.inp(reg_arr), .sel(reg_num), .outp(reg_out));
endmodule
