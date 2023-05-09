module row_arbiter #(
                     parameter row_addr_width = 2304
                     )
                    (
                     input clock,
                     input reset,
                     input [row_addr_width-1:0]row_addr_in,
                     input [2:0]control,
                     output reg [row_addr_width-1:0]row_addr_1,
                     output reg [row_addr_width-1:0]row_addr_2,
                     output reg [row_addr_width-1:0]row_addr_3,
                     output reg [row_addr_width-1:0]row_addr_4
                     );
                     
    always@(posedge clock)
    begin
        if(reset == 1'b1)
        begin
            row_addr_1 <= 0;
            row_addr_2 <= 0;
            row_addr_3 <= 0;
            row_addr_4 <= 0;
        end
        else
        begin
            if(control == 3'd1)
            begin
                row_addr_1 <= row_addr_in;
                row_addr_2 <= row_addr_2;
                row_addr_3 <= row_addr_3;
                row_addr_4 <= row_addr_4;
            end
            else if(control == 3'd2)
            begin
                row_addr_1 <= row_addr_1;
                row_addr_2 <= row_addr_in;
                row_addr_3 <= row_addr_3;
                row_addr_4 <= row_addr_4;
            end
            else if(control == 3'd3)
            begin
                row_addr_1 <= row_addr_1;
                row_addr_2 <= row_addr_2;
                row_addr_3 <= row_addr_in;
                row_addr_4 <= row_addr_4;
            end
            else if(control == 3'd4)
            begin
                row_addr_1 <= row_addr_1;
                row_addr_2 <= row_addr_2;
                row_addr_3 <= row_addr_3;
                row_addr_4 <= row_addr_in;
            end         
            else
            begin
                row_addr_1 <= row_addr_1;
                row_addr_2 <= row_addr_2;
                row_addr_3 <= row_addr_3;
                row_addr_4 <= row_addr_4;            
            end
        end
    end                          
                     
endmodule

