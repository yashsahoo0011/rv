`timescale 1ns/1ps

// Word-organized data memory built from 4 byte-wide banks, so stores
// narrower than a word (SB/SH) only write the affected byte lane(s).
// addr is a byte address; only bits [ADDR_WIDTH+1:2] select the word
// (i.e. accesses are expected word-aligned at the bank-index level,
// with byte/half-word placement inside the word handled by wstrb).
module BankedMEM #(
    parameter ADDR_WIDTH = 10   // matches bank8's ADDR_WIDTH
)(
    input         clk,
    input  [31:0] addr,
    input  [31:0] wdata,
    input  [3:0]  wstrb,
    output [31:0] rdata
);
    wire [ADDR_WIDTH-1:0] word_addr = addr[ADDR_WIDTH+1:2];

    bank8 #(ADDR_WIDTH) b0(.clk(clk), .we(wstrb[0]), .addr(word_addr), .din(wdata[7:0]),   .dout(rdata[7:0]));
    bank8 #(ADDR_WIDTH) b1(.clk(clk), .we(wstrb[1]), .addr(word_addr), .din(wdata[15:8]),  .dout(rdata[15:8]));
    bank8 #(ADDR_WIDTH) b2(.clk(clk), .we(wstrb[2]), .addr(word_addr), .din(wdata[23:16]), .dout(rdata[23:16]));
    bank8 #(ADDR_WIDTH) b3(.clk(clk), .we(wstrb[3]), .addr(word_addr), .din(wdata[31:24]), .dout(rdata[31:24]));
endmodule
