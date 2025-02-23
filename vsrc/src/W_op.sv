module W_op (input logic [63:0] a,

output logic [63:0] result

);


assign result = {{32{a[31]}},{a[31:0]}};
endmodule