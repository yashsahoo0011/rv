`timescale 1ns/1ps

// ctrl: 2'b00 = AND, 2'b01 = OR, 2'b10 = XOR
module alulogic(a, b, ctrl, outp);
    input  [31:0] a, b;
    input  [1:0]  ctrl;
    output [31:0] outp;

    reg [31:0] outp_r;
    assign outp = outp_r;

    always @(*) begin
        case (ctrl)
            2'b00: outp_r = a & b;
            2'b01: outp_r = a | b;
            2'b10: outp_r = a ^ b;
            default: outp_r = a & b;
        endcase
    end
endmodule
