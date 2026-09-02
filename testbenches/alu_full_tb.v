`timescale 1ns/1ps
module alu_full_tb;
  reg [31:0] a, b;
  reg [1:0] aluop;
  reg [2:0] funct3;
  reg funct7b5;
  wire [3:0] ctrl;
  wire [31:0] res;
  wire zero;
  integer errors = 0;

  alu_ctrl ac(aluop, funct3, funct7b5, ctrl);
  rv32ialu alu(a, b, ctrl, zero, res);

  task check(input [255:0] name, input [31:0] expected);
    begin
      #1;
      if (res !== expected) begin
        $display("FAIL %0s: expected %d (0x%h) got %d (0x%h)", name, expected, expected, res, res);
        errors = errors + 1;
      end else begin
        $display("PASS %0s: %d", name, res);
      end
    end
  endtask

  initial begin
    // R-type: ADD  10 + 5 = 15
    a=10; b=5; aluop=2'b01; funct3=3'b000; funct7b5=0; check("ADD", 15);
    // R-type: SUB  10 - 5 = 5
    a=10; b=5; aluop=2'b01; funct3=3'b000; funct7b5=1; check("SUB", 5);
    // R-type: SLL 1 << 4 = 16
    a=1; b=4; aluop=2'b01; funct3=3'b001; funct7b5=0; check("SLL", 16);
    // R-type: SLT  -1 < 1 => 1
    a=32'hFFFFFFFF; b=1; aluop=2'b01; funct3=3'b010; funct7b5=0; check("SLT(-1<1)", 1);
    // R-type: SLTU -1(as unsigned huge) < 1 => 0
    a=32'hFFFFFFFF; b=1; aluop=2'b01; funct3=3'b011; funct7b5=0; check("SLTU", 0);
    // R-type: XOR
    a=32'hFF00FF00; b=32'h0F0F0F0F; aluop=2'b01; funct3=3'b100; funct7b5=0; check("XOR", 32'hF00FF00F);
    // R-type: SRL  0x80000000 >> 1 = 0x40000000
    a=32'h80000000; b=1; aluop=2'b01; funct3=3'b101; funct7b5=0; check("SRL", 32'h40000000);
    // R-type: SRA  0x80000000 >>> 1 = 0xC0000000
    a=32'h80000000; b=1; aluop=2'b01; funct3=3'b101; funct7b5=1; check("SRA", 32'hC0000000);
    // R-type: OR
    a=32'h0F0F0F0F; b=32'hF0F0F0F0; aluop=2'b01; funct3=3'b110; funct7b5=0; check("OR", 32'hFFFFFFFF);
    // R-type: AND
    a=32'hFF00FF00; b=32'h0FF00FF0; aluop=2'b01; funct3=3'b111; funct7b5=0; check("AND", 32'h0F000F00);
    // I-type: ADDI, funct7b5 bit is part of immediate (should be ignored -> still ADD)
    a=10; b=32'hFFFFFFFF; aluop=2'b10; funct3=3'b000; funct7b5=1; check("ADDI (imm bit set, still add)", 9);
    // I-type: SRAI with funct7b5=1
    a=32'h80000000; b=4; aluop=2'b10; funct3=3'b101; funct7b5=1; check("SRAI", 32'hF8000000);
    // Load/store address calc: ADD forced regardless of funct3/funct7
    a=100; b=8; aluop=2'b00; funct3=3'b111; funct7b5=1; check("ADD (mem addr)", 108);

    if (errors == 0) $display("ALL ALU TESTS PASSED");
    else $display("%0d ALU TESTS FAILED", errors);
    $finish;
  end
endmodule
