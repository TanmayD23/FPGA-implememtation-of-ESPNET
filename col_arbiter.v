module col_arbiter #(
                     parameter col_addr_width = 2560
                     )
                    (
                     input clock,
                     input reset,
                     input [col_addr_width-1:0]col_addr_in,
                     input [2:0]control,
                     output reg [col_addr_width-1:0]col_addr_1,
                     output reg [col_addr_width-1:0]col_addr_2,
                     output reg [col_addr_width-1:0]col_addr_3,
                     output reg [col_addr_width-1:0]col_addr_4
                     );
                     
    always@(posedge clock)
    begin
        if(reset == 1'b1)
        begin
            col_addr_1 <= 0;
            col_addr_2 <= 0;
            col_addr_3 <= 0;
            col_addr_4 <= 0;
        end
        else
        begin
            if(control == 3'd1)
            begin
                col_addr_1 <= col_addr_in;
                col_addr_2 <= col_addr_2;
                col_addr_3 <= col_addr_3;
                col_addr_4 <= col_addr_4;
            end
            else if(control == 3'd2)
            begin
                col_addr_1 <= col_addr_1;
                col_addr_2 <= col_addr_in;
                col_addr_3 <= col_addr_3;
                col_addr_4 <= col_addr_4;
            end
            else if(control == 3'd3)
            begin
                col_addr_1 <= col_addr_1;
                col_addr_2 <= col_addr_2;
                col_addr_3 <= col_addr_in;
                col_addr_4 <= col_addr_4;
            end
            else if(control == 3'd4)
            begin
                col_addr_1 <= col_addr_1;
                col_addr_2 <= col_addr_2;
                col_addr_3 <= col_addr_3;
                col_addr_4 <= col_addr_in;
            end         
            else
            begin
                col_addr_1 <= col_addr_1;
                col_addr_2 <= col_addr_2;
                col_addr_3 <= col_addr_3;
                col_addr_4 <= col_addr_4;            
            end
        end
    end                          
                     
endmodule
