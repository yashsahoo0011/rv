`timescale 1ns/1ps

module forward_unit(
    input      [4:0] id_ex_rs1,
    input      [4:0] id_ex_rs2,
    input      [4:0] ex_mem_rd,
    input      [4:0] mem_wb_rd,
    input            ex_mem_regwrite,
    input            mem_wb_regwrite,
    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);
    // 00 = no forward (use ID/EX value), 10 = forward from EX/MEM, 01 = forward from MEM/WB
    always @(*) begin
        if (ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs1))
            forwardA = 2'b10;
        else if (mem_wb_regwrite && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs1))
            forwardA = 2'b01;
        else
            forwardA = 2'b00;

        if (ex_mem_regwrite && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs2))
            forwardB = 2'b10;
        else if (mem_wb_regwrite && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs2))
            forwardB = 2'b01;
        else
            forwardB = 2'b00;
    end
endmodule
