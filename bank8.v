`timescale 1ns/1ps

// One byte-wide memory bank. Four of these, one per byte lane, form
// the 32-bit BankedMEM data memory (see BankedMEM.v). Write is
// synchronous; read is asynchronous so the MEM pipeline stage sees
// data combinationally within the same cycle the address is valid.
module bank8 #(
    parameter ADDR_WIDTH = 10   // 2^10 = 1024 bytes per bank -> 4KB total memory
)(
    input                       clk,
    input                       we,
    input  [ADDR_WIDTH-1:0]     addr,
    input  [7:0]                din,
    output [7:0]                dout
);
    reg [7:0] mem [0:(1<<ADDR_WIDTH)-1];

    always @(posedge clk) begin
        if (we) mem[addr] <= din;
    end

    assign dout = mem[addr];
endmodule
