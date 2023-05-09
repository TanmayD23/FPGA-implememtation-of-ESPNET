module arbiter #(
                 parameter data_width = 4352 // 256 words * 17 bits per word
                 )
                (
                    input reset,
                    input clock,
                    input [data_width-1:0]data,
                    input [2:0]control,
                    output reg [data_width-1:0]op_1,
                    output reg [data_width-1:0]op_2,
                    output reg [data_width-1:0]op_3,
                    output reg [data_width-1:0]op_4
                 );
    always@(posedge clock)
    begin
        if(reset == 1'b1)
        begin
            op_1 <= 0;
            op_2 <= 0;
            op_3 <= 0;
            op_4 <= 0;
        end
        else
        begin
            if(control == 3'd1)
            begin
                op_1 <= data;
                op_2 <= op_2;
                op_3 <= op_3;
                op_4 <= op_4;
            end
            else if(control == 3'd2)
            begin
                op_1 <= op_1;
                op_2 <= data;
                op_3 <= op_3;
                op_4 <= op_4;
            end
            else if(control == 3'd3)
            begin
                op_1 <= op_1;
                op_2 <= op_2;
                op_3 <= data;
                op_4 <= op_4;
            end
            else if(control == 3'd4)
            begin
                op_1 <= op_1;
                op_2 <= op_2;
                op_3 <= op_3;
                op_4 <= data;
            end         
            else
            begin
                op_1 <= op_1;
                op_2 <= op_2;
                op_3 <= op_3;
                op_4 <= op_4;            
            end
        end
    end
endmodule
