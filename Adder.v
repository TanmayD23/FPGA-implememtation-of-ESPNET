module Adder #(
               parameter data_width = 17
               )
              (
               input clock,
               input reset,
               input enable,
               input signed [data_width-1:0]data_1,
               input signed [data_width-1:0]data_2,
               output reg signed [data_width-1:0]sum
               );
    wire signed [data_width-1:0]sm;
    
    assign sm = data_1 + data_2;
    
    always @(posedge clock)
    begin
        if(enable)
        begin
            if(reset == 1'b1)
            begin
                sum <= {data_width{1'b0}};
            end
            else
            begin
                if(data_1[data_width-1] & data_2[data_width-1] & !sm[data_width-1]) // Underflow condition
                begin
                    sum[data_width-1] <= 1'b1;
                    sum[data_width-2:0] <= {(data_width-1){1'b0}};
                end     
                else if(!data_1[data_width-1] & !data_2[data_width-1] & sm[data_width-1]) // Overflow condotion
                begin
                    sum[data_width-1] <= 1'b0;
                    sum[data_width-2:0] <= {(data_width-1){1'b1}};
                end
                else
                begin
                    sum <=sm;
                end
            end
        end
    end                                                 
endmodule

