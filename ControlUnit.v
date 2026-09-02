`timescale 1ns/1ps

// Main (instruction) decoder. Combinational, driven purely by opcode.
// This runs in the Decode stage; the resulting control bundle is what
// gets latched into the ID/EX pipeline register.
//
// Design notes on how the datapath reuses the shared ALU for address/
// target computation:
//   - ALUSrcA : 0 = rs1, 1 = PC          (operand A into the ALU)
//   - ALUSrc  : 0 = rs2, 1 = ImmExt      (operand B into the ALU)
//   - ALUOp   : passed to alu_ctrl.v to pick the exact ALU operation
//   For loads/stores/JALR:      ALUSrcA=rs1, ALUSrc=imm, ALUOp=ADD -> effective address / target
//   For JAL/AUIPC/branches:     ALUSrcA=PC,  ALUSrc=imm, ALUOp=ADD -> PC + imm (target or AUIPC result)
//   For R-type:                 ALUSrcA=rs1, ALUSrc=rs2, ALUOp=funct-decoded
//   For I-type ALU-imm:         ALUSrcA=rs1, ALUSrc=imm, ALUOp=funct-decoded
// Branch condition (taken/not) is NOT computed by the shared ALU; it's
// computed by a dedicated comparator (branch_comp.v) fed rs1/rs2
// directly, so the ALU is free to compute the branch target in the
// same cycle.
//
// ResultSrc (selects what gets written back to rd):
//   00 = ALU result   01 = memory read data   10 = PC + 4   11 = ImmExt (LUI)

module ControlUnit(
    input      [6:0] opcode,
    output reg       RegWrite,
    output reg [2:0] ImmSrc,
    output reg       ALUSrcA,     // 0 = rs1, 1 = PC
    output reg       ALUSrc,      // 0 = rs2, 1 = imm
    output reg       MemWrite,
    output reg       MemRead,
    output reg [1:0] ResultSrc,
    output reg       Branch,
    output reg       Jump,
    output reg [1:0] ALUOp
);
    localparam OP_R      = 7'b0110011;
    localparam OP_IMM    = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_JALR   = 7'b1100111;
    localparam OP_LUI    = 7'b0110111;
    localparam OP_AUIPC  = 7'b0010111;

    always @(*) begin
        // safe defaults (NOP-like) for unrecognized opcodes
        RegWrite  = 1'b0;
        ImmSrc    = 3'b000;
        ALUSrcA   = 1'b0;
        ALUSrc    = 1'b0;
        MemWrite  = 1'b0;
        MemRead   = 1'b0;
        ResultSrc = 2'b00;
        Branch    = 1'b0;
        Jump      = 1'b0;
        ALUOp     = 2'b00;

        case (opcode)
            OP_R: begin
                RegWrite  = 1'b1;
                ALUSrcA   = 1'b0;
                ALUSrc    = 1'b0;
                ResultSrc = 2'b00;
                ALUOp     = 2'b01;
            end
            OP_IMM: begin
                RegWrite  = 1'b1;
                ImmSrc    = 3'b000;
                ALUSrcA   = 1'b0;
                ALUSrc    = 1'b1;
                ResultSrc = 2'b00;
                ALUOp     = 2'b10;
            end
            OP_LOAD: begin
                RegWrite  = 1'b1;
                ImmSrc    = 3'b000;
                ALUSrcA   = 1'b0;
                ALUSrc    = 1'b1;
                MemRead   = 1'b1;
                ResultSrc = 2'b01;
                ALUOp     = 2'b00;
            end
            OP_STORE: begin
                ImmSrc    = 3'b001;
                ALUSrcA   = 1'b0;
                ALUSrc    = 1'b1;
                MemWrite  = 1'b1;
                ALUOp     = 2'b00;
            end
            OP_BRANCH: begin
                ImmSrc    = 3'b010;
                ALUSrcA   = 1'b1;   // PC
                ALUSrc    = 1'b1;   // imm
                Branch    = 1'b1;
                ALUOp     = 2'b00;  // ALU computes PC+imm (branch target)
            end
            OP_JAL: begin
                RegWrite  = 1'b1;
                ImmSrc    = 3'b100;
                ALUSrcA   = 1'b1;   // PC
                ALUSrc    = 1'b1;   // imm
                ResultSrc = 2'b10;  // PC+4
                Jump      = 1'b1;
                ALUOp     = 2'b00;  // ALU computes PC+imm (jump target)
            end
            OP_JALR: begin
                RegWrite  = 1'b1;
                ImmSrc    = 3'b000;
                ALUSrcA   = 1'b0;   // rs1
                ALUSrc    = 1'b1;   // imm
                ResultSrc = 2'b10;  // PC+4
                Jump      = 1'b1;
                ALUOp     = 2'b00;  // ALU computes rs1+imm (jump target)
            end
            OP_LUI: begin
                RegWrite  = 1'b1;
                ImmSrc    = 3'b011;
                ResultSrc = 2'b11;  // ImmExt passthrough
            end
            OP_AUIPC: begin
                RegWrite  = 1'b1;
                ImmSrc    = 3'b011;
                ALUSrcA   = 1'b1;   // PC
                ALUSrc    = 1'b1;   // imm
                ResultSrc = 2'b00;  // ALU result = PC+imm
                ALUOp     = 2'b00;
            end
            default: ; // NOP / unsupported (FENCE, ECALL, EBREAK, CSR...)
        endcase
    end
endmodule
