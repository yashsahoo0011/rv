`timescale 1ns/1ps

// 5-stage pipelined RV32I core (base integer ISA, minus FENCE/ECALL/
// EBREAK/CSR). Branches and jumps resolve in EX (2-cycle misprediction
// penalty); load-use hazards stall 1 cycle; all other RAW hazards are
// resolved by forwarding.
module rv32i_pipeline_top #(
    parameter IMEM_ADDR_WIDTH = 10,
    parameter DMEM_ADDR_WIDTH = 10,
    parameter INIT_FILE       = ""
)(
    input clk,
    input reset
);

    // ---------------------------------------------------------------
    // IF stage
    // ---------------------------------------------------------------
    wire        stall_pc, stall_if_id, flush_if_id, flush_id_ex;
    wire        pc_src;
    wire [31:0] pc_target;

    wire [31:0] pc_current, pc_plus4, next_pc;
    wire [31:0] inst_fetch;

    assign next_pc = pc_src ? pc_target : pc_plus4;

    reg32 pc_reg(
        .clk(clk), .reset(reset),
        .we(~stall_pc),
        .d(next_pc),
        .q(pc_current)
    );

    PCInc pc_inc(.pc(pc_current), .pc_plus4(pc_plus4));

    imem #(.ADDR_WIDTH(IMEM_ADDR_WIDTH), .INIT_FILE(INIT_FILE)) imem_inst(
        .pc(pc_current), .inst(inst_fetch)
    );

    wire [31:0] if_id_pc, if_id_pcplus4, if_id_inst;

    if_id_reg IFID(
        .clk(clk), .reset(reset),
        .stall(stall_if_id), .flush(flush_if_id),
        .pc_in(pc_current), .pcplus4_in(pc_plus4), .inst_in(inst_fetch),
        .pc_out(if_id_pc), .pcplus4_out(if_id_pcplus4), .inst_out(if_id_inst)
    );

    // ---------------------------------------------------------------
    // ID stage
    // ---------------------------------------------------------------
    wire [6:0] id_opcode  = if_id_inst[6:0];
    wire [4:0] id_rd      = if_id_inst[11:7];
    wire [2:0] id_funct3  = if_id_inst[14:12];
    wire [4:0] id_rs1     = if_id_inst[19:15];
    wire [4:0] id_rs2     = if_id_inst[24:20];
    wire       id_funct7b5 = if_id_inst[30];

    wire        c_regwrite, c_alusrcA, c_alusrc, c_memwrite, c_memread, c_branch, c_jump;
    wire [2:0]  c_immsrc;
    wire [1:0]  c_resultsrc, c_aluop;

    ControlUnit ctrl(
        .opcode(id_opcode),
        .RegWrite(c_regwrite), .ImmSrc(c_immsrc),
        .ALUSrcA(c_alusrcA), .ALUSrc(c_alusrc),
        .MemWrite(c_memwrite), .MemRead(c_memread),
        .ResultSrc(c_resultsrc), .Branch(c_branch), .Jump(c_jump),
        .ALUOp(c_aluop)
    );

    wire [31:0] id_imm;
    immgen immgen_inst(.inst(if_id_inst), .immsrc(c_immsrc), .imm(id_imm));

    wire [3:0] id_aluctrl;
    alu_ctrl aluctrl_inst(
        .aluop(c_aluop), .funct3(id_funct3), .funct7b5(id_funct7b5),
        .alu_ctrl(id_aluctrl)
    );

    // WB-stage writeback bus (declared here, driven near the bottom)
    wire [31:0] wb_data;
    wire [4:0]  wb_rd;
    wire        wb_regwrite;

    wire [31:0] id_r1, id_r2;
    regfile rf(
        .clk(clk), .reset(reset),
        .we(wb_regwrite),
        .rs1(id_rs1), .rs2(id_rs2), .rd(wb_rd), .wd(wb_data),
        .r1(id_r1), .r2(id_r2)
    );

    // ---------------------------------------------------------------
    // Hazard detection (uses ID/EX's MemRead+rd, declared after latch below)
    // ---------------------------------------------------------------
    wire ex_memread;
    wire [4:0] ex_rd_for_hazard;

    hazard_unit hz(
        .id_ex_memread(ex_memread),
        .id_ex_rd(ex_rd_for_hazard),
        .if_id_rs1(id_rs1),
        .if_id_rs2(id_rs2),
        .pc_src(pc_src),
        .stall_pc(stall_pc),
        .stall_if_id(stall_if_id),
        .flush_if_id(flush_if_id),
        .flush_id_ex(flush_id_ex)
    );

    // ---------------------------------------------------------------
    // ID/EX pipeline register
    // ---------------------------------------------------------------
    wire [31:0] ex_pc, ex_pcplus4, ex_rs1data, ex_rs2data, ex_imm;
    wire [4:0]  ex_rs1, ex_rs2, ex_rd;
    wire [2:0]  ex_funct3;
    wire        ex_alusrcA, ex_alusrc;
    wire [3:0]  ex_aluctrl;
    wire        ex_regwrite;
    wire [1:0]  ex_resultsrc;
    wire        ex_memwrite;
    wire        ex_branch, ex_jump;

    id_ex_reg IDEX(
        .clk(clk), .reset(reset), .flush(flush_id_ex),
        .pc_in(if_id_pc), .pcplus4_in(if_id_pcplus4),
        .rs1data_in(id_r1), .rs2data_in(id_r2), .imm_in(id_imm),
        .rs1_in(id_rs1), .rs2_in(id_rs2), .rd_in(id_rd),
        .funct3_in(id_funct3),
        .alusrca_in(c_alusrcA), .alusrc_in(c_alusrc), .aluctrl_in(id_aluctrl),
        .regwrite_in(c_regwrite), .resultsrc_in(c_resultsrc),
        .memwrite_in(c_memwrite), .memread_in(c_memread),
        .branch_in(c_branch), .jump_in(c_jump),

        .pc_out(ex_pc), .pcplus4_out(ex_pcplus4),
        .rs1data_out(ex_rs1data), .rs2data_out(ex_rs2data), .imm_out(ex_imm),
        .rs1_out(ex_rs1), .rs2_out(ex_rs2), .rd_out(ex_rd),
        .funct3_out(ex_funct3),
        .alusrca_out(ex_alusrcA), .alusrc_out(ex_alusrc), .aluctrl_out(ex_aluctrl),
        .regwrite_out(ex_regwrite), .resultsrc_out(ex_resultsrc),
        .memwrite_out(ex_memwrite), .memread_out(ex_memread),
        .branch_out(ex_branch), .jump_out(ex_jump)
    );

    assign ex_rd_for_hazard = ex_rd;

    // ---------------------------------------------------------------
    // EX stage
    // ---------------------------------------------------------------
    wire [4:0] mem_rd_for_fwd, wbstage_rd_for_fwd;
    wire       mem_regwrite_for_fwd, wbstage_regwrite_for_fwd;
    wire [1:0] forwardA, forwardB;

    forward_unit fwd(
        .id_ex_rs1(ex_rs1), .id_ex_rs2(ex_rs2),
        .ex_mem_rd(mem_rd_for_fwd), .mem_wb_rd(wbstage_rd_for_fwd),
        .ex_mem_regwrite(mem_regwrite_for_fwd), .mem_wb_regwrite(wbstage_regwrite_for_fwd),
        .forwardA(forwardA), .forwardB(forwardB)
    );

    wire [31:0] mem_aluresult_for_fwd; // EX/MEM.aluresult, declared here for the mux below

    wire [31:0] fwd_rs1 = (forwardA == 2'b10) ? mem_aluresult_for_fwd :
                           (forwardA == 2'b01) ? wb_data :
                                                  ex_rs1data;
    wire [31:0] fwd_rs2 = (forwardB == 2'b10) ? mem_aluresult_for_fwd :
                           (forwardB == 2'b01) ? wb_data :
                                                  ex_rs2data;

    wire [31:0] alu_srcA = ex_alusrcA ? ex_pc  : fwd_rs1;
    wire [31:0] alu_srcB = ex_alusrc  ? ex_imm : fwd_rs2;

    wire [31:0] alu_result;
    wire        alu_zero;
    rv32ialu alu(.a(alu_srcA), .b(alu_srcB), .alu_ctrl(ex_aluctrl), .zero(alu_zero), .res(alu_result));

    wire branch_taken;
    branch_comp bcmp(.rs1(fwd_rs1), .rs2(fwd_rs2), .funct3(ex_funct3), .taken(branch_taken));

    assign pc_src    = ex_jump | (ex_branch & branch_taken);
    assign pc_target = alu_result; // ALU computed PC+imm or rs1+imm this cycle

    // ---------------------------------------------------------------
    // EX/MEM pipeline register
    // ---------------------------------------------------------------
    wire [31:0] mem_aluresult, mem_writedata, mem_pcplus4, mem_imm;
    wire [4:0]  mem_rd;
    wire [2:0]  mem_funct3;
    wire        mem_regwrite;
    wire [1:0]  mem_resultsrc;
    wire        mem_memwrite;

    ex_mem_reg EXMEM(
        .clk(clk), .reset(reset),
        .aluresult_in(alu_result), .writedata_in(fwd_rs2),
        .pcplus4_in(ex_pcplus4), .imm_in(ex_imm), .rd_in(ex_rd),
        .funct3_in(ex_funct3),
        .regwrite_in(ex_regwrite), .resultsrc_in(ex_resultsrc), .memwrite_in(ex_memwrite),

        .aluresult_out(mem_aluresult), .writedata_out(mem_writedata),
        .pcplus4_out(mem_pcplus4), .imm_out(mem_imm), .rd_out(mem_rd),
        .funct3_out(mem_funct3),
        .regwrite_out(mem_regwrite), .resultsrc_out(mem_resultsrc), .memwrite_out(mem_memwrite)
    );

    assign mem_aluresult_for_fwd = mem_aluresult;
    assign mem_rd_for_fwd        = mem_rd;
    assign mem_regwrite_for_fwd  = mem_regwrite;

    // ---------------------------------------------------------------
    // MEM stage
    // ---------------------------------------------------------------
    wire [3:0]  st_wstrb;
    wire [31:0] st_wdata;
    store_align stalign(
        .addr_lsb(mem_aluresult[1:0]), .funct3(mem_funct3), .rs2_data(mem_writedata),
        .wstrb(st_wstrb), .wdata(st_wdata)
    );

    wire [31:0] dmem_rdata;
    BankedMEM #(.ADDR_WIDTH(DMEM_ADDR_WIDTH)) dmem(
        .clk(clk), .addr(mem_aluresult), .wdata(st_wdata),
        .wstrb(mem_memwrite ? st_wstrb : 4'b0000),
        .rdata(dmem_rdata)
    );

    wire [31:0] mem_loaddata;
    load_extend ldext(
        .addr_lsb(mem_aluresult[1:0]), .funct3(mem_funct3), .mem_rdata(dmem_rdata),
        .load_data(mem_loaddata)
    );

    // ---------------------------------------------------------------
    // MEM/WB pipeline register
    // ---------------------------------------------------------------
    wire [31:0] wb_aluresult, wb_memdata, wb_pcplus4, wb_imm;

    mem_wb_reg MEMWB(
        .clk(clk), .reset(reset),
        .aluresult_in(mem_aluresult), .memdata_in(mem_loaddata),
        .pcplus4_in(mem_pcplus4), .imm_in(mem_imm), .rd_in(mem_rd),
        .regwrite_in(mem_regwrite), .resultsrc_in(mem_resultsrc),

        .aluresult_out(wb_aluresult), .memdata_out(wb_memdata),
        .pcplus4_out(wb_pcplus4), .imm_out(wb_imm), .rd_out(wb_rd),
        .regwrite_out(wb_regwrite), .resultsrc_out(c_wb_resultsrc)
    );

    // ---------------------------------------------------------------
    // WB stage
    // ---------------------------------------------------------------
    wire [1:0] c_wb_resultsrc;
    reg [31:0] wb_data_r;
    assign wb_data = wb_data_r;

    always @(*) begin
        case (c_wb_resultsrc)
            2'b00:   wb_data_r = wb_aluresult;
            2'b01:   wb_data_r = wb_memdata;
            2'b10:   wb_data_r = wb_pcplus4;
            2'b11:   wb_data_r = wb_imm;
            default: wb_data_r = wb_aluresult;
        endcase
    end

    assign wbstage_rd_for_fwd       = wb_rd;
    assign wbstage_regwrite_for_fwd = wb_regwrite;

endmodule
