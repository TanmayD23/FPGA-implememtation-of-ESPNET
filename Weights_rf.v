module Weights_rf #(
                       parameter wts_width = 17*4                    // Width of 4 weight                        
                       )    
                      (
                       input clock,
                       input enable,
                       input reset,
                       input [wts_width-1:0]wts_in,                                            
                       output reg [wts_width-1:0]wts_out                                                                 
                       );
                       
    always @(posedge clock)
    begin
        if(reset == 1'b1)
        begin
            wts_out <= {wts_width{1'b0}};            
        end
        else if(enable == 1'b1 && reset == 1'b0)
        begin
            wts_out <= wts_in;            
        end
        else
        begin
            wts_out <= wts_out;            
        end                                          
    end                             
                       
endmodule

