`ifndef __CSR_SV
`define __CSR_SV
module csr
	import common::*;(
	input logic[63:0] imem_a,
	input logic clk, reset,
	input csr_addr_t ra,
	output word_t rd,
	input u1 stall,
	input u1 valid,
	input csr_addr_t wa,
	input word_t wd,
	input u1 is_mret
);
	csr_regs_t regs, regs_nxt;

	always_ff @(posedge clk) begin
		if (reset) begin
			regs <= '0;
			regs.mcause[1] <= 1'b1;
			regs.mepc[31] <= 1'b1;
		end else if(stall) begin
			
		end
		else begin
			regs <= regs_nxt;
		end
	end
	always_comb begin
		rd = '0;
		unique case(ra)
			CSR_MIE: rd = regs.mie;
			CSR_MIP: rd = regs.mip;
			CSR_MTVEC: rd = regs.mtvec;
			CSR_MSTATUS: rd = regs.mstatus;
			CSR_MSCRATCH: rd = regs.mscratch;
			CSR_MEPC: rd = regs.mepc;
			CSR_MCAUSE: rd = regs.mcause;
			CSR_MCYCLE: rd = regs.mcycle;
			CSR_MTVAL: rd = regs.mtval;
			CSR_SATP:rd = regs.satp;
			default: begin
				rd = '0;
			end
		endcase
	end

	always_comb begin
		regs_nxt = regs;
		regs_nxt.mcycle = regs.mcycle + 1;
		if (valid) begin
			unique case(wa)
				CSR_MIE: regs_nxt.mie = wd;
				CSR_MIP:  regs_nxt.mip = wd;
				CSR_MTVEC: regs_nxt.mtvec = wd;
				CSR_MSTATUS: regs_nxt.mstatus = wd;
				CSR_MSCRATCH: regs_nxt.mscratch = wd;
				CSR_MEPC: regs_nxt.mepc = wd;
				CSR_MCAUSE: regs_nxt.mcause = wd;
				CSR_MCYCLE: regs_nxt.mcycle = wd;
				CSR_MTVAL: regs_nxt.mtval = wd;
				CSR_SATP: regs_nxt.satp = wd;
				default: begin
				end
			endcase
			regs_nxt.mstatus.sd = regs_nxt.mstatus.fs != 0;
		end else if (is_mret & wa!=12'b0  & wa != 12'h120) begin
			regs_nxt.mstatus.mie = regs_nxt.mstatus.mpie;
			regs_nxt.mstatus.mpie = 1'b1;
			regs_nxt.mstatus.mpp = 2'b0;
			regs_nxt.mstatus.xs = 0;
		end else if(is_mret & wa==12'b0)begin
			regs_nxt.mstatus.mie = 0;
			regs_nxt.mstatus.mpie = 1;
			regs_nxt.mcause = 8;
			regs_nxt.mepc = imem_a;
		end
		else begin end
		
	end
	
	
endmodule

`endif