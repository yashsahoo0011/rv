`timescale 1ns/1ps

// alu_ctrl = {alt, funct3}. This mirrors the RISC-V instruction encoding
// directly: funct3 selects the operation family, and `alt` (funct7[5],
// or the ADDI/SRAI immediate-shift bit) disambiguates ADD/SUB and
// SRL/SRA. See alu_ctrl.v for how this is generated from the instruction.
//
//  alu_ctrl   op
//  0_000      ADD
//  1_000      SUB
//  x_001      SLL
//  x_010      SLT
//  x_011      SLTU
//  x_100      XOR
//  0_101      SRL
//  1_101      SRA
//  x_110      OR
//  x_111      AND
module rv32ialu(a, b, alu_ctrl, zero, res);

    input  [31:0] a, b;
    input  [3:0]  alu_ctrl;
    output        zero;
    output [31:0] res;

    wire alt = alu_ctrl[3];
    wire [2:0] funct3 = alu_ctrl[2:0];

    wire [31:0] add_sub_res, logic_res, shift_res, comp_res;
    wire pos_of, neg_of;

    // add/sub: alt=0 add, alt=1 sub (aluaddsub: ctrl=1 => subtract)
    aluaddsub inst1 (add_sub_res, a, b, alt, pos_of, neg_of);

    // logic: AND/OR/XOR
    wire [1:0] logic_ctrl = (funct3 == 3'b100) ? 2'b10 :   // XOR
                             (funct3 == 3'b110) ? 2'b01 :   // OR
                                                   2'b00;    // AND
    alulogic inst2 (a, b, logic_ctrl, logic_res);

    // shift: SLL / SRL / SRA
    wire [1:0] shift_ctrl = (funct3 == 3'b001) ? 2'b00 :          // SLL
                             alt                ? 2'b10 : 2'b01;   // SRA : SRL
    alushift inst3 (shift_res, a, b[4:0], shift_ctrl);

    // compare: SLT / SLTU
    wire comp_ctrl = (funct3 == 3'b011);
    alucomp inst4 (comp_res, a, b, comp_ctrl);

    reg [31:0] res_r;
    assign res = res_r;

    always @(*) begin
        case (funct3)
            3'b000:  res_r = add_sub_res;
            3'b001:  res_r = shift_res;
            3'b010:  res_r = comp_res;
            3'b011:  res_r = comp_res;
            3'b100:  res_r = logic_res;
            3'b101:  res_r = shift_res;
            3'b110:  res_r = logic_res;
            3'b111:  res_r = logic_res;
            default: res_r = 32'b0;
        endcase
    end

    assign zero = (res == 32'b0);

endmodule
