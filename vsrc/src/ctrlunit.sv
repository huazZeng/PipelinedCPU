/* verilator lint_off NOLATCH */
module controlUnit(
input logic [6:0]opcode,
input logic [2:0]func3,
input logic [6:0]fun7,
input logic athematic,
output logic jump,
output  logic MemRead,
//0 ->ALU 1->dmreaddata 2->pc+4 3->immediate
	output logic [3:0]WhichtoReg,
	output logic MemWrite,
	output logic  ALUSrc1,
	output logic  ALUSrc2,
	output  logic RegWrite,
	output  logic [4:0]ALUctl,
	output logic [2:0]b,
	output logic [2:0]size,
	output logic word,
	output logic div_start,
	output logic div_sign,
	output logic mul_start,
	output logic unsignedLoad,
	output logic WhichtoCSR,
	output logic [1:0]Csr_op,
	output logic csrWrite,
	output logic csr_ret

);
always_comb begin
	csr_ret=0;
//I
if(opcode==7'b0010011)
begin
WhichtoCSR=0;
Csr_op=0;
csrWrite=0;
unsignedLoad=0;
div_sign=0;
mul_start=0;
div_start=0;
word=0;
MemRead=0;
size=3'b0;
MemWrite= 0;
//0->RS1 1-> pc
ALUSrc1=0;
//0->RS2 1-> immediate
ALUSrc2=1;
RegWrite=1;
WhichtoReg=0;
b=0;
jump=0;
case (func3) 
//addi
 3'b000: ALUctl=0;
 //xori
 3'b100: ALUctl=5'b0011;
 //ori
 3'b110: ALUctl=5'b0010;
 //andi
 3'b111: ALUctl=5'b0100;
 //slti
 3'b010: ALUctl=5'b1011;
 //sltiu
 3'b011: ALUctl=5'b1100;
 3'b101:begin
	//srai
		if(athematic)begin
			 ALUctl=5'b1010;
		end
	//srli
		else begin
			ALUctl=5'b1001;
		end
	end
 3'b001:begin
	//slai
		if(athematic)begin
			 ALUctl=5'b1000;
		end
	//slli
		else begin
			ALUctl=5'b0111;
		end
	end
 default: ALUctl =5'b1111;
endcase 
end

else if(opcode==7'b0110011)
begin
	WhichtoCSR=0;
	Csr_op=0;
	csrWrite=0;
	unsignedLoad=0;
	word=0;
	MemRead=0;
	size=3'b0;
	MemWrite= 0;
	//0->RS1 1-> pc
	ALUSrc1=0;
	//0->RS2 1-> immediate
	ALUSrc2=0;
	RegWrite=1;

	b=0;
	jump=0;
	case (func3) 
		//add
		3'b000: begin
			if(fun7==7'b0000000)begin
				ALUctl=0;
				WhichtoReg=0;
				div_start=0;
				div_sign=0;
				mul_start=0;
			end
			//sub
			if(fun7==7'b0100000)begin
				ALUctl=1;
				WhichtoReg=0;
				div_start=0;
				div_sign=0;
				mul_start=0;
			end
			//mul
			if(fun7==7'b0000001)begin
				ALUctl=0;
				WhichtoReg=7;
				div_start=0;
				div_sign=0;
				mul_start=1;
			end
		end
			//xor
		3'b100: 
		begin
		if(fun7==7'b0000000)
			begin
				ALUctl=5'b0011;
				WhichtoReg=0;
				div_start=0;
				div_sign=0;
				mul_start=0;
			end
		//div
		if(fun7==7'b0000001)
			begin
				ALUctl=5'b1111;
				div_start=1;
				WhichtoReg=5;
				div_sign=1;
				mul_start=0;
			end
		end


		3'b110:begin
		//or
		if(fun7==7'b0000000)
		begin
			WhichtoReg=0; 
			ALUctl=5'b0010;
			div_start=0;
			div_sign=0;
			mul_start=0;
		end
		//rem
		if(fun7==7'b0000001)
		begin
			ALUctl=5'b1111;
			div_start=1;
			WhichtoReg=6;
			div_sign=1;
			mul_start=0;
		end
		end
		//and
		3'b111: begin
			if(fun7==7'b0000000)
		begin
			WhichtoReg=0; 
			ALUctl=5'b0100;
			div_start=0;
			div_sign=0;
			mul_start=0;
		end
			//remu
		if(fun7==7'b0000001)
		begin
			ALUctl=5'b1111;
			WhichtoReg=6;
			div_sign=0;
			mul_start=0;
			div_start=1;
		end
		end

		3'b001:begin
			WhichtoReg=0; 
			ALUctl=5'b0111;
			div_start=0;
			div_sign=0;
			mul_start=0;
		end
		3'b010:begin
			WhichtoReg=0; 
			ALUctl=5'b1011;
			div_start=0;
			div_sign=0;
			mul_start=0;
		end
		3'b011:begin
			WhichtoReg=0; 
			ALUctl=5'b1100;
			div_start=0;
			div_sign=0;
			mul_start=0;
		end
		3'b101:begin
			if(fun7==7'b0100000 |fun7==7'b0000000 )begin
			//sra
				if(athematic)begin
					ALUctl=5'b1010;
					WhichtoReg=0;
					div_start=0;
					div_sign=0;
					mul_start=0;
				end
			//srl
				else begin
					ALUctl=5'b1001;
					WhichtoReg=0;
					div_start=0;
					div_sign=0;
					mul_start=0;
				end
			end
			else if(fun7==7'b0000001)begin
				ALUctl=5'b1111;
				div_start=1;
				WhichtoReg=5;
				div_sign=0;
				mul_start=0;
			end
				
			end
		default: begin
			ALUctl =5'b0111;
			WhichtoReg=0;
			div_start=0;
			div_sign=0;
			mul_start=0;
		end
		endcase 
	end
//B
else if(opcode==7'b1100011)
begin
WhichtoCSR=0;
Csr_op=0;
csrWrite=0;
unsignedLoad=0;
div_sign=0;
mul_start=0;
div_start=0;
word=0;
size=3'b0;
MemWrite= 0;
ALUSrc1=1;
ALUSrc2=1;
RegWrite=0;
WhichtoReg=0;
ALUctl=5'b0000;
jump=0;
MemRead=0;
case(func3)
	3'b000 : b=3'b001;
	3'b001 : b=3'b010;//bne
	3'b101 : b=3'b100;//beg
	3'b111 : b=3'b110;//bgeu
	3'b100 : b=3'b011;//blt
	3'b110 : b=3'b101;//bltu
	default:b=3'b0;
endcase
end
//jal
else if(opcode==7'b1101111)
begin
WhichtoCSR=0;
Csr_op=0;
csrWrite=0;
unsignedLoad=0;
div_sign=0;
mul_start=0;
div_start=0;
word=0;
size=3'b0;
MemWrite= 0;
ALUSrc1=1;
ALUSrc2=1;
RegWrite=1;
WhichtoReg=2;
ALUctl=0;
jump=1;
MemRead=0;
b=0;
end
//jalr
else if(opcode==7'b1100111)
begin
WhichtoCSR=0;
Csr_op=0;
csrWrite=0;
unsignedLoad=0;
div_sign=0;
mul_start=0;
div_start=0;
word=0;
size=3'b0;
MemWrite= 0;
ALUSrc1=0;
ALUSrc2=1;
RegWrite=1;
WhichtoReg=2;
ALUctl=0;
jump=1;
b=0;
MemRead=0;
end
//lui
else if(opcode==7'b0110111)
begin
WhichtoCSR=0;
Csr_op=0;
csrWrite=0;
unsignedLoad=0;
div_sign=0;
mul_start=0;
div_start=0;
word=0;
ALUSrc1=0;	
size=3'b0;
MemWrite= 0;
ALUSrc2=1;
RegWrite=1;
WhichtoReg=0;
ALUctl=5;
jump=0;
b=0;
MemRead=0;
end
//aupic
else if(opcode==7'b0010111)
begin
	WhichtoCSR=0;
	Csr_op=0;
	csrWrite=0;
	unsignedLoad=0;
	div_sign=0;
	mul_start=0;
	div_start=0;
	word=0;
	size=3'b0;
	MemWrite= 0;
	ALUSrc1=1;
	ALUSrc2=1;
	RegWrite=1;
	WhichtoReg=0;
	ALUctl=5'b0110;
	jump=0;
	b=0;
	MemRead=0;
end
//l
else if(opcode==7'b0000011)
begin
	WhichtoCSR=0;
	Csr_op=0;
	csrWrite=0;
	div_sign=0;
	mul_start=0;
	div_start=0;
	word=0;
	ALUSrc1=0;
	ALUSrc2=1;	
	RegWrite=1;
	WhichtoReg=1;
	ALUctl=5'b0000;
	MemRead=1;
	MemWrite= 0;
	size = (func3[2])  ? (func3-3'b100):func3;
	jump=0;
	b=0;
	unsignedLoad = func3[2];

end
//sd
else if(opcode==7'b0100011)
begin
	WhichtoCSR=0;
	Csr_op=0;
	csrWrite=0;
	unsignedLoad = 0;
	div_sign=0;
	mul_start=0;
	div_start=0;
	word=0;
	ALUSrc1=0;
	ALUSrc2=1;	
	RegWrite=0;
	WhichtoReg=0;
	ALUctl=5'b0000;
	size=func3;
	jump=0;
	b=0;
	MemRead=0;
	case(func3)
		3'b000:MemWrite=1;
		3'b001:MemWrite=1;
		3'b010:MemWrite=1;
		3'b011:MemWrite=1;
		default:MemWrite=0;
	endcase
end
//slli srai srli
else if(opcode==7'b0010011)
begin
	WhichtoCSR=0;
	Csr_op=0;
	csrWrite=0;
	unsignedLoad=0;
	div_sign=0;
	mul_start=0;
	div_start=0;
	word=0;
	ALUSrc1=0;
	ALUSrc2=1;	
	RegWrite=1;
	WhichtoReg=0;
	size=3'b000;
	jump=0;
	b=0;
	MemRead=0;
	MemWrite= 0;
	case (func3)
		3'b010:ALUctl=5'b1011;
		3'b011:ALUctl=5'b1100;
		default: ALUctl=0;
		
	endcase
end
else if(opcode==7'b0011011)
begin
	WhichtoCSR=0;
	Csr_op=0;
	csrWrite=0;
	unsignedLoad=0;
	div_sign=0;
	mul_start=0;
	div_start=0;
	word=1;
	MemRead=0;
	size=3'b0;
	MemWrite= 0;
	//0->RS1 1-> pc
	ALUSrc1=0;
	//0->RS2 1-> immediate
	ALUSrc2=1;
	RegWrite=1;
	WhichtoReg=4;
	b=0;
	jump=0;
	case (func3) 
		//addiw
		3'b000: ALUctl=0;
		//xor
		3'b100: ALUctl=5'b0011;
		//or
		3'b110: ALUctl=5'b0010;
		//and
		3'b111: ALUctl=5'b0100;
		//slti
		3'b010: ALUctl=5'b1011;
		//sltiu
		3'b011: ALUctl=5'b1100;
		3'b101:begin
			//sraiww
				if(athematic)begin
					ALUctl=5'b1010;
				end
			//srliw
				else begin
					ALUctl=5'b1001;
				end
			end
		3'b001:begin
			//slaiw
				if(athematic)begin
					ALUctl=5'b1000;
				end
			//slliw
				else begin
					ALUctl=5'b0111;
				end
			end
		default: ALUctl =5'b1111;
		endcase 
end
else if(opcode==7'b0111011)
begin
	WhichtoCSR=0;
	Csr_op=0;
	csrWrite=0;
	unsignedLoad=0;
	word=1;
	MemRead=0;
	size=3'b0;
	MemWrite= 0;
	//0->RS1 1-> pc
	ALUSrc1=0;
	//0->RS2 1-> immediate
	ALUSrc2=0;
	RegWrite=1;
	b=0;
	jump=0;
	case (func3) 
		//addw
		3'b000: begin
			if(fun7==7'b0000000)begin
				ALUctl=0;
				WhichtoReg=4;
				div_start=0;
				div_sign=0;
				mul_start=0;
			end
			//subw
			if(fun7==7'b0100000)begin
				ALUctl=1;
				WhichtoReg=4;
				div_start=0;
				div_sign=0;
				mul_start=0;
			end
			//mulw
			if(fun7==7'b0000001)begin
				ALUctl=0;
				WhichtoReg=7;
				div_start=0;
				div_sign=0;
				mul_start=1;
			end
		end
			//xorw
		3'b100: 
		begin
		if(fun7==7'b0000000)
			begin
				ALUctl=5'b0011;
				WhichtoReg=0;
				div_start=0;
				div_sign=0;
				mul_start=0;
			end
		//divw
		if(fun7==7'b0000001)
			begin
				ALUctl=5'b1111;
				div_start=1;
				WhichtoReg=5;
				div_sign=1;
				mul_start=0;
			end
		end


		3'b110:begin
		//orw
		if(fun7==7'b0000000)
		begin
			WhichtoReg=0; 
			ALUctl=5'b0010;
			div_start=0;
			div_sign=0;
			mul_start=0;
		end
		//remw
		if(fun7==7'b0000001)
		begin
			ALUctl=5'b1111;
			div_start=1;
			WhichtoReg=6;
			div_sign=1;
			mul_start=0;
		end
		end
		//andw
		3'b111: begin
			if(fun7==7'b0000000)
		begin
			WhichtoReg=0; 
			ALUctl=5'b0100;
			div_start=0;
			div_sign=0;
			mul_start=0;
		end
			//remuw
		if(fun7==7'b0000001)
		begin
			ALUctl=5'b1111;
			WhichtoReg=6;
			div_sign=0;
			mul_start=0;
			div_start=1;
		end
		end

		3'b001:begin
			WhichtoReg=4; 
			ALUctl=5'b10001;
			div_start=0;
			div_sign=0;
			mul_start=0;
		end

		
		3'b101:begin
			if(fun7==7'b0100000 |fun7==7'b0000000 )begin
			//sraw
				if(athematic)begin
					ALUctl=5'b1111;
					WhichtoReg=4;
					div_start=0;
					div_sign=0;
					mul_start=0;
				end
			//srlw
				else begin
					ALUctl=5'b1101;
					WhichtoReg=4;
					div_start=0;
					div_sign=0;
					mul_start=0;
				end
			end
			else if(fun7==7'b0000001)begin
				ALUctl=5'b1111;
				div_start=1;
				WhichtoReg=5;
				div_sign=0;
				mul_start=0;
			end
				
			end
		default: begin
			ALUctl =5'b0111;
			WhichtoReg=0;
			div_start=0;
			div_sign=0;
			mul_start=0;
		end
		endcase
end
else if (opcode==7'b1110011) begin
	
	
	div_sign=0;
	mul_start=0;
	div_start=0;
	ALUSrc1=0;
	ALUSrc2=0;	
	ALUctl=5'b0000;
	word=0;
	unsignedLoad=0;
	size=3'b011;
	jump=0;
	b=0;
	MemRead=0;
	MemWrite= 0;
	case(func3)
		3'b000:begin
			RegWrite=0;
			WhichtoReg=0;
			WhichtoCSR=0;
			Csr_op=0;
			csr_ret=1;
			csrWrite=0;
		end
		3'b001:begin
			RegWrite=1;
			WhichtoReg=8;
			WhichtoCSR=0;
			Csr_op=0;
			csrWrite=1;
			csr_ret=0;
		end
		3'b010:begin
			RegWrite=1;
			WhichtoReg=8;
			WhichtoCSR=0;
			Csr_op=1;
			csrWrite=1;
			csr_ret=0;
		end
		3'b011:begin
			RegWrite=1;
			WhichtoReg=8;
			WhichtoCSR=0;
			Csr_op=2;
			csrWrite=1;
			csr_ret=0;
		end
		3'b101:begin
			RegWrite=1;
			WhichtoReg=8;
			WhichtoCSR=1;
			Csr_op=0;
			csrWrite=1;
			csr_ret=0;
		end
		3'b110:begin
			RegWrite=1;
			WhichtoReg=8;
			WhichtoCSR=1;
			Csr_op=1;
			csrWrite=1;
			csr_ret=0;
		end
		3'b111:begin
			RegWrite=1;
			WhichtoReg=8;
			WhichtoCSR=1;
			Csr_op=2;
			csrWrite=1;
			csr_ret=0;
		end
		default:begin
			RegWrite=0;
			WhichtoReg=8;
			WhichtoCSR=0;
			Csr_op=0;
			csrWrite=0;
			csr_ret=0;
		end

endcase

end
else  begin
    Csr_op=0;
	csrWrite=0;
	csr_ret=0;
    WhichtoCSR=0;
	div_sign=0;
	mul_start=0;
	div_start=0;
	ALUSrc1=0;
	ALUSrc2=0;	
	RegWrite=0;
	WhichtoReg=0;
	ALUctl=5'b0000;
	word=0;
	unsignedLoad=0;
	size=3'b011;
	jump=0;
	b=0;
	MemRead=0;
	MemWrite= 0;
end
end

endmodule