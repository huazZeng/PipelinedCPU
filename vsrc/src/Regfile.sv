
module registers(
	input logic stallM,
	input logic clk,
	input logic reset,
	input logic W_en,
	input logic [4:0]Rs1,
	input logic [4:0]Rs2,
	input logic [4:0]Rd,
	input logic [63:0]Wr_data,
	
	output logic [63:0]Rd_data1,
	output logic [63:0]Rd_data2
    );
	integer  i;
	reg [63:0] regs [31:0];
	
    always@(posedge  clk )
		begin
			if(reset)
			begin
			regs[0] <= 0;
			for (i = 1; i <= 31; i = i + 1) begin
			regs[i] <= 64'hFFFFFFFF; // Initialize each register to 0
			end
			end
			//阻塞
			if(stallM)
			begin
			end 
			else if(W_en&&Rd!=5'b0)
			begin
			regs[Rd] <= Wr_data;	
			end
		end
//read

	assign Rd_data1=regs[Rs1];
	assign Rd_data2=regs[Rs2];
	
endmodule
