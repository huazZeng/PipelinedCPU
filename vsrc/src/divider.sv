module divider(
    input wire clk, div_start, is_signed,reset,
    input wire signed [63:0] numerator, denominator,
    output logic signed [63:0] quotient, remainder,
    output logic div_done,
    input logic word,
    input logic next
);

    logic signed [127:0] temp_numerator, temp_denominator;
    logic signed [63:0] abs_numerator, abs_denominator;
    logic [127:0] temp_numerator_unsigned, temp_denominator_unsigned;
    logic [63:0] abs_numerator_unsigned, abs_denominator_unsigned;
    logic [6:0] counter;
    logic numerator_sign, denominator_sign, result_sign, finish;
    logic signed [63:0] temp_numerator32, temp_denominator32;
    logic signed [31:0] abs_numerator32, abs_denominator32;
    logic [63:0] temp_numerator_unsigned32, temp_denominator_unsigned32;
    logic [31:0] abs_numerator_unsigned32, abs_denominator_unsigned32;
    logic numerator_sign32, denominator_sign32, result_sign32;
    logic [31:0] quotient_32,remainder_32;
    // Calculate absolute values of inputs and determine signs
    always_comb begin
        numerator_sign = numerator[63];
        denominator_sign = denominator[63];
        abs_numerator = numerator_sign ? (~numerator + 1) : numerator;
        abs_denominator = denominator_sign ? (~denominator + 1) : denominator;
        result_sign = numerator_sign ^ denominator_sign;
        abs_numerator_unsigned= $unsigned(numerator);
        abs_denominator_unsigned = $unsigned(denominator);
        numerator_sign32 = numerator[31];
        denominator_sign32 = denominator[31];
        abs_numerator32 = numerator_sign32 ? (~numerator[31:0] + 1) : numerator[31:0];
        abs_denominator32 = denominator_sign32 ? (~denominator[31:0] + 1) : denominator[31:0];
        result_sign32 = numerator_sign32 ^ denominator_sign32;
        abs_numerator_unsigned32= $unsigned(numerator[31:0]);
        abs_denominator_unsigned32 = $unsigned(denominator[31:0]);

        quotient_32 = (~temp_numerator32[31:0] + 1) ;
        remainder_32= (~temp_numerator32[63:32] + 1) ;
    end
    assign div_done = finish;
    // Main divider logic
    always_ff @(posedge clk) begin
        if(reset)begin
            finish <= 0;
            counter <= 0;
        end
        if (next) begin
            finish <= 0;
            counter <= 0;
        end 
        
        else if(div_start&!finish) begin
            if (word)begin
                if (abs_denominator32 != 0) begin
                  //有符号
                    if (is_signed) begin
                        if(counter==0) begin
                            temp_numerator32 <= {32'h0000,abs_numerator32};
                            temp_denominator32 <= {abs_denominator32,32'h0000};
                            counter <=counter+1;
                        end

                        else if (counter < 33) begin
                            if (temp_numerator32[63:32] >= abs_denominator32) begin
                                temp_numerator32<= temp_numerator32 - temp_denominator32 + 1'b1;
                            end
                        else begin
                                temp_numerator32 <= {temp_numerator32[62:0], 1'b0};
                                counter <= counter + 1;
                        end
                        end
                        else if(counter==33)
                        begin
                            if (temp_numerator32[63:32] >= abs_denominator32) begin
                                temp_numerator32 <= temp_numerator32 - temp_denominator32 + 1'b1;
                            end
                            counter <= counter + 1;
                        end
                        else begin
                            quotient <= result_sign32? {{32{quotient_32[31]}},{(~temp_numerator32[31:0] + 1)}} : {{32{temp_numerator32[31]}},temp_numerator32[31:0]};
                            remainder <= numerator_sign32 ? {{32{remainder_32[31]}},{(~temp_numerator32[63:32] + 1)}} : {{32{temp_numerator32[63]}},temp_numerator32[63:32]};
                            finish <= 1'b1; 
                        end
                    end
                        //无符号
                    else begin
                        if(counter==0) begin
                            temp_denominator_unsigned32 <= {abs_denominator_unsigned32, 32'h0000};
                            temp_numerator_unsigned32 <= {32'h0, abs_numerator_unsigned32};
                            counter <= counter + 1;
                        end
                        else if (counter < 33) begin
                            if (temp_numerator_unsigned32[63:32] >= abs_denominator_unsigned32) begin
                                temp_numerator_unsigned32 <= temp_numerator_unsigned32 - temp_denominator_unsigned32 + 1'b1;
                            end
                            else begin
                                temp_numerator_unsigned32 <= {temp_numerator_unsigned32[62:0], 1'b0};
                                counter <= counter + 1;
                            end
                        end
                        else if(counter ==33)begin
                            if (temp_numerator_unsigned32[63:32] >= abs_denominator_unsigned32) begin
                                temp_numerator_unsigned32 <= temp_numerator_unsigned32 - temp_denominator_unsigned32 + 1'b1;
                            end
                            counter <= counter + 1;
                        end
                        else begin
                            quotient <= {{32{temp_numerator_unsigned32[31]}},temp_numerator_unsigned32[31:0]};
                            remainder <= {{32{temp_numerator_unsigned32[63]}},temp_numerator_unsigned32[63:32]};
                            finish <= 1'b1;
                        end
                    end
                end
                        //除数为 0
                else begin
                    quotient <= 64'hffffffffffffffff;
                    remainder <= {{32{numerator[31]}},{numerator[31:0]}};
                    finish <= 1'b1;
                end
            end
            
            else 
            begin
                if (denominator != 0) begin
                    //有符号
                    if (is_signed) begin
                        if(counter==0) begin
                            temp_numerator <= {64'h00000000,abs_numerator};
                            temp_denominator <= {abs_denominator,64'h00000000};
                            counter <=counter+1;
                        end

                    else if (counter < 65) begin
                        if (temp_numerator[127:64] >= abs_denominator) begin
                            temp_numerator<= temp_numerator - temp_denominator + 1'b1;
                        end
                        else begin
                            temp_numerator <= {temp_numerator[126:0], 1'b0};
                            counter <= counter + 1;
                        end
                    end
                    else if(counter==65)
                    begin
                    if (temp_numerator[127:64] >= abs_denominator) begin
                        temp_numerator <= temp_numerator - temp_denominator + 1'b1;
                    end
                    counter <= counter + 1;       
                    end
                    else begin
                        quotient <= result_sign ? (~temp_numerator[63:0] + 1) : temp_numerator[63:0];
                        remainder <= numerator_sign ? (~temp_numerator[127:64] + 1) : temp_numerator[127:64];
                        finish <= 1'b1;
                            
                    end
                    end
                    //无符号
                    else begin
                        if(counter==0) begin
                            temp_denominator_unsigned <= {abs_denominator_unsigned, 64'h00000000};
                            temp_numerator_unsigned <= {64'h0, abs_numerator_unsigned};
                            counter <= counter + 1;
                        end


                        else if (counter < 65) begin
                            
                            if (temp_numerator_unsigned[127:64] >= abs_denominator_unsigned) begin
                                temp_numerator_unsigned <= temp_numerator_unsigned - temp_denominator_unsigned + 1'b1;
                            end
                            else begin
                                temp_numerator_unsigned <= {temp_numerator_unsigned[126:0], 1'b0};
                                counter <= counter + 1;
                            end
                        end
                        else if(counter ==65)begin
                            if (temp_numerator_unsigned[127:64] >= abs_denominator_unsigned) begin
                                temp_numerator_unsigned <= temp_numerator_unsigned - temp_denominator_unsigned + 1'b1;
                            end
                            counter <= counter + 1;
                        end
                        else begin
                            quotient <= temp_numerator_unsigned[63:0];
                            remainder <= temp_numerator_unsigned[127:64];
                            finish <= 1'b1;
                        end
                    end
                end
                    //除数为 0
                else begin
                    quotient <= 64'hffffffffffffffff;
                    remainder <= numerator;
                    finish <= 1;
                end
            end
            

        
        end
        else begin
            finish <= 1'b0;
            
        end
    end

endmodule