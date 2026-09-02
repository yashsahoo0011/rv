`timescale 1ns/1ps

module alu_whole_tb;

  reg [31:0] a,b;
  reg [2:0] alu_ctrl;
	
  wire zero;
  wire [31:0] res;
  
  rv32ialu uut(a,b,alu_ctrl,zero,res);
  
  initial begin
    $dumpfile("task3");
    $dumpvars(0,alu_whole_tb);
  end
  
  initial begin
    $monitor($time, "A = %d, B=%d, Control = %b, zero = %b, Result = %d",a,b,alu_ctrl,zero,res);
    
    a = 5;
    b = 4;
    alu_ctrl = 001;
    #10;
    
    a = 5;
    b = 5;
    alu_ctrl = 000;
    #10;
    
    $finish;
  end
endmodule
    

  