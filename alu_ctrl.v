`timescale 1ns/1ps

// ALUOp meaning (set by the main ControlUnit from the opcode):
//   2'b00 : force ADD  (loads, stores, JAL/JALR/AUIPC address calc)
//   2'b01 : R-type     (alt = funct7[5], op = funct3)
//   2'b10 : I-type ALU-immediate (ADDI/SLTI/.../SLLI/SRLI/SRAI):
//           alt = funct7b5 only for the two shift funct3 codes
//           (SRAI reuses that immediate bit as the arithmetic-shift
//           flag); forced to 0 for every other I-type op since there
//           is no "SUBI" and that bit is just part of the immediate.
module alu_ctrl(
    input      [1:0] aluop,
    input      [2:0] funct3,
    input             funct7b5,
    output reg [3:0] alu_ctrl
);
    wire is_shift = (funct3 == 3'b001) || (funct3 == 3'b101);

    always @(*) begin
        case (aluop)
            2'b00:   alu_ctrl = 4'b0000;                          // ADD
            2'b01:   alu_ctrl = {funct7b5, funct3};                 // R-type
            2'b10:   alu_ctrl = {(is_shift ? funct7b5 : 1'b0), funct3}; // I-type imm
            default: alu_ctrl = 4'b0000;
        endcase
    end
endmodule
