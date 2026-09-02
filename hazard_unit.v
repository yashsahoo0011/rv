`timescale 1ns/1ps

module hazard_unit(
    input        id_ex_memread,
    input  [4:0] id_ex_rd,
    input  [4:0] if_id_rs1,
    input  [4:0] if_id_rs2,
    input        pc_src,        // branch taken or jump resolved in EX

    output       stall_pc,
    output       stall_if_id,
    output       flush_if_id,
    output       flush_id_ex
);
    wire load_use_hazard = id_ex_memread && (id_ex_rd != 5'b0) &&
                            ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2));

    assign stall_pc    = load_use_hazard;
    assign stall_if_id = load_use_hazard;
    assign flush_if_id = pc_src;               // squash wrong-path fetch
    assign flush_id_ex = load_use_hazard || pc_src;
endmodule
