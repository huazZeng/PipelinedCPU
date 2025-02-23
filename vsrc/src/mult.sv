module Multiplier(
    input wire clk, mul_start,
    input wire signed [63:0] a,
    input wire signed [63:0] b,
    output logic signed [63:0] mul_result,
    output logic mul_ok,
    input logic word,
    input logic next
);

    logic signed [127:0] temp_result,temp_a;
    logic [63:0] a_abs, b_abs;
    logic a_sign, b_sign, result_sign;
    logic [6:0] counter;
    logic finish;
    logic b_boolean;
    logic signed [63:0] temp_result32,temp_a32;
    logic [31:0] a_abs32, b_abs32;
    logic a_sign32, b_sign32, result_sign32;
    // Calculate absolute values of inputs and determine signs
    always_comb begin
        a_sign = a[63];
        b_sign = b[63];
        a_abs = a_sign ? { ~a + 1} : { a};
        b_abs = b_sign ? { ~b + 1} : {b};
        result_sign = a_sign ^ b_sign;
        a_sign32 = a[31];
        b_sign32 = b[31];
        a_abs32 = a_sign32 ? { ~a[31:0] + 1} : { a[31:0]};
        b_abs32 = b_sign32 ? { ~b[31:0] + 1} : {b[31:0]};
        result_sign32 = a_sign32 ^ b_sign32;
       
    end
    assign mul_result =word ?{{32{temp_result32[31]}} ,temp_result32[31:0]}:temp_result[63:0];
    assign mul_ok=finish;
    // Multiply a and b
    always_ff @(posedge clk) begin
        if (next) begin
            counter<=0;
            finish <= 0;
            
        end else if (mul_start&!finish) 
        begin
            if(word)begin
                if (counter < 33) begin
                    if (counter == 0) begin
                        temp_result32 <= 64'b0;
                        counter <= counter + 1;
                        temp_a32 <= {32 'h0, a_abs32};
                    end
                    else begin
                        if(b_abs32[counter-1])begin
                            temp_result32 <= temp_result32 + temp_a32;
                        end
                            temp_a32 <= {temp_a32[62:0], 1'b0};
                            counter <= counter + 1;
                        
                    end
                end
                else begin
                    temp_result32 <= result_sign32 ? (~temp_result32+1) : temp_result32;
                    finish <= 1'b1;
                end
            end
            else begin
                if (counter < 65) begin
                    if (counter == 0) begin
                        temp_result <= 128'b0;
                        counter <= counter + 1;
                        temp_a <= {64  'h0, a_abs};
                    end
                    else begin
                        if(b_abs[counter-1])begin
                            temp_result <= temp_result + temp_a;
                        end
                            temp_a <= {temp_a[126:0], 1'b0};
                            counter <= counter + 1;
                    end
                end
                else begin
                    temp_result <= result_sign ? (~temp_result+1) : temp_result;
                    finish <= 1'b1;
                end
            end
        end else begin
                finish <= 1'b0;
            end
        end
    
endmodule
