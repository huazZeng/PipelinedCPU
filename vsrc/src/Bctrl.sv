`timescale 1ns/1ps
module Bctrl (
    input logic [63:0] a_in,
    input logic [63:0] b_in,
    input logic[2:0]  b,
    output logic bboolean
    );
always_comb begin
    case (b)
        3'b000 :  bboolean=0;
        //beq
        3'b001 :  bboolean= (a_in==b_in);
        //ne
        3'b010 :  bboolean= (a_in!=b_in);
        //blt
        3'b011 :  bboolean= ($signed(a_in)<$signed(b_in));
        //bge
        3'b100 :  bboolean= ($signed(a_in)>$signed(b_in))|($signed(a_in)==$signed(b_in));
        //bltu
        3'b101 :  bboolean= (a_in<b_in);//unsigned
        //bgtu
        3'b110 :  bboolean= (a_in>b_in)|(a_in==b_in);//unsigned
        default:bboolean=0;
    endcase
    
end

endmodule
