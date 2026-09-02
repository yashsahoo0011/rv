`timescale 1ns/1ps

module ex_mem_reg(
    input             clk,
    input             reset,

    input      [31:0] aluresult_in,
    input      [31:0] writedata_in,   // store data (forwarded rs2)
    input      [31:0] pcplus4_in,
    input      [31:0] imm_in,
    input      [4:0]  rd_in,
    input      [2:0]  funct3_in,
    input             regwrite_in,
    input      [1:0]  resultsrc_in,
    input             memwrite_in,

    output reg [31:0] aluresult_out,
    output reg [31:0] writedata_out,
    output reg [31:0] pcplus4_out,
    output reg [31:0] imm_out,
    output reg [4:0]  rd_out,
    output reg [2:0]  funct3_out,
    output reg        regwrite_out,
    output reg [1:0]  resultsrc_out,
    output reg        memwrite_out
);
    always @(posedge clk) begin
        if (reset) begin
            aluresult_out <= 32'b0;
            writedata_out <= 32'b0;
            pcplus4_out   <= 32'b0;
            imm_out       <= 32'b0;
            rd_out        <= 5'b0;
            funct3_out    <= 3'b0;
            regwrite_out  <= 1'b0;
            resultsrc_out <= 2'b0;
            memwrite_out  <= 1'b0;
        end else begin
            aluresult_out <= aluresult_in;
            writedata_out <= writedata_in;
            pcplus4_out   <= pcplus4_in;
            imm_out       <= imm_in;
            rd_out        <= rd_in;
            funct3_out    <= funct3_in;
            regwrite_out  <= regwrite_in;
            resultsrc_out <= resultsrc_in;
            memwrite_out  <= memwrite_in;
        end
    end
endmodule
