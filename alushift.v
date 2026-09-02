`timescale 1ns/1ps

// ctrl: 2'b00 = SLL, 2'b01 = SRL, 2'b10 = SRA
module alushift(outp, inp, b, ctrl);
    input  [31:0] inp;
    input  [4:0]  b;
    input  [1:0]  ctrl;
    output [31:0] outp;

    reg signed [31:0] outp_r;
    assign outp = outp_r;

    always @(*) begin
        case (ctrl)
            2'b00: outp_r = inp << b;
            2'b01: outp_r = inp >> b;
            2'b10: outp_r = $signed(inp) >>> b;
            default: outp_r = inp << b;
        endcase
    end
endmodule
