`timescale 1ns/1ps

// Evaluates whether a branch is taken. funct3 encodes the branch type
// per the RISC-V spec: BEQ=000, BNE=001, BLT=100, BGE=101, BLTU=110,
// BGEU=111. Kept separate from the shared ALU so the ALU is free to
// compute the branch target (PC + imm) in the same cycle.
module branch_comp(
    input      [31:0] rs1,
    input      [31:0] rs2,
    input      [2:0]  funct3,
    output reg        taken
);
    always @(*) begin
        case (funct3)
            3'b000:  taken = (rs1 == rs2);                    // BEQ
            3'b001:  taken = (rs1 != rs2);                    // BNE
            3'b100:  taken = ($signed(rs1) <  $signed(rs2));  // BLT
            3'b101:  taken = ($signed(rs1) >= $signed(rs2));  // BGE
            3'b110:  taken = (rs1 <  rs2);                    // BLTU
            3'b111:  taken = (rs1 >= rs2);                    // BGEU
            default: taken = 1'b0;
        endcase
    end
endmodule
