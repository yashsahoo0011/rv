`timescale 1ns/1ps

module mem_wb_reg(
    input             clk,
    input             reset,

    input      [31:0] aluresult_in,
    input      [31:0] memdata_in,
    input      [31:0] pcplus4_in,
    input      [31:0] imm_in,
    input      [4:0]  rd_in,
    input             regwrite_in,
    input      [1:0]  resultsrc_in,

    output reg [31:0] aluresult_out,
    output reg [31:0] memdata_out,
    output reg [31:0] pcplus4_out,
    output reg [31:0] imm_out,
    output reg [4:0]  rd_out,
    output reg        regwrite_out,
    output reg [1:0]  resultsrc_out
);
    always @(posedge clk) begin
        if (reset) begin
            aluresult_out <= 32'b0;
            memdata_out   <= 32'b0;
            pcplus4_out   <= 32'b0;
            imm_out       <= 32'b0;
            rd_out        <= 5'b0;
            regwrite_out  <= 1'b0;
            resultsrc_out <= 2'b0;
        end else begin
            aluresult_out <= aluresult_in;
            memdata_out   <= memdata_in;
            pcplus4_out   <= pcplus4_in;
            imm_out       <= imm_in;
            rd_out        <= rd_in;
            regwrite_out  <= regwrite_in;
            resultsrc_out <= resultsrc_in;
        end
    end
endmodule
