`timescale 1ns/1ps

module reg32(
    input             clk,
    input             reset,
    input             we,
    input      [31:0] d,
    output reg [31:0] q
);
    always @(posedge clk) begin
        if (reset)
            q <= 32'b0;
        else if (we)
            q <= d;
    end
endmodule
