module address_rf #(
                    parameter row_in_width = 10*256,                // Width of 1024 row addresses
                    col_in_width = 11*256,                          // Width of 1024 col addresses
                    ch_in_width = 8*256,                            // Width of 1024 ch addresses
                    row_width = 10,                                 // Width of row address
                    col_width = 11,                                 // Width of col address
                    ch_width = 8                                    // Width of ch address
                    )
                   (
                    input clock,
                    input reset,
                    input [row_in_width-1:0]row_in, 
                    input [col_in_width-1:0]col_in, 
                    input [ch_in_width-1:0]ch_in,                     
                    output reg [row_in_width-1:0]row_out,                     
                    output reg [col_in_width-1:0]col_out,                     
                    output reg [ch_in_width-1:0]ch_out                     
                    );
                    
    reg [row_in_width-1:0]row_reg;                    
    reg [col_in_width-1:0]col_reg;                    
    reg [ch_in_width-1:0]ch_reg;  
    
    always @(posedge clock)
    begin
        if(reset == 1'b1)
        begin
            row_reg[row_in_width-1] <= 1'b1;                    // To indicate that it is a invalid address
            col_reg[col_in_width-1] <= 1'b1;                    // To indicate that it is a invalid address
            ch_reg[ch_in_width-1] <= 1'b1;                      // To indicate that it is a invalid address
            
            row_reg[row_width-2:0] <= {row_width-1{1'b0}};      // Rest of the address is 0
            col_reg[col_width-2:0] <= {col_width-1{1'b0}};      // Rest of the address is 0
            ch_reg[ch_width-2:0] <= {ch_width-1{1'b0}};         // Rest of the address is 0
            
            row_out[row_in_width-1] <= 1'b1;                    // To indicate that it is a invalid address
            col_out[col_in_width-1] <= 1'b1;                    // To indicate that it is a invalid address
            ch_out[ch_in_width-1] <= 1'b1;                      // To indicate that it is a invalid address
            
            row_out[row_width-2:0] <= {row_width-1{1'b0}};      // Rest of the address is 0
            col_out[col_width-2:0] <= {col_width-1{1'b0}};      // Rest of the address is 0
            ch_out[ch_width-2:0] <= {ch_width-1{1'b0}};         // Rest of the address is 0
        end
        else
        begin
            row_reg <= row_in;
            col_reg <= col_in;
            ch_reg <= ch_in;
            
            row_out <= row_reg;
            col_out <= col_reg;
            ch_out <= ch_reg;
        end
    end                  
                    
endmodule
