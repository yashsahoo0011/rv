`timescale 1ns/1ps

// Word-addressed instruction memory. Asynchronous read so the Fetch
// stage sees the instruction combinationally within the same cycle.
module imem #(
    parameter ADDR_WIDTH = 10,   // 2^10 words = 4096 instructions
    parameter INIT_FILE  = ""
)(
    input      [31:0] pc,
    output     [31:0] inst
);
    reg [31:0] mem [0:(1<<ADDR_WIDTH)-1];

    integer i;
    initial begin
        for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1)
            mem[i] = 32'h00000013; // ADDI x0,x0,0 (NOP) by default
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
    end

    assign inst = mem[pc[ADDR_WIDTH+1:2]];
endmodule
