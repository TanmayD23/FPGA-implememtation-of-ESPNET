module Addr_reg_file #(
                       parameter row_width = 5*4,                    // Width of the 4 row addresses of weight 
                       col_width = 5*4,                              // Width of the 4 col addresses of weight 
                       ker_width = 5*4                               // Width of the 4 ker addresses of weight 
                       )    
                      (
                       input clock,
                       input enable,
                       input reset,
                       input [row_width-1:0]row_in,                     
                       input [col_width-1:0]col_in,                     
                       input [ker_width-1:0]ker_in,
                       output reg [row_width-1:0]row_out,
                       output reg [col_width-1:0]col_out,
                       output reg [ker_width-1:0]ker_out                                            
                       );
                       
    always @(posedge clock)
    begin
        if(reset == 1'b1)
        begin
            row_out <= {row_width{1'b0}};
            col_out <= {col_width{1'b0}};
            ker_out <= {ker_width{1'b0}};
        end
        else if(enable == 1'b1 && reset == 1'b0)
        begin
            row_out <= row_in;
            col_out <= col_in;
            ker_out <= ker_in;
        end
        else
        begin
            row_out <= row_out;
            col_out <= col_out;
            col_out <= ker_out;
        end                                          
    end                             
                       
endmodule
