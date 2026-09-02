`timescale 1ns/1ps

module if_id_reg(
    input             clk,
    input             reset,
    input             stall,   // hold current contents (load-use hazard)
    input             flush,   // squash to NOP (branch/jump misprediction)
    input      [31:0] pc_in,
    input      [31:0] pcplus4_in,
    input      [31:0] inst_in,
    output reg [31:0] pc_out,
    output reg [31:0] pcplus4_out,
    output reg [31:0] inst_out
);
    always @(posedge clk) begin
        if (reset || flush) begin
            pc_out      <= 32'b0;
            pcplus4_out <= 32'b0;
            inst_out    <= 32'h00000013; // ADDI x0,x0,0 (NOP)
        end else if (!stall) begin
            pc_out      <= pc_in;
            pcplus4_out <= pcplus4_in;
            inst_out    <= inst_in;
        end
        // else: stall -> hold current values
    end
endmodule
