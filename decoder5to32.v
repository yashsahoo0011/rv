module decoder5to32 (
    input  [4:0] rd,
    input        we,
    output [31:0] dec_out
);

    assign dec_out = we ? (32'b1 << rd) : 32'b0;

endmodule