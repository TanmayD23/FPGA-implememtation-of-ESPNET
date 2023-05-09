module Accum_adder #(
                     parameter data_width = 17
                     )
                    (                     
                     input enable,
                     input signed [data_width-1:0]data_1,
                     input signed [data_width-1:0]data_2,
                     output signed [data_width-1:0]sum
                     );                 
    wire signed [data_width-1:0]sm;
                         
    assign sm = data_1 + data_2;
    
   // assign sum[data_width-1] = (data_1[data_width-1] ^~ data_2[data_width-1]) ? ((data_1[data_width-1] ^ sm[data_width-1]) ? 1'b0 : data_1[data_width-1]) : ((data_1[data_width-1] && !sum[data_width-1] ? 1'b1 : data_1[data_width-1]));
    assign sum[data_width-1] = ((data_1[data_width-1] ^~ data_2[data_width-1])&&enable) ? data_1[data_width-1] : sm[data_width-1];
    assign sum[data_width-2:0] = (((data_1[data_width-1] ^~ data_2[data_width-1]) && (data_1[data_width-1] ^ sm[data_width-1]))&&enable) ? {(data_width-1){!data_1[data_width-1]}} : sm[data_width-2:0]; 
                      
endmodule

