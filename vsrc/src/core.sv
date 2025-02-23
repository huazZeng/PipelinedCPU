`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`endif
module core import common::*;(
	input  logic       clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
	input  logic       trint, swint, exint
);
	/* TODO: Add your CPU-Core here. */
 /* verilator lint_off MULTIDRIVEN */
logic [63:0] imem_a;
logic [31:0] instr;
logic [63:0] a_in;
logic [63:0] b_in;
logic [63:0] Rd_data1;
logic [63:0] Rd_data2;
logic [63:0] imme;
logic [6:0] opcode;
logic [6:0] func7;
logic [2:0] func3;
logic [4:0]Rs1;
logic [4:0]Rs2;
logic [4:0]Rd;
logic [4:0]ALUctl;
logic [63:0] result;
logic [3:0] WhichtoReg;
logic ALUSrc1;
logic ALUSrc2;
logic RegWrite;
logic MemWrite;
logic [7:0]strobe;
logic jump;
logic MemRead;
logic [63:0] Wr_data;
logic bboolean;
logic [2:0]b;
logic stallDM;

logic flag	;
logic [63:0]lastpc,lastpc1;
logic [63:0]W_result;
logic [2:0] size;
logic drq;
logic flag1;

logic athematic;
logic irequst;
logic drequst;
logic word;//用于标注是否结果�?要先截断32位再做符号拓�?
//DIVIDER
logic _div_start;
logic div_start, divider_is_signed;
logic signed [63:0] quotient, remainder;
logic div_done;
logic stall_Divider;
logic mul_start;
logic _mul_start;
 logic stall_Mul;
logic signed [63:0] mul_result;
logic signed [63:0] mul_result32;
logic mul_ok;
logic unsignedLoad;
logic [63:0] dbusdata;
logic WhichtoCSR;
logic [1:0]Csr_op;
logic csrWrite;
logic [63:0] zimm;
logic [11:0] csr_id;
logic is_mret;
logic[1:0] mode;
logic [63:0] csrwritedata,csrreaddata,_csrreaddata;


msize_t msize;
u1 if_over,mem_over,excute_over,_if_over,idrequst,resetover,skip;
u64 memdata,iaddr,daddr,ddata,_Wr_data;
logic [2:0] dcount;
logic [1:0] lastmode;
assign ireq.addr=iaddr;
assign ireq.valid=irequst;
assign dreq.valid=drequst | idrequst;
decoder decoder_instance (   
    .instr(instr), 
    .Rs1(Rs1),              
    .Rs2(Rs2),               
    .Rd(Rd),                 
    .opcode(opcode),       
    .func3(func3),        
    .imme(imme),          
    .func7(func7),
	.athematic(athematic),
	.zimm(zimm),
	.csr_id(csr_id)
);  
W_op w_op(
	.a(result),
	.result(W_result)
);
readdata readdatadecoder(
	._rd(memdata),
	.rd(dbusdata),
	.addr(result[2:0]),
	.msize(msize),
	.mem_unsigned(unsignedLoad)
);
writedata writedatadecoder(
	.addr(result[2:0]),
	._wd(Rd_data2),
	.msize(msize),
	.wd(dreq.data),
	.write(MemWrite),
	.strobe(strobe)
);
csr csr_instance(
	.imem_a(imem_a),
	.clk(clk),
	.reset(reset),
	.ra(csr_id),
	.rd(csrreaddata),
	.stall(!if_over),
	.valid(csrWrite),
	.wa(csr_id),
	.wd(csrwritedata),
	.is_mret(is_mret)
	
);
alu alu_instance (  
        .a(a_in),  
        .b(b_in),  
		.word(word),
        .alucontrol(ALUctl), 
        .result(result)
    ); 
     
divider div_instance(
	.next(if_over & mem_over & excute_over &resetover),
	.clk(clk),
	.div_start(_div_start),
	.is_signed(divider_is_signed),
	.numerator(a_in),
	.denominator(b_in),
	.quotient(quotient),
	.remainder(remainder),
	.div_done(div_done),
	.reset(reset),
	.word(word)
);

Multiplier mul_instance(
	.next(if_over & mem_over & excute_over & resetover),
	.clk(clk),
	.mul_start(_mul_start),
	.a(a_in),
	.b(b_in),
	.mul_result(mul_result),
	.mul_ok(mul_ok),
	.word(word)
	);

controlUnit control_unit_instance ( 
	.athematic(athematic),
		
        .opcode(opcode),          
        .func3(func3),            
        .fun7(func7),            
        .jump(jump),         
        .MemRead(MemRead),       
        .WhichtoReg(WhichtoReg),  
        .MemWrite(MemWrite),      
        .ALUSrc1(ALUSrc1),       
        .ALUSrc2(ALUSrc2),       
        .RegWrite(RegWrite),   
        .ALUctl(ALUctl)  ,
        .b(b),
		.size(size)  ,
		.word(word),
		.div_start(div_start),
		.div_sign(divider_is_signed),
		.mul_start(mul_start),
		.unsignedLoad(unsignedLoad),
		.WhichtoCSR(WhichtoCSR),
		.Csr_op(Csr_op),
		.csrWrite(csrWrite),
		.csr_ret(is_mret)
    ); 
registers registers_instance ( 

		.stallM(!if_over |  !mem_over |  !excute_over | !resetover) ,
        .clk(clk),
		.reset(reset),                    
        .W_en(RegWrite),          
        .Rs1(Rs1),           
        .Rs2(Rs2),           
        .Rd(Rd),              
        .Wr_data(Wr_data),   
        .Rd_data1(Rd_data1), 
        .Rd_data2(Rd_data2)  
    );  
Bctrl Bctrl_ins(
.a_in(Rd_data1),
.b_in(Rd_data2),
.b(b),
.bboolean(bboolean)
);
assign Wr_data= (WhichtoReg==0)?result :
			(WhichtoReg==1)?dbusdata :
			(WhichtoReg==2)?imem_a+4  :
			(WhichtoReg==3)?imme :
			(WhichtoReg==4)?W_result :
			(WhichtoReg==5)?quotient:
			(WhichtoReg==6)?remainder: 
			(WhichtoReg==7)?mul_result:
			(WhichtoReg==8)?_csrreaddata:64'd0;

assign csrwritedata = (Csr_op==0)?Rd_data1:
					(Csr_op==1)?Rd_data1|csrreaddata:
					(Csr_op==2)?Rd_data1&csrreaddata:64'b0;


// always_comb
// begin
	
// 	if(unsignedLoad)begin
// 				case(size)
// 					3'b000:dbusdata={{56'b0},{dresp.data[7:0]}};
// 					3'b001:dbusdata={{48'b0},{dresp.data[15:0]}};
// 					3'b010:dbusdata={{32'b0},{dresp.data[31:0]}};
// 					3'b011:dbusdata={{dresp.data[63:0]}};
// 					default:dbusdata=64'b0;
// 				endcase
// 			end
// 			else begin
// 				case(size)
// 					3'b000:dbusdata={{56{dresp.data[7]}},{dresp.data[7:0]}};
// 					3'b001:dbusdata={{48{dresp.data[15]}},{dresp.data[15:0]}};
// 					3'b010:dbusdata={{32{dresp.data[31]}},{dresp.data[31:0]}};
// 					3'b011:dbusdata={{dresp.data[63:0]}};
// 					default:dbusdata=64'b0;
// 				endcase
// 			end
	
	

// end

assign a_in=(ALUSrc1)?imem_a : Rd_data1;
assign b_in=(ALUSrc2)?imme : Rd_data2;
//阻塞信号
u32 idata;
always @(posedge clk) 
begin
_if_over<=if_over;
_Wr_data<=Wr_data;
// if(trint |  swint|  exint)begin
// 	csr_instance.regs.mepc <= imem_a;
// 	csr_instance.regs.mcause[63]<=1;
// 	csr_instance.regs.mcause[62:0]<=trint?  7 : swint? 1:  exint?  11: 0;
// 	csr_instance.regs.mstatus.mpie <= csr_instance.regs.mstatus.mie;
// 	csr_instance.regs.mstatus.mie<=0;
// 	csr_instance.regs.mstatus.mpp <= mode;
// end	



if(!if_over |  !mem_over |  !excute_over)begin
	flag<=0;
end
if(iresp.data_ok) begin
	instr <= iresp.data;
	irequst<= 0;
	if_over<= 1;
	lastpc <= imem_a;
	idrequst<=0;
end
else begin
if(!if_over & dresp.data_ok)begin
	dcount <= dcount-1;
	if(dcount == 1) begin
		irequst <= 1;
		idrequst<=0;
		iaddr <=  {7'b0,dresp.data[54:10],imem_a[11:0]} ;
	end
	else begin
		idrequst<=1;
		if (dcount == 3) begin
			daddr <= {7'b0,dresp.data[54:10],12'b0}+8 * imem_a[29:21] ;
			end
		if (dcount == 2) begin
			daddr <= {7'b0,dresp.data[54:10],12'b0}+8 * imem_a[20:12] ;
		end
	end
end
if(if_over)begin
	
	drequst <= MemWrite | MemRead;
	if(MemWrite | MemRead) begin
		if(mode == 3 | csr_instance.regs.satp.mode != 4'b1000 ) begin
			dcount <= 1;
			daddr<=result;
			
		end
		else begin
			dcount <= 4;
			daddr <= {8'b0,csr_instance.regs.satp.ppn, 12'b0}+ 8 *csr_instance.regs.mepc[38:30];
		end
	end
	else begin
		dcount <= 1;
	end
	_mul_start <= mul_start;
	_div_start <= div_start;
	
	if(!_if_over)begin
		_csrreaddata <= csrreaddata;
	end
end
if(if_over & mem_over & excute_over& resetover)begin
	if_over<=0;
	mem_over<=0;
	excute_over<=0;
	resetover<=0;
	skip <= 0;
	flag<=1;
	imem_a <= (bboolean|jump)?result:
				(is_mret & csr_id != 12'b0 & csr_id != 12'h120) ? csr_instance.regs.mepc: (is_mret & csr_id == 12'b0) ?csr_instance.regs.mtvec:imem_a+4;
	
	if(mode == 3 | csr_instance.regs.satp.mode != 4'b1000 ) begin
		irequst <= 1;
		iaddr <=  (bboolean|jump)?result:
				(is_mret & csr_id != 12'b0 & csr_id != 12'h120) ? csr_instance.regs.mepc: (is_mret & csr_id == 12'b0) ?csr_instance.regs.mtvec:imem_a+4;
	end
	else begin
		idrequst <= 1;
		dcount <= 3;
		daddr <= {8'b0,csr_instance.regs.satp.ppn, 12'b0}+ 8 *csr_instance.regs.mepc[38:30];
	end
	end
if(if_over & mem_over & excute_over &	!resetover)begin
	lastmode <= mode;
	resetover<=1;
end
if(_if_over )begin
		if(is_mret & csr_id != 12'b0 & csr_id != 12'h120)begin
			if(!resetover&if_over)begin
				mode <= csr_instance.regs.mstatus.mpp;
			end
			
		end
		if(is_mret & csr_id == 12'b0 )begin
			if(!resetover&if_over)begin
				mode <= 3;
			end
		end
		if((!drequst | dresp.data_ok) & dcount == 1) begin
			mem_over <= 1;
			if(mem_over!=1) begin
				memdata <= dresp.data;
			end
			skip <= !daddr[31] & MemRead;
			drequst<=0;
		end
		if (dresp.data_ok & dcount != 1 ) begin
			drequst<=1;
			if (dcount == 4) begin
				daddr <= {7'b0,dresp.data[54:10],12'b0}+8 * imem_a[29:21] ;
				//其余接口数据更新
			end
			if (dcount == 3) begin
				daddr <= {7'b0,dresp.data[54:10],12'b0}+8 * imem_a[20:12] ;
				//其余接口数据更新
			end
			if (dcount == 2) begin
				daddr <=	{7'b0,dresp.data[54:10],imem_a[11:0]}  ;
				//其余接口数据更新
			end
			dcount<=dcount-1;
		end
		if((!_mul_start|mul_ok) &(!_div_start|div_done) )begin
			excute_over<=1;
			_mul_start<=0;
			_div_start<=0;
		end
end
if(!if_over )begin
		mem_over<=0;
		excute_over<=0;
end
if(reset)
	begin
	mode<=2'b11;
	imem_a <= PCINIT;
	iaddr <= PCINIT;
	//发�?�首个访问instr的请�?
	irequst <= 1;
	if_over <= 0;
	mem_over <= 0;
	excute_over <= 0;
	resetover<=0;
	skip <= 0;
	end 

end
end


assign dreq.strobe=strobe;
assign dreq.addr=daddr;
assign dreq.size=msize;
assign msize=(size==3'b0)?MSIZE1:
	  (size==3'b1)?MSIZE2:
	  (size==3'b10)?MSIZE4:
	  (size==3'b11)?MSIZE8:MSIZE1 ;




`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (flag),
		.pc                 (lastpc),
		.instr              (iresp.data),
		.skip               (skip),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (RegWrite),
		.wdest              ({3'b0,Rd}),
		.wdata              (_Wr_data)
	);
	
	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
		.gpr_0              (registers_instance.regs[0]),
		.gpr_1              (registers_instance.regs[1]),
		.gpr_2              (registers_instance.regs[2]),
		.gpr_3              (registers_instance.regs[3]),
		.gpr_4              (registers_instance.regs[4]),
		.gpr_5              (registers_instance.regs[5]),
		.gpr_6              (registers_instance.regs[6]),
		.gpr_7              (registers_instance.regs[7]),
		.gpr_8              (registers_instance.regs[8]),
		.gpr_9              (registers_instance.regs[9]),
		.gpr_10             (registers_instance.regs[10]),
		.gpr_11             (registers_instance.regs[11]),
		.gpr_12             (registers_instance.regs[12]),
		.gpr_13             (registers_instance.regs[13]),
		.gpr_14             (registers_instance.regs[14]),
		.gpr_15             (registers_instance.regs[15]),
		.gpr_16             (registers_instance.regs[16]),
		.gpr_17             (registers_instance.regs[17]),
		.gpr_18             (registers_instance.regs[18]),
		.gpr_19             (registers_instance.regs[19]),
		.gpr_20             (registers_instance.regs[20]),
		.gpr_21             (registers_instance.regs[21]),
		.gpr_22             (registers_instance.regs[22]),
		.gpr_23             (registers_instance.regs[23]),
		.gpr_24             (registers_instance.regs[24]),
		.gpr_25             (registers_instance.regs[25]),
		.gpr_26             (registers_instance.regs[26]),
		.gpr_27             (registers_instance.regs[27]),
		.gpr_28             (registers_instance.regs[28]),
		.gpr_29             (registers_instance.regs[29]),
		.gpr_30             (registers_instance.regs[30]),
		.gpr_31             (registers_instance.regs[31])
	);

    DifftestTrapEvent DifftestTrapEvent(
		.clock              (clk),
		.coreid             (0),
		.valid              (0),
		.code               (0),
		.pc                 (0),
		.cycleCnt           (0),
		.instrCnt           (0)
	);

	DifftestCSRState DifftestCSRState(
		.clock              (clk),
		.coreid             (0),
		.priviledgeMode     (lastmode),
		.mstatus            (csr_instance.regs.mstatus),
		.sstatus            (csr_instance.regs.mstatus & 64'h800000030001e000 /* mstatus & 64'h800000030001e000 */),
		.mepc               (csr_instance.regs.mepc),
		.sepc               (0),
		.mtval              (csr_instance.regs.mtval),
		.stval              (0),
		.mtvec              (csr_instance.regs.mtvec),
		.stvec              (0),
		.mcause             (csr_instance.regs.mcause),
		.scause             (0),
		.satp               (csr_instance.regs.satp),
		.mip                (csr_instance.regs.mip),
		.mie                (csr_instance.regs.mie),
		.mscratch           (csr_instance.regs.mscratch),
		.sscratch           (0),
		.mideleg            (0),
		.medeleg            (0)
	);
`endif
endmodule
`endif