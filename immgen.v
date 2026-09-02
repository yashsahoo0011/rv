`timescale 1ns/1ps

// Sign-extends the immediate out of a 32-bit instruction based on its
// format, selected by immsrc (driven by the main ControlUnit from opcode):
//   000 : I-type (loads, ADDI/SLTI/.../JALR, imm[11:0] = inst[31:20])
//   001 : S-type (stores)
//   010 : B-type (branches)
//   011 : U-type (LUI, AUIPC)
//   100 : J-type (JAL)
module immgen(
    input      [31:0] inst,
    input      [2:0]  immsrc,
    output reg [31:0] imm
);
    always @(*) begin
        case (immsrc)
            3'b000: imm = {{20{inst[31]}}, inst[31:20]};                                     // I
            3'b001: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};                          // S
            3'b010: imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}; // B
            3'b011: imm = {inst[31:12], 12'b0};                                               // U
            3'b100: imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}; // J
            default: imm = 32'b0;
        endcase
    end
endmodule
