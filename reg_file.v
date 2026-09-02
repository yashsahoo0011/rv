`timescale 1ns/1ps

// 32 x 32-bit RISC-V register file. x0 is hardwired to zero (its reg32
// instance is simply never created, and its slot in the flattened bus
// is tied low), so writes with rd == 0 are naturally discarded.
module regfile(
    input         clk,
    input         reset,
    input         we,
    input  [4:0]  rs1,
    input  [4:0]  rs2,
    input  [4:0]  rd,
    input  [31:0] wd,
    output [31:0] r1,
    output [31:0] r2
);

    wire [1023:0] x;          // flattened array: x[32*i +: 32] = register i
    wire [31:0]   ctrl;       // one-hot write-enable, one bit per register

    decoder5to32 d1(
        .rd(rd),
        .we(we),
        .dec_out(ctrl)
    );

    assign x[31:0] = 32'b0;   // x0 hardwired to 0

    genvar i;
    generate
        for (i = 1; i < 32; i = i + 1) begin : reg_gen
            reg32 r_inst(
                .clk(clk),
                .reset(reset),
                .we(ctrl[i]),
                .d(wd),
                .q(x[32*i +: 32])
            );
        end
    endgenerate

    wire [31:0] r1_raw, r2_raw;
    bit32_32to1mux m1(.reg_out(r1_raw), .reg_num(rs1), .reg_arr(x));
    bit32_32to1mux m2(.reg_out(r2_raw), .reg_num(rs2), .reg_arr(x));

    // Write-through bypass: if this same cycle is writing the register
    // we're reading, forward the write data directly instead of the
    // (stale, pre-update) register output.
    assign r1 = (we && rd != 5'b0 && rd == rs1) ? wd : r1_raw;
    assign r2 = (we && rd != 5'b0 && rd == rs2) ? wd : r2_raw;

endmodule
