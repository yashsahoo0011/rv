`timescale 1ns/1ps

module id_ex_reg(
    input             clk,
    input             reset,
    input             flush,     // squash to a bubble (load-use stall or branch/jump flush)

    input      [31:0] pc_in, pcplus4_in,
    input      [31:0] rs1data_in, rs2data_in,
    input      [31:0] imm_in,
    input      [4:0]  rs1_in, rs2_in, rd_in,
    input      [2:0]  funct3_in,
    input             alusrca_in, alusrc_in,
    input      [3:0]  aluctrl_in,
    input             regwrite_in,
    input      [1:0]  resultsrc_in,
    input             memwrite_in, memread_in,
    input             branch_in, jump_in,

    output reg [31:0] pc_out, pcplus4_out,
    output reg [31:0] rs1data_out, rs2data_out,
    output reg [31:0] imm_out,
    output reg [4:0]  rs1_out, rs2_out, rd_out,
    output reg [2:0]  funct3_out,
    output reg        alusrca_out, alusrc_out,
    output reg [3:0]  aluctrl_out,
    output reg        regwrite_out,
    output reg [1:0]  resultsrc_out,
    output reg        memwrite_out, memread_out,
    output reg        branch_out, jump_out
);
    always @(posedge clk) begin
        if (reset || flush) begin
            pc_out        <= 32'b0;
            pcplus4_out   <= 32'b0;
            rs1data_out   <= 32'b0;
            rs2data_out   <= 32'b0;
            imm_out       <= 32'b0;
            rs1_out       <= 5'b0;
            rs2_out       <= 5'b0;
            rd_out        <= 5'b0;
            funct3_out    <= 3'b0;
            alusrca_out   <= 1'b0;
            alusrc_out    <= 1'b0;
            aluctrl_out   <= 4'b0;
            regwrite_out  <= 1'b0;
            resultsrc_out <= 2'b0;
            memwrite_out  <= 1'b0;
            memread_out   <= 1'b0;
            branch_out    <= 1'b0;
            jump_out      <= 1'b0;
        end else begin
            pc_out        <= pc_in;
            pcplus4_out   <= pcplus4_in;
            rs1data_out   <= rs1data_in;
            rs2data_out   <= rs2data_in;
            imm_out       <= imm_in;
            rs1_out       <= rs1_in;
            rs2_out       <= rs2_in;
            rd_out        <= rd_in;
            funct3_out    <= funct3_in;
            alusrca_out   <= alusrca_in;
            alusrc_out    <= alusrc_in;
            aluctrl_out   <= aluctrl_in;
            regwrite_out  <= regwrite_in;
            resultsrc_out <= resultsrc_in;
            memwrite_out  <= memwrite_in;
            memread_out   <= memread_in;
            branch_out    <= branch_in;
            jump_out      <= jump_in;
        end
    end
endmodule
