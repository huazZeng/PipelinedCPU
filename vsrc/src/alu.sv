module alu (input logic [63:0] a, b,
input logic [4:0] alucontrol,
input logic word,
output logic [63:0] result

);

always_comb begin
if(word)begin
case (alucontrol)
5'b0000: result = a + b;
5'b0001: result = a - b;
5'b0111: result={32'b0,{a[31:0]}<<(b[5:0])};//logic
5'b1000: result={32'b0,$signed(a[31:0])<<<(b[5:0])};//athematic
5'b1001: result={32'b0,{a[31:0]}>>(b[5:0])};
5'b1010: result={32'b0,$signed(a[31:0])>>>(b[5:0])};
5'b1101: result ={32'b0,{a[31:0]}>>(b[4:0])};
5'b1111: result={32'b0,$signed(a[31:0])>>>(b[4:0])};
5'b10001:result={32'b0,{a[31:0]}<<(b[4:0])};
5'b10010:result={32'b0,$signed(a[31:0])<<<(b[4:0])};
default: result=64'b0;
endcase
end
else begin
case (alucontrol)
5'b0000: result = a + b;
5'b0001: result = a - b;
5'b0010: result = a|b;
5'b0011: result = a^b;
5'b0100: result = a&b;
5'b0101: result = b<<12;
5'b0110: result = a+(b<<12);
5'b0111: result = a<<(b[5:0]);//logic
5'b1000: result = $signed(a)<<<(b[5:0]);//athematic
5'b1001: result = a>>(b[5:0]);
5'b1010: result = $signed(a)>>>(b[5:0]);
5'b1011: result = {63'b0,$signed(a)<$signed(b)};
5'b1100: result = {63'b0,a<b};
5'b1101: result ={32'b0,{a[31:0]}>>(b[4:0])};
5'b1111: result={32'b0,$signed(a[31:0])>>>(b[4:0])};
5'b10001:result={32'b0,{a[31:0]}<<(b[4:0])};
5'b10010:result={32'b0,$signed(a[31:0])<<<(b[4:0])};
default: result = 64'b0;
endcase
end
end
endmodule 