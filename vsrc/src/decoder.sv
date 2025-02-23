
module decoder(
	input logic[31:0] instr,
output logic [4:0]Rs1,
output logic [4:0]Rs2,
output logic [4:0]Rd,
output logic [6:0]opcode,
output logic [2:0]func3,
output logic [63:0]imme,
output logic [6:0]func7,
output logic athematic,
output logic [63:0]  zimm,
output logic [11:0]	csr_id
);
logic I_type;
logic U_type;
logic J_type;
logic B_type;
logic S_type;
logic I_shift;
logic [63:0]Is_imme;
logic [63:0]I_imme;
logic [63:0]U_imme;
logic [63:0]J_imme;
logic [63:0]B_imme;
logic [63:0]S_imme;


assign I_type=(instr[6:0]==7'b0011011)|(instr[6:0]==7'b1100111) | (instr[6:0]==7'b0000011) | ((instr[6:0]==7'b0010011)&(instr[14:12]!=3'b001)&(instr[14:12]!=3'b101) );
assign I_shift=(instr[6:0]==7'b0010011)&((instr[14:12]==3'b001)|(instr[14:12]==3'b101)) ;
assign U_type=(instr[6:0]==7'b0110111) | (instr[6:0]==7'b0010111);
assign J_type=(instr[6:0]==7'b1101111);
assign B_type=(instr[6:0]==7'b1100011);
assign S_type=(instr[6:0]==7'b0100011);
	
	
assign I_imme={{52{instr[31]}},instr[31:20]}; 
assign Is_imme={58'b0,instr[25:20]};
assign U_imme={{44{instr[31]}},instr[31:12]};
assign J_imme={{44{instr[31]}},instr[19:12],instr[20],instr[30:21],1'b0};   
assign B_imme={{52{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0};
assign S_imme={{52{instr[31]}},instr[31:25],instr[11:7]}; 
	
assign imme= I_type?I_imme :
			I_shift?Is_imme :
			U_type?U_imme :
			J_type?J_imme :
			B_type?B_imme :
			S_type?S_imme : 64'd0;
assign opcode=instr[6:0];
assign func3=instr[14:12];
assign func7=instr[31:25];
assign Rs1=instr[19:15];
assign Rs2=instr[24:20];
assign Rd =instr[11:7];
assign athematic =instr[30];
assign zimm = {{59'b0},instr[19:15]}; 
assign csr_id = instr[31:20];
endmodule 