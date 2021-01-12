`ifndef DEF_V
`define DEF_V

`define INTERNAL_BITS 32
//----------------------instruction field------------------------
`define OPCODE 31:26
//RTYPE

`define REGISTER_BITS 5
`define RTYPE_RS 25:21
`define RTYPE_RT 20:16
`define RTYPE_RD 15:11
`define RTYPE_SHAMT 10:6
`define RTYPE_FUNC 5:0
//JTYPE
`define JTYPE_CONST 25:0
//ITYPE
`define ITYPE_RS 25:21
`define ITYPE_RT 20:16
`define ITYPE_IMM 15:0
//-------------------------OPCODE---------------------------------
`define RTYPE 6'b000_000
`define LW 6'b100_011
`define SW 6'b101_011
`define BEQ 6'b000_100
`define JMP 6'b000_010
//----------------------Special instruction-----------------------
`define NOP 32'h0000_0000
`define SYSCALL 32'h0000_000c

`define PC_BITS 32
`define OPCODE_BITS 6
`define FUNCTIONCODE_BITS 6
`define ALUOP_BITS 2
`define ALUCONTROL_BITS 4

`endif
