`ifndef DECODE_PKG_SV
`define DECODE_PKG_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif



package sign_pkg;
	import common::*;
	
	typedef struct packed {
		logic jump;
		
		logic MemRead;
		logic [3:0] WhichtoReg;
		logic MemWrite;
		logic ALUSrc1;
		logic ALUSrc2;
		logic RegWrite;
		logic [4:0] ALUctl;
		logic [2:0] b;
		logic [4:0]Rs1;
		logic [4:0]Rs2;
		logic [4:0]Rd;
	} decoder_hazard_sign;

	
	typedef struct packed {
	    u32 instr;
		u64 imme;
		logic [63:0] pc;
		logic jump;
		logic MemRead;
		logic [3:0] WhichtoReg;
		logic MemWrite;
		logic ALUSrc1;
		logic ALUSrc2;
		logic RegWrite;
		logic [4:0] ALUctl;
		logic [2:0] b;
		logic [2:0] size;
		logic word;
		logic div_start;
		logic div_sign;
		logic mul_start;
		logic unsignedLoad;
		logic [4:0]Rs1;
		logic [4:0]Rs2;
		logic [4:0]Rd;
	} decoder_output_sign;
	

	typedef struct packed {
		logic [63:0] pc;
		logic [31:0] instr;
	} fetch_input_sign;

	typedef struct packed {
		logic [31:0] instr;
		logic [63:0] pc;
	} fetch_output_sign;


	typedef struct packed {
		decoder_output_sign decoder_sign;
	} excute_input_sign;

	typedef struct packed {
		decoder_output_sign decoder_sign;
		logic [63:0] result;//选择后的准确结果
		logic bboolean;//b类型的跳�?
		u64 a_reg,b_reg;
	} excute_output_sign;

	typedef struct packed {
		excute_output_sign excute_sign;
	} memory_input_sign;

	typedef struct packed {
		decoder_output_sign decoder_sign;
		logic [63:0] result;//ALU计算结果
		logic  [63:0] dbusdata;//经过处理的读取数�?
		u64 addr;
		strobe_t strobe;
		u1 valid;
	} memory_output_sign;

	

	typedef struct packed {
		memory_output_sign memory_sign;
	} writeback_intput_sign;

	typedef struct packed {
		decoder_output_sign decoder_sign;
		u64 result;
		logic skip;
	} writeback_output_sign;
	typedef struct packed {
		fetch_output_sign	fetch_sign;
	} decoder_input_sign;

	typedef struct packed {
		u1 sd;
		logic [MXLEN-2-36:0] wpri1;
		u2 sxl;
		u2 uxl;
		u9 wpri2;
		u1 tsr;
		u1 tw;
		u1 tvm;
		u1 mxr;
		u1 sum;
		u1 mprv;
		u2 xs;
		u2 fs;
		u2 mpp;
		u2 wpri3;
		u1 spp;
		u1 mpie;
		u1 wpri4;
		u1 spie;
		u1 upie;
		u1 mie;
		u1 wpri5;
		u1 sie;
		u1 uie;
	} mstatus_t;


	typedef struct packed {
		u4 mode;
		u16 asid;
		u44 ppn;
	} satp_t;
	
	

	typedef struct packed {
		u64
		mhartid, // Hardware thread Id, read-only as 0 in this work
		mie,	 // Machine interrupt-enable register
		mip,	 // Machine interrupt pending
		mtvec;	 // Machine trap-handler base address
		mstatus_t
		mstatus; // Machine status register
		u64
		mscratch, // Scratch register for machine trap handlers
		mepc,	 // Machine exception program counter
		satp,	 // Supervisor address translation and protection, read-only as 0 in this work
		mcause,  // Machine trap cause
		mcycle,  // Counter
		mtval;
	} csr_regs_t;
endpackage
`endif