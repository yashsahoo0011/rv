`timescale 1ns/1ps
module regfile_quick_tb;
  reg clk=0, reset, we;
  reg [4:0] rs1, rs2, rd;
  reg [31:0] wd;
  wire [31:0] r1, r2;

  regfile uut(clk, reset, we, rs1, rs2, rd, wd, r1, r2);

  always #5 clk = ~clk;

  initial begin
    reset = 1; we = 0; rs1=0; rs2=0; rd=0; wd=0;
    @(posedge clk);
    reset = 0;
    // write x5 = 123
    @(negedge clk); rd = 5; wd = 123; we = 1;
    @(posedge clk);
    @(negedge clk); we = 0; rs1 = 5;
    #1;
    if (r1 !== 123) $display("FAIL: expected 123 got %d", r1);
    else $display("PASS: x5 read back as %d", r1);
    // write x0 should stay 0
    @(negedge clk); rd = 0; wd = 999; we = 1;
    @(posedge clk);
    @(negedge clk); we = 0; rs1 = 0;
    #1;
    if (r1 !== 0) $display("FAIL: x0 should be 0, got %d", r1);
    else $display("PASS: x0 stays 0");
    $finish;
  end
endmodule
