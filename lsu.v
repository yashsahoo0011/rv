`timescale 1ns/1ps

// funct3 for loads/stores: 000=byte,001=half,010=word,100=byte unsigned,101=half unsigned
module store_align(
    input      [1:0]  addr_lsb,
    input      [2:0]  funct3,
    input      [31:0] rs2_data,
    output reg [3:0]  wstrb,
    output reg [31:0] wdata
);
    always @(*) begin
        wstrb = 4'b0000;
        wdata = rs2_data;
        case (funct3[1:0])
            2'b00: begin // SB
                wdata = {4{rs2_data[7:0]}};
                wstrb = 4'b0001 << addr_lsb;
            end
            2'b01: begin // SH
                wdata = {2{rs2_data[15:0]}};
                wstrb = 4'b0011 << addr_lsb;
            end
            2'b10: begin // SW
                wdata = rs2_data;
                wstrb = 4'b1111;
            end
            default: begin
                wdata = rs2_data;
                wstrb = 4'b0000;
            end
        endcase
    end
endmodule

module load_extend(
    input      [1:0]  addr_lsb,
    input      [2:0]  funct3,
    input      [31:0] mem_rdata,
    output reg [31:0] load_data
);
    reg [7:0]  byte_sel;
    reg [15:0] half_sel;

    always @(*) begin
        byte_sel = mem_rdata[8*addr_lsb +: 8];
        half_sel = mem_rdata[16*addr_lsb[1] +: 16];

        case (funct3)
            3'b000:  load_data = {{24{byte_sel[7]}}, byte_sel};   // LB
            3'b001:  load_data = {{16{half_sel[15]}}, half_sel};  // LH
            3'b010:  load_data = mem_rdata;                        // LW
            3'b100:  load_data = {24'b0, byte_sel};                // LBU
            3'b101:  load_data = {16'b0, half_sel};                // LHU
            default: load_data = mem_rdata;
        endcase
    end
endmodule
